import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_history_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../utils/utils.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gym Revenue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<double>(
                              future: controller.getTotalGymRevenue(),
                              builder: (context, snapshot) {
                                return Text(
                                  CurrencyUtils.formatCurrency(snapshot.data ?? 0),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'F&B Revenue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<double>(
                              future: controller.getTotalFBRevenue(),
                              builder: (context, snapshot) {
                                return Text(
                                  CurrencyUtils.formatCurrency(snapshot.data ?? 0),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Transactions Tab View
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Gym Transactions'),
                      Tab(text: 'F&B Transactions'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Gym Transactions
                        Obx(
                          () => controller.gymTransactions.isEmpty
                              ? const EmptyStateWidget(
                                  title: 'No Gym Transactions',
                                  subtitle: 'Transactions will appear here',
                                  icon: Icons.receipt_long_outlined,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: controller.gymTransactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = controller.gymTransactions[index];
                                    return _buildGymTransactionCard(transaction);
                                  },
                                ),
                        ),
                        // F&B Transactions
                        Obx(
                          () => controller.fbTransactions.isEmpty
                              ? const EmptyStateWidget(
                                  title: 'No F&B Transactions',
                                  subtitle: 'Transactions will appear here',
                                  icon: Icons.shopping_cart_outlined,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: controller.fbTransactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = controller.fbTransactions[index];
                                    return _buildFBTransactionCard(transaction);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymTransactionCard(GymTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.memberName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  CurrencyUtils.formatCurrency(transaction.amount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateTimeUtils.formatDateTime(transaction.transactionDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.status,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFBTransactionCard(FoodBeverageTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.memberName ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  CurrencyUtils.formatCurrency(transaction.finalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateTimeUtils.formatDateTime(transaction.transactionDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${transaction.items.length} items',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
