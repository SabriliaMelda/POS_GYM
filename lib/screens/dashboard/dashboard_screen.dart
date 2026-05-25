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
      backgroundColor: const Color(0xFFF5F7FB),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingWidget(message: 'Loading dashboard...')
            : RefreshIndicator(
                onRefresh: () => controller.refreshDashboard(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    final metricColumns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 360
                        ? 2
                        : 1;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(controller, constraints.maxWidth),
                          const SizedBox(height: 18),
                          _buildMetricGrid(controller, metricColumns),
                          const SizedBox(height: 18),
                          if (isWide)
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildRevenuePanel(controller),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTransactionPanel(controller),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            _buildRevenuePanel(controller),
                            const SizedBox(height: 16),
                            _buildTransactionPanel(controller),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildHeroSection(
    DashboardController controller,
    double availableWidth,
  ) {
    final totalMembers = controller.totalMembers.value;
    final activeMembers = controller.activeMembers.value;
    final activeRate = totalMembers == 0 ? 0.0 : activeMembers / totalMembers;
    final useSideChart = availableWidth >= 620;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (useSideChart)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 4,
                      child: _buildHeroInfo(controller, compact: true),
                    ),
                    const SizedBox(width: 0),
                    Container(
                      width: 1.4,
                      height: 168,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 70),
                    Expanded(
                      flex: 5,
                      child: _buildWeeklyMemberChart(controller),
                    ),
                  ],
                )
              else ...[
                _buildHeroInfo(controller),
                const SizedBox(height: 16),
                _buildWeeklyMemberChart(controller),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: activeRate.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC857),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$activeMembers dari $totalMembers member aktif',
                style: const TextStyle(
                  color: Color(0xFFE8F4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInfo(
    DashboardController controller, {
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'X-FIT Digital Indonesia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ringkasan operasional gym dan penjualan',
                    style: TextStyle(
                      color: Color(0xFFE8F4FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 18,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildHeroValue(
              'Total Omzet',
              CurrencyUtils.formatCurrency(
                controller.totalCombinedRevenue.value,
              ),
            ),
            _buildHeroValue(
              'Kehadiran Hari Ini',
              '${controller.todayAttendanceCount.value} member',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroValue(String label, String value) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(DashboardController controller, int columns) {
    final cards = [
      _DashboardMetric(
        title: 'Total Members',
        value: controller.totalMembers.value.toString(),
        subtitle: 'Terdaftar',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
      ),
      _DashboardMetric(
        title: 'Active Members',
        value: controller.activeMembers.value.toString(),
        subtitle: 'Berlaku',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF16A34A),
      ),
      _DashboardMetric(
        title: 'Expired Members',
        value: controller.expiredMembers.value.toString(),
        subtitle: 'Follow up',
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF97316),
      ),
      _DashboardMetric(
        title: 'Today Attendance',
        value: controller.todayAttendanceCount.value.toString(),
        subtitle: 'Hari ini',
        icon: Icons.login_rounded,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 96,
      ),
      itemBuilder: (context, index) => _buildMetricCard(cards[index]),
    );
  }

  Widget _buildMetricCard(_DashboardMetric metric) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7ECF3)),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    metric.color.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.00),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(metric.icon, color: metric.color, size: 22),
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
                          color: Color(0xFF111827),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  metric.value,
                  style: TextStyle(
                    color: metric.color,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMemberChart(DashboardController controller) {
    return Obx(() {
      final chartPoints = controller.memberGrowthChart.isEmpty
          ? [MemberGrowthPoint(date: DateTime.now(), count: 0)]
          : controller.memberGrowthChart;
      final selectedPoint = controller.selectedMemberGrowthPoint.value;
      final headerPoint = selectedPoint ?? chartPoints.last;

      return Container(
        height: 168,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Grafik Member Bulan Ini',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${headerPoint.count} member',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              selectedPoint == null
                  ? 'Klik titik grafik untuk detail tanggal'
                  : _formatPopupDate(selectedPoint.date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final popupOffset = _chartPointOffset(
                    chartPoints,
                    selectedPoint,
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );

                  return MouseRegion(
                    onHover: (event) {
                      if (selectedPoint != null) {
                        final point = _nearestChartPoint(
                          chartPoints,
                          event.localPosition.dx,
                          contextWidth: constraints.maxWidth,
                        );
                        controller.selectMemberGrowthPoint(point);
                      }
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) {
                        final point = _nearestChartPoint(
                          chartPoints,
                          details.localPosition.dx,
                          contextWidth: constraints.maxWidth,
                        );
                        controller.selectMemberGrowthPoint(point);
                      },
                      onPanUpdate: (details) {
                        final point = _nearestChartPoint(
                          chartPoints,
                          details.localPosition.dx,
                          contextWidth: constraints.maxWidth,
                        );
                        controller.selectMemberGrowthPoint(point);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            painter: _MemberLineChartPainter(
                              points: chartPoints,
                              selectedPoint: selectedPoint,
                            ),
                          ),
                          if (selectedPoint != null)
                            Positioned(
                              left: (popupOffset.dx - 52).clamp(
                                0.0,
                                (constraints.maxWidth - 104).clamp(
                                  0.0,
                                  double.infinity,
                                ),
                              ),
                              top: (popupOffset.dy - 42).clamp(
                                0.0,
                                constraints.maxHeight,
                              ),
                              child: IgnorePointer(
                                child: _buildChartMiniPopup(selectedPoint),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartMiniPopup(MemberGrowthPoint point) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatPopupDate(point.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Offset _chartPointOffset(
    List<MemberGrowthPoint> points,
    MemberGrowthPoint? selectedPoint,
    Size size,
  ) {
    if (points.isEmpty ||
        selectedPoint == null ||
        size.width <= 0 ||
        size.height <= 0) {
      return Offset.zero;
    }

    final chartHeight = size.height - 18;
    final maxCount = points
        .map((point) => point.count)
        .fold<int>(1, (max, value) => value > max ? value : max);
    final selectedIndex = points.indexWhere(
      (point) =>
          point.date.year == selectedPoint.date.year &&
          point.date.month == selectedPoint.date.month &&
          point.date.day == selectedPoint.date.day,
    );
    final index = selectedIndex == -1 ? points.length - 1 : selectedIndex;
    final stepX = points.length <= 1
        ? size.width
        : size.width / (points.length - 1);
    final x = points.length <= 1 ? size.width / 2 : stepX * index;
    final normalized = points[index].count / maxCount;
    final y = chartHeight - (normalized * (chartHeight - 8));

    return Offset(x, y);
  }

  MemberGrowthPoint _nearestChartPoint(
    List<MemberGrowthPoint> points,
    double dx, {
    required double contextWidth,
  }) {
    if (points.length <= 1 || contextWidth <= 0) return points.first;
    final index = ((dx / contextWidth) * (points.length - 1)).round();
    return points[index.clamp(0, points.length - 1)];
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatPopupDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[date.weekday - 1]}, ${_formatShortDate(date)}';
  }

  Widget _buildRevenuePanel(DashboardController controller) {
    final gymRevenue = controller.totalGymRevenue.value;
    final fbRevenue = controller.totalFBRevenue.value;
    final totalRevenue = controller.totalCombinedRevenue.value;

    return _buildPanel(
      title: 'Revenue Summary',
      icon: Icons.payments_rounded,
      child: Column(
        children: [
          _buildRevenueRow(
            label: 'Gym Transaction',
            value: gymRevenue,
            total: totalRevenue,
            color: const Color(0xFF2563EB),
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 16),
          _buildRevenueRow(
            label: 'Food & Beverage',
            value: fbRevenue,
            total: totalRevenue,
            color: const Color(0xFF16A34A),
            icon: Icons.restaurant_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: _buildAmountLine(
              'Total Revenue',
              CurrencyUtils.formatCurrency(totalRevenue),
              color: const Color(0xFF15803D),
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow({
    required String label,
    required double value,
    required double total,
    required Color color,
    required IconData icon,
  }) {
    final progress = total <= 0 ? 0.0 : value / total;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAmountLine(
                label,
                CurrencyUtils.formatCurrency(value),
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountLine(
    String label,
    String value, {
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF374151),
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionPanel(DashboardController controller) {
    return _buildPanel(
      title: 'Transaction Summary',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          _buildTransactionTile(
            title: 'Gym Transactions',
            value: controller.gymTransactionCount.value.toString(),
            color: const Color(0xFF2563EB),
            icon: Icons.local_activity_rounded,
          ),
          const SizedBox(height: 12),
          _buildTransactionTile(
            title: 'F&B Transactions',
            value: controller.fbTransactionCount.value.toString(),
            color: const Color(0xFF16A34A),
            icon: Icons.shopping_bag_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7ECF3)),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.00),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(AppColors.primaryColor),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberLineChartPainter extends CustomPainter {
  final List<MemberGrowthPoint> points;
  final MemberGrowthPoint? selectedPoint;

  const _MemberLineChartPainter({
    required this.points,
    required this.selectedPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    final chartHeight = size.height - 18;
    final maxCount = points
        .map((point) => point.count)
        .fold<int>(1, (max, value) => value > max ? value : max);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = (chartHeight / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final stepX = points.length <= 1
        ? size.width
        : size.width / (points.length - 1);
    final path = Path();
    final fillPath = Path();
    final offsets = <Offset>[];

    for (var index = 0; index < points.length; index++) {
      final x = points.length <= 1 ? size.width / 2 : stepX * index;
      final normalized = points[index].count / maxCount;
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

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.30),
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
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 1;
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final offset in offsets) {
      _drawDashedLine(
        canvas,
        Offset(offset.dx, chartHeight),
        offset,
        dashPaint,
      );
      canvas.drawCircle(offset, 3.2, dotPaint);
      canvas.drawCircle(offset, 3.2, dotBorderPaint);
    }

    if (selectedPoint != null) {
      final selectedIndex = points.indexWhere(
        (point) =>
            point.date.year == selectedPoint!.date.year &&
            point.date.month == selectedPoint!.date.month &&
            point.date.day == selectedPoint!.date.day,
      );

      if (selectedIndex != -1) {
        final selectedOffset = offsets[selectedIndex];
        final guidePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.30)
          ..strokeWidth = 1;
        canvas.drawLine(
          Offset(selectedOffset.dx, 0),
          Offset(selectedOffset.dx, chartHeight),
          guidePaint,
        );
        canvas.drawCircle(selectedOffset, 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          selectedOffset,
          5,
          Paint()
            ..color = const Color(0xFF1D4ED8)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }

    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final label = '${point.date.day}';
      labelPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );
      labelPainter.layout();
      final x = offsets[index].dx - (labelPainter.width / 2);
      labelPainter.paint(canvas, Offset(x, chartHeight + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _MemberLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedPoint != selectedPoint;
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

class _DashboardMetric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
