import 'package:flutter/material.dart';

import 'month_year_picker.dart';

/// Memfilter daftar transaksi berdasarkan tanggal.
/// [mode]: 'all' | 'today' | 'date' | 'month'.
List<T> filterByDate<T>(
  List<T> items,
  DateTime Function(T) dateOf,
  String mode,
  DateTime date,
  DateTime month,
) {
  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  switch (mode) {
    case 'today':
      final now = DateTime.now();
      return items.where((it) => sameDay(dateOf(it), now)).toList();
    case 'date':
      return items.where((it) => sameDay(dateOf(it), date)).toList();
    case 'month':
      return items.where((it) {
        final d = dateOf(it);
        return d.year == month.year && d.month == month.month;
      }).toList();
    default:
      return items;
  }
}

/// Baris chip filter tanggal untuk panel riwayat (Semua / Hari Ini / Tanggal /
/// Bulan). [onChanged] dipanggil dengan (mode, date, month) yang baru.
class HistoryDateFilterBar extends StatelessWidget {
  const HistoryDateFilterBar({
    super.key,
    required this.mode,
    required this.date,
    required this.month,
    required this.onChanged,
    this.accent = const Color(0xFF1D4ED8),
  });

  final String mode;
  final DateTime date;
  final DateTime month;
  final void Function(String mode, DateTime date, DateTime month) onChanged;
  final Color accent;

  static String _two(int v) => v.toString().padLeft(2, '0');
  static String _dateLabel(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static String _monthLabel(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            'Semua',
            Icons.all_inbox_rounded,
            mode == 'all',
            () => onChanged('all', date, month),
          ),
          const SizedBox(width: 8),
          _chip(
            'Hari Ini',
            Icons.today_rounded,
            mode == 'today',
            () => onChanged('today', date, month),
          ),
          const SizedBox(width: 8),
          _chip(
            mode == 'date' ? _dateLabel(date) : 'Tanggal',
            Icons.event_rounded,
            mode == 'date',
            () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: date.isAfter(now) ? now : date,
                firstDate: DateTime(now.year - 5),
                lastDate: now,
                helpText: 'Pilih tanggal',
              );
              if (picked != null) onChanged('date', picked, month);
            },
          ),
          const SizedBox(width: 8),
          _chip(
            mode == 'month' ? _monthLabel(month) : 'Bulan',
            Icons.calendar_month_rounded,
            mode == 'month',
            () async {
              final picked = await pickMonthYear(context, initial: month);
              if (picked != null) onChanged('month', date, picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
