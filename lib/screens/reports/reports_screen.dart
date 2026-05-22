import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Member Report',
            'View all members and their status',
            Icons.people,
            Colors.blue,
            () {
              Get.snackbar('UI Preview', 'Member report belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Revenue Report',
            'View revenue breakdown by category',
            Icons.attach_money,
            Colors.green,
            () {
              Get.snackbar('UI Preview', 'Revenue report belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Transaction Report',
            'Detailed transaction history and statistics',
            Icons.receipt,
            Colors.orange,
            () {
              Get.snackbar('UI Preview', 'Transaction report belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Attendance Report',
            'Member attendance statistics and trends',
            Icons.calendar_today,
            Colors.purple,
            () {
              Get.snackbar('UI Preview', 'Attendance report belum diaktifkan.');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
