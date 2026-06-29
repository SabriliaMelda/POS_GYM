import 'package:flutter/material.dart';

/// Dialog pemilih **bulan + tahun** (bukan kalender). Mengembalikan DateTime
/// (tanggal 1 dari bulan terpilih) atau null bila dibatalkan.
Future<DateTime?> pickMonthYear(
  BuildContext context, {
  required DateTime initial,
  Color accent = const Color(0xFF1D4ED8),
}) {
  final now = DateTime.now();
  const months = [
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
  var year = initial.year;
  return showDialog<DateTime>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setLocal(() => year--),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text(
              '$year',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            IconButton(
              onPressed: year < now.year ? () => setLocal(() => year++) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 280,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(12, (i) {
              final m = i + 1;
              final disabled = year == now.year && m > now.month;
              final selected = initial.year == year && initial.month == m;
              return FilledButton(
                onPressed: disabled
                    ? null
                    : () => Navigator.pop(context, DateTime(year, m)),
                style: FilledButton.styleFrom(
                  backgroundColor: selected
                      ? accent
                      : const Color(0xFFF1F5F9),
                  foregroundColor: selected
                      ? Colors.white
                      : const Color(0xFF111827),
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(months[i]),
              );
            }),
          ),
        ),
      ),
    ),
  );
}
