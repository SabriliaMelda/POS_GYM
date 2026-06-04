import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Laporan Member',
            'Lihat semua member dan statusnya',
            Icons.people,
            Colors.blue,
            () {
              Get.snackbar('Pratinjau UI', 'Laporan member belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Laporan Omzet',
            'Lihat rincian omzet berdasarkan kategori',
            Icons.attach_money,
            Colors.green,
            () {
              Get.snackbar('Pratinjau UI', 'Laporan omzet belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Laporan Transaksi',
            'Riwayat dan statistik transaksi lengkap',
            Icons.receipt,
            Colors.orange,
            () {
              Get.snackbar('Pratinjau UI', 'Laporan transaksi belum diaktifkan.');
            },
          ),
          _buildReportCard(
            'Laporan Absensi',
            'Statistik dan tren absensi member',
            Icons.calendar_today,
            Colors.purple,
            () {
              Get.snackbar('Pratinjau UI', 'Laporan absensi belum diaktifkan.');
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
