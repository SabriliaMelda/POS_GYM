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
      todayAttendanceCount.value = _mockData.getAttendanceCountByDate(DateTime.now());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
