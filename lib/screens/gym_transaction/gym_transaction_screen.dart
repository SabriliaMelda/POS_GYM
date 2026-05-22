import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gym_transaction_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../utils/utils.dart';

class GymTransactionScreen extends StatelessWidget {
  const GymTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GymTransactionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Transactions'),
        backgroundColor: Colors.blue,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingWidget()
            : controller.filteredTransactions.isEmpty
                ? const EmptyStateWidget(
                    title: 'No Transactions',
                    subtitle: 'Start by creating a new transaction',
                    icon: Icons.receipt,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('UI Preview', 'Form transaksi gym belum diaktifkan.');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionCard(GymTransaction transaction) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Get.snackbar('UI Preview', 'Detail transaksi gym belum diaktifkan.');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.memberName ?? 'Unknown Member',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.packageName ?? 'Unknown Package',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyUtils.formatCurrency(transaction.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateTimeUtils.formatDateTime(transaction.transactionDate),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: transaction.status == 'completed'
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: transaction.status == 'completed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Card with margin
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? elevation;
  final GestureTapCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        color: backgroundColor ?? Colors.white,
        elevation: elevation ?? 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
