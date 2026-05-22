import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../constants/app_constants.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(AppColors.primaryColor),
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingWidget(message: 'Loading dashboard...')
            : RefreshIndicator(
                onRefresh: () => controller.refreshDashboard(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildSummaryCard(
                            title: 'Total Members',
                            value: controller.totalMembers.value.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _buildSummaryCard(
                            title: 'Active Members',
                            value: controller.activeMembers.value.toString(),
                            icon: Icons.person_add,
                            color: Colors.green,
                          ),
                          _buildSummaryCard(
                            title: 'Expired Members',
                            value: controller.expiredMembers.value.toString(),
                            icon: Icons.warning,
                            color: Colors.orange,
                          ),
                          _buildSummaryCard(
                            title: 'Today Attendance',
                            value: controller.todayAttendanceCount.value.toString(),
                            icon: Icons.login,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Revenue Section
                      const Text(
                        'Revenue Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRevenueLine(
                              'Gym Transaction',
                              CurrencyUtils.formatCurrency(
                                controller.totalGymRevenue.value,
                              ),
                            ),
                            const Divider(),
                            _buildRevenueLine(
                              'Food & Beverage',
                              CurrencyUtils.formatCurrency(
                                controller.totalFBRevenue.value,
                              ),
                            ),
                            const Divider(),
                            _buildRevenueLine(
                              'Total Revenue',
                              CurrencyUtils.formatCurrency(
                                controller.totalCombinedRevenue.value,
                              ),
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transaction Count Section
                      const Text(
                        'Transaction Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Gym Transactions'),
                                  const SizedBox(height: 8),
                                  Text(
                                    controller.gymTransactionCount.value.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('F&B Transactions'),
                                  const SizedBox(height: 8),
                                  Text(
                                    controller.fbTransactionCount.value.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueLine(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
