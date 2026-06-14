import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class TransactionHistoryController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var gymTransactions = <GymTransaction>[].obs;
  var fbTransactions = <FoodBeverageTransaction>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final gymTrans = List<GymTransaction>.from(_mockData.gymTransactions)
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      final fbTrans = List<FoodBeverageTransaction>.from(
        _mockData.foodBeverageTransactions,
      )..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      gymTransactions.value = gymTrans;
      fbTransactions.value = fbTrans;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      isLoading.value = true;
      final gymTrans = _mockData.getGymTransactionsInRange(startDate, endDate);
      final fbTrans = _mockData.getFoodBeverageTransactionsInRange(
        startDate,
        endDate,
      );

      gymTransactions.value = gymTrans;
      fbTransactions.value = fbTrans;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memfilter transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<GymTransaction>> getMemberGymTransactionHistory(
    int memberId,
  ) async {
    try {
      return _mockData.getGymTransactionsByMemberId(memberId);
    } catch (e) {
      return [];
    }
  }

  Future<List<FoodBeverageTransaction>> getMemberFBTransactionHistory(
    int memberId,
  ) async {
    try {
      return _mockData.getFoodBeverageTransactionsByMemberId(memberId);
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalGymRevenue() async {
    try {
      return _mockData.totalGymRevenue;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTotalFBRevenue() async {
    try {
      return _mockData.totalFoodBeverageRevenue;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTotalCombinedRevenue() async {
    try {
      final gymRevenue = await getTotalGymRevenue();
      final fbRevenue = await getTotalFBRevenue();
      return gymRevenue + fbRevenue;
    } catch (e) {
      return 0;
    }
  }
}
