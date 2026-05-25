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
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
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
    final monthStart = DateTime(now.year, now.month);
    final points = <MemberGrowthPoint>[];

    for (var day = 1; day <= now.day; day += 7) {
      final pointDate = DateTime(now.year, now.month, day);
      final endOfPointDate = DateTime(
        pointDate.year,
        pointDate.month,
        pointDate.day,
        23,
        59,
        59,
      );
      final memberCount = _mockData.members.where((member) {
        final registeredAt = member.registrationDate;
        return !registeredAt.isBefore(monthStart) &&
            !registeredAt.isAfter(endOfPointDate);
      }).length;

      points.add(MemberGrowthPoint(date: pointDate, count: memberCount));
    }

    if (points.isEmpty || points.last.date.day != now.day) {
      final todayCount = _mockData.members.where((member) {
        final registeredAt = member.registrationDate;
        return !registeredAt.isBefore(monthStart) && !registeredAt.isAfter(now);
      }).length;
      points.add(MemberGrowthPoint(date: now, count: todayCount));
    }

    return points;
  }
}

class MemberGrowthPoint {
  final DateTime date;
  final int count;

  const MemberGrowthPoint({required this.date, required this.count});
}
