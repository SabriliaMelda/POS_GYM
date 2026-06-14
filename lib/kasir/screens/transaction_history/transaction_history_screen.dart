import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_history_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const _background = Color(0xFFF5F7FB);
  static const _surface = Colors.white;
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _primary = Color(0xFF1D4ED8);
  static const _navy = Color(0xFF071A3D);
  late final TransactionHistoryController _controller;
  final _searchController = TextEditingController();
  String _query = '';
  _HistoryType? _selectedType;

  @override
  void initState() {
    super.initState();
    final isRegistered = Get.isRegistered<TransactionHistoryController>();
    _controller = isRegistered
        ? Get.find<TransactionHistoryController>()
        : Get.put(TransactionHistoryController());
    if (isRegistered) _controller.loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
            ),
          ),
        ),
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Semua aktivitas pembayaran gym dan F&B',
              style: TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _controller.loadTransactions,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final entries = _buildEntries();
        final filteredEntries = _filterEntries(entries);

        return RefreshIndicator(
          onRefresh: _controller.loadTransactions,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                sliver: SliverToBoxAdapter(child: _buildHero(entries)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                sliver: SliverToBoxAdapter(child: _buildFilters(entries)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            color: _text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${filteredEntries.length} transaksi',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_controller.isLoading.value && entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredEntries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    title: 'Transaksi Tidak Ditemukan',
                    subtitle: 'Ubah kata kunci atau filter transaksi',
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.separated(
                    itemCount: filteredEntries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildTransactionCard(filteredEntries[index]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHero(List<_HistoryEntry> entries) {
    final totalRevenue = entries.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26071A3D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          final summary = _buildHeroSummary(totalRevenue);
          final chart = _buildRevenueChart(entries);

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 290, child: summary),
                const SizedBox(width: 24),
                Expanded(child: chart),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [summary, const SizedBox(height: 18), chart],
          );
        },
      ),
    );
  }

  Widget _buildHeroSummary(double totalRevenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Total Omzet Tercatat',
          style: TextStyle(
            color: Color(0xFFC8DDF2),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatCurrencySimple(totalRevenue),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gabungan pendaftaran, daily pass, perpanjangan, dan penjualan F&B.',
          style: TextStyle(
            color: Color(0xFFC8DDF2),
            fontSize: 10,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<_HistoryEntry> entries) {
    final groups = _monthlyRevenue(entries);
    final types = _HistoryType.values;
    final maxValue = groups.fold<double>(0, (max, group) {
      final groupMax = group.values.values.fold<double>(0, math.max);
      return math.max(max, groupMax);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Omzet per Kategori (4 bulan terakhir)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          width: double.infinity,
          child: maxValue <= 0
              ? const Center(
                  child: Text(
                    'Belum ada data omzet untuk ditampilkan',
                    style: TextStyle(color: Color(0xFFC8DDF2), fontSize: 11),
                  ),
                )
              : CustomPaint(
                  painter: _GroupedBarChartPainter(
                    groups: groups,
                    types: types,
                    colorFor: (type) => _visualFor(type).color,
                    maxValue: maxValue,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: types.map((type) {
            final visual = _visualFor(type);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: visual.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  visual.shortLabel,
                  style: const TextStyle(
                    color: Color(0xFFC8DDF2),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<_MonthRevenue> _monthlyRevenue(List<_HistoryEntry> entries) {
    final now = DateTime.now();
    final months = [
      for (var i = 3; i >= 0; i--) DateTime(now.year, now.month - i, 1),
    ];
    return months.map((month) {
      final values = {for (final type in _HistoryType.values) type: 0.0};
      for (final entry in entries) {
        if (entry.date.year == month.year && entry.date.month == month.month) {
          values[entry.type] = values[entry.type]! + entry.amount;
        }
      }
      return _MonthRevenue(label: _monthShort(month.month), values: values);
    }).toList();
  }

  String _monthShort(int month) {
    const names = [
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
    return names[(month - 1) % 12];
  }

  Widget _buildFilters(List<_HistoryEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari nama, ID transaksi, paket, atau item...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: _primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: _background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primary, width: 1.3),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  count: entries.length,
                  selected: _selectedType == null,
                  onSelected: () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: 7),
                ..._HistoryType.values.map((type) {
                  final visual = _visualFor(type);
                  final count = entries
                      .where((entry) => entry.type == type)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _buildFilterChip(
                      label: visual.shortLabel,
                      count: count,
                      selected: _selectedType == type,
                      onSelected: () => setState(() => _selectedType = type),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      label: Text('$label  $count'),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _muted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
      selectedColor: _primary,
      backgroundColor: _background,
      side: BorderSide(color: selected ? _primary : _border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    );
  }

  Widget _buildTransactionCard(_HistoryEntry entry) {
    final visual = _visualFor(entry.type);
    final status = _statusVisual(entry.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F071A3D),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(visual.icon, color: visual.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      entry.customerName,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _buildBadge(
                      visual.label,
                      visual.color,
                      visual.color.withValues(alpha: 0.09),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildMetadata(Icons.tag_rounded, entry.transactionId),
                    _buildMetadata(
                      Icons.schedule_rounded,
                      DateTimeUtils.formatDateTime(entry.date),
                    ),
                    _buildMetadata(
                      Icons.payments_outlined,
                      entry.paymentMethod,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatCurrencySimple(entry.amount),
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              _buildBadge(status.label, status.color, status.background),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 13),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  List<_HistoryEntry> _buildEntries() {
    final entries = <_HistoryEntry>[
      ..._controller.gymTransactions.map(_entryFromGym),
      ..._controller.fbTransactions.map(_entryFromFoodBeverage),
    ];
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  List<_HistoryEntry> _filterEntries(List<_HistoryEntry> entries) {
    final query = _query.toLowerCase();
    return entries.where((entry) {
      if (_selectedType != null && entry.type != _selectedType) return false;
      if (query.isEmpty) return true;
      return entry.customerName.toLowerCase().contains(query) ||
          entry.transactionId.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query) ||
          entry.paymentMethod.toLowerCase().contains(query) ||
          _visualFor(entry.type).label.toLowerCase().contains(query);
    }).toList();
  }

  _HistoryEntry _entryFromGym(GymTransaction transaction) {
    final notes = (transaction.notes ?? '').toLowerCase();
    final package = (transaction.packageName ?? '').toLowerCase();
    final customer = (transaction.memberName ?? '').toLowerCase();

    final type =
        notes.contains('member baru') ||
            customer.contains('pendaftaran member baru')
        ? _HistoryType.registration
        : notes.contains('harian') || package.contains('daily pass')
        ? _HistoryType.dailyPass
        : _HistoryType.renewal;

    final description = switch (type) {
      _HistoryType.registration =>
        '${transaction.packageName ?? 'Paket gym'} + biaya pendaftaran member baru',
      _HistoryType.dailyPass =>
        '${transaction.packageName ?? 'Daily Pass'} untuk kunjungan harian',
      _HistoryType.renewal =>
        'Perpanjangan ${transaction.packageName ?? 'membership gym'}',
      _HistoryType.foodBeverage => transaction.packageName ?? 'Transaksi gym',
    };

    return _HistoryEntry(
      transactionId: transaction.transactionId,
      customerName: transaction.memberName ?? 'Pelanggan Gym',
      description: description,
      amount: transaction.amount,
      paymentMethod: transaction.paymentMethod,
      status: transaction.status,
      date: transaction.transactionDate,
      type: type,
    );
  }

  _HistoryEntry _entryFromFoodBeverage(FoodBeverageTransaction transaction) {
    final totalQuantity = transaction.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final itemNames = transaction.items.map((item) => item.itemName).join(', ');
    final description = itemNames.isEmpty
        ? '${transaction.items.length} jenis item F&B'
        : '$totalQuantity item: $itemNames';

    return _HistoryEntry(
      transactionId: transaction.transactionId,
      customerName: transaction.memberName ?? 'Pelanggan Non-member',
      description: description,
      amount: transaction.finalAmount,
      paymentMethod: transaction.paymentMethod,
      status: transaction.status,
      date: transaction.transactionDate,
      type: _HistoryType.foodBeverage,
    );
  }

  ({String label, String shortLabel, IconData icon, Color color}) _visualFor(
    _HistoryType type,
  ) {
    return switch (type) {
      _HistoryType.registration => (
        label: 'Pendaftaran Baru',
        shortLabel: 'Pendaftaran',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFF2563EB),
      ),
      _HistoryType.dailyPass => (
        label: 'Daily Pass',
        shortLabel: 'Daily Pass',
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFFD97706),
      ),
      _HistoryType.foodBeverage => (
        label: 'Food & Beverage',
        shortLabel: 'F&B',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _HistoryType.renewal => (
        label: 'Perpanjangan',
        shortLabel: 'Perpanjangan',
        icon: Icons.autorenew_rounded,
        color: const Color(0xFF0891B2),
      ),
    };
  }

  ({String label, Color color, Color background}) _statusVisual(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
      case 'selesai':
        return (
          label: 'SELESAI',
          color: const Color(0xFF15803D),
          background: const Color(0xFFEAF7EE),
        );
      case 'pending':
        return (
          label: 'MENUNGGU',
          color: const Color(0xFFB45309),
          background: const Color(0xFFFFF7E6),
        );
      case 'cancelled':
        return (
          label: 'DIBATALKAN',
          color: const Color(0xFFB91C1C),
          background: const Color(0xFFFEECEC),
        );
      default:
        return (
          label: value.toUpperCase(),
          color: _muted,
          background: _background,
        );
    }
  }
}

class _MonthRevenue {
  const _MonthRevenue({required this.label, required this.values});

  final String label;
  final Map<_HistoryType, double> values;
}

class _GroupedBarChartPainter extends CustomPainter {
  _GroupedBarChartPainter({
    required this.groups,
    required this.types,
    required this.colorFor,
    required this.maxValue,
  });

  final List<_MonthRevenue> groups;
  final List<_HistoryType> types;
  final Color Function(_HistoryType) colorFor;
  final double maxValue;

  static const _axisColor = Color(0x33FFFFFF);
  static const _labelColor = Color(0xFFC8DDF2);

  @override
  void paint(Canvas canvas, Size size) {
    const leftAxis = 40.0;
    const bottomAxis = 18.0;
    const topPad = 6.0;
    final plotLeft = leftAxis;
    final plotTop = topPad;
    final plotRight = size.width;
    final plotBottom = size.height - bottomAxis;
    final plotHeight = plotBottom - plotTop;
    final plotWidth = plotRight - plotLeft;
    if (plotHeight <= 0 || plotWidth <= 0) return;

    final niceMax = _niceCeil(maxValue);
    final gridPaint = Paint()
      ..color = _axisColor
      ..strokeWidth = 1;

    const gridCount = 4;
    for (var i = 0; i <= gridCount; i++) {
      final fraction = i / gridCount;
      final y = plotBottom - fraction * plotHeight;
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
      _drawText(
        canvas,
        _shortValue(niceMax * fraction),
        Offset(plotLeft - 6, y),
        align: TextAlign.right,
        anchorRight: true,
        anchorMiddle: true,
        fontSize: 8,
      );
    }

    final groupWidth = plotWidth / groups.length;
    final barCount = types.length;
    const maxBarWidth = 28.0;
    const gap = 4.0;
    final rawBarWidth = (groupWidth * 0.7 - gap * (barCount - 1)) / barCount;
    final barWidth = math.min(rawBarWidth, maxBarWidth);
    final barAreaWidth = barWidth * barCount + gap * (barCount - 1);

    for (var g = 0; g < groups.length; g++) {
      final group = groups[g];
      final groupStart = plotLeft + g * groupWidth;
      final barsStart = groupStart + (groupWidth - barAreaWidth) / 2;

      for (var t = 0; t < barCount; t++) {
        final type = types[t];
        final value = group.values[type] ?? 0;
        final barHeight = niceMax <= 0 ? 0.0 : (value / niceMax) * plotHeight;
        final left = barsStart + t * (barWidth + gap);
        final rect = Rect.fromLTWH(
          left,
          plotBottom - barHeight,
          barWidth,
          barHeight,
        );
        final paint = Paint()..color = colorFor(type);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          paint,
        );
      }

      _drawText(
        canvas,
        group.label,
        Offset(groupStart + groupWidth / 2, plotBottom + 4),
        align: TextAlign.center,
        anchorCenter: true,
        fontSize: 9,
      );
    }
  }

  double _niceCeil(double value) {
    if (value <= 0) return 1;
    final magnitude = math
        .pow(10, (math.log(value) / math.ln10).floor())
        .toDouble();
    final normalized = value / magnitude;
    final niceNormalized = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 5
        ? 5
        : 10;
    return niceNormalized * magnitude;
  }

  String _shortValue(double value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return '${millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1)}jt';
    }
    if (value >= 1000) return '${(value / 1000).round()}rb';
    return value.toStringAsFixed(0);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    required TextAlign align,
    bool anchorRight = false,
    bool anchorCenter = false,
    bool anchorMiddle = false,
    double fontSize = 9,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _labelColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = position.dx;
    if (anchorRight) {
      dx -= painter.width;
    } else if (anchorCenter) {
      dx -= painter.width / 2;
    }
    var dy = position.dy;
    if (anchorMiddle) dy -= painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) {
    return oldDelegate.groups != groups || oldDelegate.maxValue != maxValue;
  }
}

enum _HistoryType { registration, dailyPass, foodBeverage, renewal }

class _HistoryEntry {
  const _HistoryEntry({
    required this.transactionId,
    required this.customerName,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.type,
  });

  final String transactionId;
  final String customerName;
  final String description;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime date;
  final _HistoryType type;
}
