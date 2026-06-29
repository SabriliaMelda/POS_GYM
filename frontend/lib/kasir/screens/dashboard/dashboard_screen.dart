import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/dashboard_controller.dart';
import '../../constants/app_constants.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.adminStyle = false});

  /// Gaya admin: warna lebih gelap (khas admin) + Ringkasan Transaksi jadi
  /// grafik donat persentase.
  final bool adminStyle;

  static const Color _neutralText = Color(0xFF111827);
  static const Color _mutedText = Color(0xFF64748B);
  static const Color _softSurface = Color(0xFFF8FAFC);
  static const Color _softBorder = Color(0xFFE2E8F0);
  static const Color _singleAccent = Color(0xFF1F3A5F);
  static const Color _adminAccent = Color(0xFF071A3D);

  Color get _accent => adminStyle ? _adminAccent : _singleAccent;
  List<Color> get _heroColors => adminStyle
      ? const [Color(0xFF050D1F), Color(0xFF0A1E3A), Color(0xFF0E2A4C)]
      : const [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingWidget(message: 'Memuat beranda...')
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
                          if (!adminStyle) _buildLogoutBar(),
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

  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda akan keluar dan kembali ke halaman login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final preferences = await SharedPreferences.getInstance();
    for (final key in const [
      'auth_token',
      'auth_token_type',
      'auth_expires_in',
      'auth_must_change_password',
      'auth_user_role',
      'auth_username',
      'auth_full_name',
    ]) {
      await preferences.remove(key);
    }
    Get.offAllNamed('/');
  }

  Widget _buildLogoutBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(color: Color(0xFFFECACA)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _heroColors,
        ),
      ),
      child: Stack(
        children: [
          // Gaya admin: latar gambar gym + overlay navy.
          if (adminStyle) ...[
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
                      _adminAccent,
                      _adminAccent.withValues(alpha: 0.90),
                      _adminAccent.withValues(alpha: 0.50),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                      child: _buildHeroChart(controller),
                    ),
                  ],
                )
              else ...[
                _buildHeroInfo(controller),
                const SizedBox(height: 16),
                _buildHeroChart(controller),
              ],
              if (!adminStyle) ...[
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
            ],
            ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adminStyle
                        ? 'Dashboard Admin'
                        : 'X-FIT Digital Indonesia',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminStyle
                        ? 'Ringkasan operasional POS Gym hari ini.'
                        : 'Ringkasan operasional gym dan penjualan',
                    style: const TextStyle(
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
        if (!adminStyle) ...[
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
        title: 'Total Member',
        value: controller.totalMembers.value.toString(),
        subtitle: 'Terdaftar',
        icon: Icons.groups_rounded,
      ),
      _DashboardMetric(
        title: 'Member Aktif',
        value: controller.activeMembers.value.toString(),
        subtitle: 'Berlaku',
        icon: Icons.verified_user_rounded,
      ),
      _DashboardMetric(
        title: 'Member Kedaluwarsa',
        value: controller.expiredMembers.value.toString(),
        subtitle: 'Follow up',
        icon: Icons.event_busy_rounded,
      ),
      _DashboardMetric(
        title: 'Absensi Hari Ini',
        value: controller.todayAttendanceCount.value.toString(),
        subtitle: 'Hari ini',
        icon: Icons.login_rounded,
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
                    _softSurface.withValues(alpha: 0.90),
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
                    color: _softSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _softBorder),
                  ),
                  child: Icon(metric.icon, color: _accent, size: 22),
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
                          color: _neutralText,
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
                          color: _mutedText,
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
                  style: const TextStyle(
                    color: _neutralText,
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

  Widget _buildHeroChart(DashboardController controller) => adminStyle
      ? _buildTransactionTrendChart(controller)
      : _buildWeeklyMemberChart(controller);

  // Grafik 2 garis transaksi Gym vs F&B (7 hari) untuk beranda admin.
  Widget _buildTransactionTrendChart(DashboardController controller) {
    const gymColor = Color(0xFFFFC857);
    const fnbColor = Color(0xFF7DD3FC);
    return Obx(() {
      final days = controller.trendDays.toList();
      final gym = controller.gymTrend.toList();
      final fnb = controller.fnbTrend.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaksi 7 Hari',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _trendLegendDot(gymColor, 'Gym'),
              const SizedBox(width: 14),
              _trendLegendDot(fnbColor, 'F&B'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: Size.infinite,
              painter: _TwoLineChartPainter(
                days: days,
                gym: gym,
                fnb: fnb,
                gymColor: gymColor,
                fnbColor: fnbColor,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _trendLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
                    'Pendaftaran 7 Hari',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${headerPoint.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'member baru',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                              left: (popupOffset.dx - 60).clamp(
                                0.0,
                                (constraints.maxWidth - 120).clamp(
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
      width: 120,
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
          const SizedBox(height: 4),
          Text(
            '${point.count} member baru',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
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
      title: 'Ringkasan Omzet',
      icon: Icons.payments_rounded,
      child: Column(
        children: [
          _buildRevenueRow(
            label: 'Transaksi Gym',
            value: gymRevenue,
            total: totalRevenue,
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 16),
          _buildRevenueRow(
            label: 'Makanan & Minuman',
            value: fbRevenue,
            total: totalRevenue,
            icon: Icons.restaurant_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _softSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _softBorder),
            ),
            child: _buildAmountLine(
              'Total Omzet',
              CurrencyUtils.formatCurrency(totalRevenue),
              color: _neutralText,
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
                color: _softSurface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _softBorder),
              ),
              child: Icon(icon, color: _accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAmountLine(
                label,
                CurrencyUtils.formatCurrency(value),
                color: _neutralText,
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
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
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
    if (adminStyle) return _buildTransactionDonutPanel(controller);
    return _buildPanel(
      title: 'Ringkasan Transaksi',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          _buildTransactionTile(
            title: 'Transaksi Gym',
            value: controller.gymTransactionCount.value.toString(),
            icon: Icons.local_activity_rounded,
          ),
          const SizedBox(height: 12),
          _buildTransactionTile(
            title: 'Transaksi M&M',
            value: controller.fbTransactionCount.value.toString(),
            icon: Icons.shopping_bag_rounded,
          ),
        ],
      ),
    );
  }

  // Ringkasan Transaksi gaya admin: grafik donat proporsi Gym vs F&B.
  Widget _buildTransactionDonutPanel(DashboardController controller) {
    final gym = controller.gymTransactionCount.value;
    final fnb = controller.fbTransactionCount.value;
    final total = gym + fnb;
    final gymPct = total == 0 ? 0 : (gym * 100 / total).round();
    final fnbPct = total == 0 ? 0 : 100 - gymPct;
    const gymColor = _adminAccent;
    const fnbColor = Color(0xFFF59E0B);
    return _buildPanel(
      title: 'Ringkasan Transaksi',
      icon: Icons.donut_large_rounded,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutPainter(
                    gym: gym,
                    fnb: fnb,
                    gymColor: gymColor,
                    fnbColor: fnbColor,
                    emptyColor: _softBorder,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: _neutralText,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'transaksi',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDonutLegend(gymColor, 'Transaksi Gym', gym, gymPct),
                const SizedBox(height: 14),
                _buildDonutLegend(fnbColor, 'Transaksi M&M', fnb, fnbPct),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutLegend(Color color, String label, int count, int pct) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _neutralText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: _neutralText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($pct%)',
          style: const TextStyle(
            color: _mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _softBorder),
            ),
            child: Icon(icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _neutralText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _neutralText,
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

  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}

/// Donat 2 segmen (Gym vs F&B) untuk Ringkasan Transaksi gaya admin.
class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.gym,
    required this.fnb,
    required this.gymColor,
    required this.fnbColor,
    required this.emptyColor,
  });

  final int gym;
  final int fnb;
  final Color gymColor;
  final Color fnbColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = gym + fnb;
    final stroke = size.width * 0.20;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - stroke) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = emptyColor;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }

    const start = -pi / 2;
    final gymSweep = 2 * pi * gym / total;
    paint.color = gymColor;
    canvas.drawArc(rect, start, gymSweep, false, paint);
    paint.color = fnbColor;
    canvas.drawArc(rect, start + gymSweep, 2 * pi - gymSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.gym != gym || old.fnb != fnb;
}

/// Grafik 2 garis (Gym & F&B) di atas latar navy hero admin.
class _TwoLineChartPainter extends CustomPainter {
  _TwoLineChartPainter({
    required this.days,
    required this.gym,
    required this.fnb,
    required this.gymColor,
    required this.fnbColor,
  });

  final List<DateTime> days;
  final List<int> gym;
  final List<int> fnb;
  final Color gymColor;
  final Color fnbColor;

  @override
  void paint(Canvas canvas, Size size) {
    final n = days.length;
    if (n == 0) return;
    const bottomPad = 22.0;
    final chartHeight = size.height - bottomPad;
    final maxVal = [...gym, ...fnb, 1].reduce(max).toDouble();
    final dx = n <= 1 ? 0.0 : size.width / (n - 1);

    Offset pointFor(List<int> series, int i) {
      final value = i < series.length ? series[i] : 0;
      final y = chartHeight - (value / maxVal) * (chartHeight - 10) - 5;
      return Offset(dx * i, y);
    }

    // Garis bantu horizontal.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var g = 0; g <= 2; g++) {
      final y = chartHeight * g / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    void drawSeries(List<int> series, Color color) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = pointFor(series, i);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final dot = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(pointFor(series, i), 3, dot);
      }
    }

    drawSeries(gym, gymColor);
    drawSeries(fnb, fnbColor);

    // Label tanggal (angka hari) di bawah.
    for (var i = 0; i < n; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${days[i].day}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (dx * i - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _TwoLineChartPainter old) =>
      old.gym != gym || old.fnb != fnb;
}
