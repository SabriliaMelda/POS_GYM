import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../utils/utils.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // RFID Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              label: 'RFID Card Number',
              hint: 'Scan RFID card here',
              prefixIcon: Icons.credit_card,
            ),
          ),
          // Today's Attendance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Today\'s Attendance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.todayAttendance.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No Attendance Today',
                      subtitle: 'Check-in members to see them here',
                      icon: Icons.people_outline,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.todayAttendance.length,
                      itemBuilder: (context, index) {
                        final attendance = controller.todayAttendance[index];
                        return _buildAttendanceCard(attendance);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.memberName ?? 'Unknown Member',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check-in: ${attendance.checkInTime ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                DateTimeUtils.formatDate(attendance.attendanceDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
