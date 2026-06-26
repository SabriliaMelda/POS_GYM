import 'package:get/get.dart';
import '../services/mock_data_service.dart';

class DashboardController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var totalMembers = 0.obs;
  var activeMembers = 0.obs;
  var expiredMembers = 0.obs;
  var totalGymRevenue = 0.0.obs;
  var totalFBRevenue = 0.0.obs;
  var totalCombinedRevenue = 0.0.obs;
  var gymTransactionCount = 0.obs;
  var fbTransactionCount = 0.obs;
  var todayAttendanceCount = 0.obs;
  var memberGrowthChart = <MemberGrowthPoint>[].obs;
  final selectedMemberGrowthPoint = Rxn<MemberGrowthPoint>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      totalMembers.value = _mockData.members.length;
      activeMembers.value = _mockData.getActiveMembers().length;
      expiredMembers.value = _mockData.getExpiredMembers().length;

      totalGymRevenue.value = _mockData.totalGymRevenue;
      totalFBRevenue.value = _mockData.totalFoodBeverageRevenue;
      totalCombinedRevenue.value = totalGymRevenue.value + totalFBRevenue.value;

      gymTransactionCount.value = _mockData.gymTransactions.length;
      fbTransactionCount.value = _mockData.foodBeverageTransactions.length;
      todayAttendanceCount.value = _mockData.getAttendanceCountByDate(
        DateTime.now(),
      );
      memberGrowthChart.value = _buildMemberGrowthChart();
      selectedMemberGrowthPoint.value = null;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data beranda: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  void selectMemberGrowthPoint(MemberGrowthPoint point) {
    selectedMemberGrowthPoint.value = point;
  }

  List<MemberGrowthPoint> _buildMemberGrowthChart() {
    final now = DateTime.now();
    final currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day - ((now.day - 1) % 7),
    );
    final chartStart = currentWeekStart.subtract(const Duration(days: 42));
    final points = <MemberGrowthPoint>[];
    final registrationDates = _mockData.members.map(
      (member) => member.registrationDate,
    );

    for (var week = 0; week < 7; week++) {
      final weekStart = chartStart.add(Duration(days: week * 7));
      final weekEnd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + 6,
        23,
        59,
        59,
      );
      final pointCutoff = weekEnd.isAfter(now) ? now : weekEnd;
      final registrationCount = registrationDates.where((registrationDate) {
        return !registrationDate.isBefore(weekStart) &&
            !registrationDate.isAfter(pointCutoff);
      }).length;
      final previousCount = points.isEmpty ? 0 : points.last.count;
      final percentChange = _calculatePercentChange(
        previousCount,
        registrationCount,
      );

      points.add(
        MemberGrowthPoint(
          date: weekStart,
          count: registrationCount,
          percentChange: percentChange,
        ),
      );
    }

    return points;
  }

  double _calculatePercentChange(int previousCount, int currentCount) {
    if (previousCount == 0) {
      return currentCount == 0 ? 0 : 100;
    }

    return ((currentCount - previousCount) / previousCount) * 100;
  }
}

class MemberGrowthPoint {
  final DateTime date;
  final int count;
  final double percentChange;

  const MemberGrowthPoint({
    required this.date,
    required this.count,
    this.percentChange = 0,
  });
}
