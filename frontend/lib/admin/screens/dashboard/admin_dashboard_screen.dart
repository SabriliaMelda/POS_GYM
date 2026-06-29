import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../kasir/models/index.dart';
import '../master/admin_master_data_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const Color _background = Color(0xFFF4F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _navy = Color(0xFF071A3D);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Semua angka beranda dihitung dari data backend (sama seperti kasir).
  final AdminMasterDataRepository _repository = AdminMasterDataRepository();
  _AdminDashboardData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final members = await _repository.listMembers();
      final gym = await _repository.listGymTransactions();
      final fnb = await _repository.listFnbTransactions();
      final packages = await _repository.listGymPackages();
      final fnbItems = await _repository.listFnbItems();
      final attendance = await _repository.listAttendance();
      if (!mounted) return;
      setState(() {
        _data = _AdminDashboardData.from(
          members: members,
          gymTransactions: gym,
          fnbTransactions: fnb,
          packages: packages,
          fnbItems: fnbItems,
          attendance: attendance,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardScreen._background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : RefreshIndicator(
                onRefresh: _load,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    final padding = isWide ? 28.0 : 16.0;
                    final data = _data!;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(padding, 18, padding, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(isWide: isWide),
                          const SizedBox(height: 16),
                          _MetricGrid(data: data, isWide: isWide),
                          const SizedBox(height: 16),
                          _ChartSection(data: data, isWide: isWide),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AdminDashboardScreen._muted,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat beranda.\n${_error ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AdminDashboardScreen._muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gym/premium-gym-hero.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AdminDashboardScreen._navy,
                    AdminDashboardScreen._navy.withValues(alpha: 0.92),
                    AdminDashboardScreen._navy.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Expanded(child: _buildHeaderContent())],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logogym.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Ringkasan operasional POS Gym hari ini.',
                style: TextStyle(
                  color: Color(0xFFDCEBFF),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.data, required this.isWide});

  final _AdminDashboardData data;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        title: 'Member Aktif',
        value: data.activeMembers.toString(),
        helper: '${data.expiringMembers} hampir habis',
        icon: Icons.groups_rounded,
        color: AdminDashboardScreen._navy,
      ),
      _MetricData(
        title: 'Kunjungan',
        value: data.todayVisits.toString(),
        helper: 'Hari ini',
        icon: Icons.how_to_reg_rounded,
        color: AdminDashboardScreen._navy,
      ),
      _MetricData(
        title: 'Paket Gym',
        value: data.activePackages.toString(),
        helper: 'Aktif dijual',
        icon: Icons.fitness_center_rounded,
        color: AdminDashboardScreen._navy,
      ),
      _MetricData(
        title: 'Produk F&B',
        value: data.activeProducts.toString(),
        helper: '${data.lowStockProducts} stok rendah',
        icon: Icons.local_cafe_rounded,
        color: AdminDashboardScreen._navy,
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 86,
      ),
      itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminDashboardScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminDashboardScreen._border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(metric.icon, color: metric.color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminDashboardScreen._text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminDashboardScreen._muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            metric.value,
            style: const TextStyle(
              color: AdminDashboardScreen._text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.data, required this.isWide});

  final _AdminDashboardData data;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminDashboardScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminDashboardScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Ringkas 4 Minggu',
            style: TextStyle(
              color: AdminDashboardScreen._text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tren aktivitas utama dengan konsep grafik seperti dashboard kasir.',
            style: TextStyle(
              color: AdminDashboardScreen._muted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: data.chartItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 214,
            ),
            itemBuilder: (context, index) {
              return _MiniChartCard(item: data.chartItems[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _MiniChartCard extends StatelessWidget {
  const _MiniChartCard({required this.item});

  final _ChartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminDashboardScreen._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.helper,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 96,
            width: double.infinity,
            child: _MiniLineChart(values: item.values, labels: item.labels),
          ),
        ],
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AdminLineChartPainter(values: values, labels: labels),
    );
  }
}

class _AdminLineChartPainter extends CustomPainter {
  const _AdminLineChartPainter({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    final chartHeight = size.height - 18;
    final maxValue = values.fold<int>(
      1,
      (max, value) => value > max ? value : max,
    );
    final stepX = values.length <= 1
        ? size.width
        : size.width / (values.length - 1);
    final offsets = <Offset>[];
    final path = Path();
    final fillPath = Path();

    for (var index = 0; index < values.length; index++) {
      final x = values.length <= 1 ? size.width / 2 : stepX * index;
      final normalized = values[index] / maxValue;
      final y = chartHeight - (normalized * (chartHeight - 8));
      final offset = Offset(x, y);
      offsets.add(offset);

      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, chartHeight);
        fillPath.lineTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }
    }

    fillPath
      ..lineTo(offsets.last.dx, chartHeight)
      ..close();

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = (chartHeight / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = AdminDashboardScreen._navy
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final offset in offsets) {
      _drawDashedLine(
        canvas,
        Offset(offset.dx, chartHeight),
        offset,
        dashPaint,
      );
      canvas.drawCircle(offset, 3.4, dotPaint);
      canvas.drawCircle(offset, 3.4, dotBorderPaint);
    }

    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var index = 0; index < offsets.length; index++) {
      labelPainter.text = TextSpan(
        text: labels[index],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.80),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(offsets[index].dx - (labelPainter.width / 2), chartHeight + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AdminLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashHeight = 4.0;
    const dashGap = 4.0;
    var y = start.dy;

    while (y > end.dy) {
      final nextY = (y - dashHeight).clamp(end.dy, start.dy);
      canvas.drawLine(Offset(start.dx, y), Offset(end.dx, nextY), paint);
      y = nextY - dashGap;
    }
  }
}

class _AdminDashboardData {
  _AdminDashboardData({
    required this.activeMembers,
    required this.expiringMembers,
    required this.todayVisits,
    required this.activePackages,
    required this.activeProducts,
    required this.lowStockProducts,
    required this.monthRevenue,
    required this.monthTransactionCount,
    required this.chartItems,
  });

  final int activeMembers;
  final int expiringMembers;
  final int todayVisits;
  final int activePackages;
  final int activeProducts;
  final int lowStockProducts;
  final double monthRevenue;
  final int monthTransactionCount;
  final List<_ChartItem> chartItems;

  String get monthRevenueLabel => _currency.format(monthRevenue);

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  factory _AdminDashboardData.from({
    required List<Member> members,
    required List<GymTransaction> gymTransactions,
    required List<FoodBeverageTransaction> fnbTransactions,
    required List<GymPackage> packages,
    required List<FoodBeverageItem> fnbItems,
    required List<Attendance> attendance,
  }) {
    final now = DateTime.now();
    final activeMembers = members.where((member) => !member.isExpired).toList();
    final expiringMembers = activeMembers
        .where((member) => member.daysUntilExpiry <= 7)
        .length;
    final todayVisits = attendance
        .where(
          (a) =>
              a.attendanceDate.year == now.year &&
              a.attendanceDate.month == now.month &&
              a.attendanceDate.day == now.day,
        )
        .length;
    final activeProducts = fnbItems.where((item) => item.isActive).toList();
    final lowStockProducts = activeProducts.where((item) => item.stock <= 12);

    final rangeStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 27));
    final rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final rangeGymTransactions = gymTransactions.where(
      (transaction) =>
          !transaction.transactionDate.isBefore(rangeStart) &&
          !transaction.transactionDate.isAfter(rangeEnd),
    );
    final rangeFnbTransactions = fnbTransactions.where(
      (transaction) =>
          !transaction.transactionDate.isBefore(rangeStart) &&
          !transaction.transactionDate.isAfter(rangeEnd),
    );

    final newMembers = rangeGymTransactions.where((transaction) {
      final member = (transaction.memberName ?? '').toLowerCase();
      final notes = (transaction.notes ?? '').toLowerCase();
      return member.contains('pendaftaran') || notes.contains('member baru');
    }).toList();
    final renewals = rangeGymTransactions.where((transaction) {
      final package = (transaction.packageName ?? '').toLowerCase();
      final member = (transaction.memberName ?? '').toLowerCase();
      final notes = (transaction.notes ?? '').toLowerCase();
      final isDailyPass = package.contains('daily') || notes.contains('harian');
      final isNewMember =
          member.contains('pendaftaran') || notes.contains('member baru');
      return notes.contains('perpanjangan') ||
          (transaction.memberId > 0 && !isDailyPass && !isNewMember);
    }).toList();

    final monthRevenue =
        rangeGymTransactions.fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        ) +
        rangeFnbTransactions.fold<double>(
          0,
          (sum, transaction) => sum + transaction.finalAmount,
        );

    return _AdminDashboardData(
      activeMembers: activeMembers.length,
      expiringMembers: expiringMembers,
      todayVisits: todayVisits,
      activePackages: packages.where((p) => p.isActive).length,
      activeProducts: activeProducts.length,
      lowStockProducts: lowStockProducts.length,
      monthRevenue: monthRevenue,
      monthTransactionCount:
          rangeGymTransactions.length + rangeFnbTransactions.length,
      chartItems: [
        _ChartItem(
          title: 'Member Baru',
          value: newMembers.length,
          helper: 'Pendaftaran bulan ini',
          values: _periodCounts(newMembers, rangeStart),
          labels: _periodLabels,
          icon: Icons.person_add_alt_1_rounded,
          color: AdminDashboardScreen._navy,
        ),
        _ChartItem(
          title: 'Perpanjangan',
          value: renewals.length,
          helper: 'Membership diperbarui',
          values: _periodCounts(renewals, rangeStart),
          labels: _periodLabels,
          icon: Icons.autorenew_rounded,
          color: AdminDashboardScreen._navy,
        ),
        _ChartItem(
          title: 'F&B',
          value: rangeFnbTransactions.length,
          helper: 'Transaksi produk',
          values: _periodCounts(rangeFnbTransactions.toList(), rangeStart),
          labels: _periodLabels,
          icon: Icons.local_cafe_rounded,
          color: AdminDashboardScreen._navy,
        ),
      ],
    );
  }

  static const List<String> _periodLabels = ['M1', 'M2', 'M3', 'M4'];

  static List<int> _periodCounts(List<dynamic> transactions, DateTime start) {
    final values = List<int>.filled(4, 0);
    for (final transaction in transactions) {
      final transactionDate = transaction.transactionDate as DateTime;
      final periodIndex = transactionDate.difference(start).inDays ~/ 7;
      if (periodIndex < 0 || periodIndex > 3) continue;
      values[periodIndex] += 1;
    }
    return values;
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;
}

class _ChartItem {
  const _ChartItem({
    required this.title,
    required this.value,
    required this.helper,
    required this.values,
    required this.labels,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final String helper;
  final List<int> values;
  final List<String> labels;
  final IconData icon;
  final Color color;

  String get changeLabel {
    if (values.length < 2) return '0% dari minggu lalu';
    final previous = values[values.length - 2];
    final current = values.last;
    if (previous == 0 && current == 0) return '0% dari minggu lalu';
    if (previous == 0) return '+100% dari minggu lalu';
    final percent = ((current - previous) / previous) * 100;
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(0)}% dari minggu lalu';
  }
}
