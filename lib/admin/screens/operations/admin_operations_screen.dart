import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../kasir/services/mock_data_service.dart';

class AdminOperationsScreen extends StatelessWidget {
  const AdminOperationsScreen({super.key});

  static const Color _background = Color(0xFFF4F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _navy = Color(0xFF071A3D);

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final service = MockDataService.instance;
    final transactions = [
      ...service.gymTransactions.map(
        (trx) => _OperationItem(
          title: trx.transactionId,
          subtitle: '${trx.packageName ?? 'Gym'} | ${trx.paymentMethod}',
          amount: trx.amount,
          icon: Icons.fitness_center_rounded,
        ),
      ),
      ...service.foodBeverageTransactions.map(
        (trx) => _OperationItem(
          title: trx.transactionId,
          subtitle: 'F&B | ${trx.paymentMethod}',
          amount: trx.finalAmount,
          icon: Icons.local_cafe_rounded,
        ),
      ),
    ]..sort((a, b) => b.title.compareTo(a.title));

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(
                title: 'Operasional',
                subtitle: 'Pantau transaksi layanan gym, F&B, dan kunjungan.',
                icon: Icons.admin_panel_settings_rounded,
              ),
              const SizedBox(height: 14),
              _Panel(
                title: 'Transaksi Terbaru',
                children: transactions.take(7).map((item) {
                  return _OperationTile(item: item);
                }).toList(),
              ),
              const SizedBox(height: 14),
              _Panel(
                title: 'Kunjungan Member',
                children: service.attendanceRecords.take(6).map((attendance) {
                  return _SimpleTile(
                    icon: Icons.how_to_reg_rounded,
                    title: attendance.memberName ?? 'Member',
                    subtitle:
                        '${attendance.checkInTime ?? '-'} | ${attendance.rfidCardNumber ?? 'Manual'}',
                    trailing: 'Hadir',
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminOperationsScreen._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminOperationsScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminOperationsScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AdminOperationsScreen._text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.item});

  final _OperationItem item;

  @override
  Widget build(BuildContext context) {
    return _SimpleTile(
      icon: item.icon,
      title: item.title,
      subtitle: item.subtitle,
      trailing: AdminOperationsScreen._currency.format(item.amount),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminOperationsScreen._border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AdminOperationsScreen._navy, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOperationsScreen._text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOperationsScreen._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: const TextStyle(
              color: AdminOperationsScreen._navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationItem {
  const _OperationItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
}
