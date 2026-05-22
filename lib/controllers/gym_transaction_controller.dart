import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class GymTransactionController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var transactions = <GymTransaction>[].obs;
  var filteredTransactions = <GymTransaction>[].obs;
  var selectedTransaction = Rx<GymTransaction?>(null);
  var isLoading = false.obs;
  var selectedMember = Rx<Member?>(null);
  var selectedPackage = Rx<GymPackage?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final loadedTransactions = List<GymTransaction>.from(_mockData.gymTransactions);
      transactions.value = loadedTransactions;
      filteredTransactions.value = loadedTransactions;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransaction(GymTransaction transaction) async {
    try {
      isLoading.value = true;
      _mockData.addGymTransaction(transaction);
      await loadTransactions();
      Get.snackbar('Success', 'Transaction created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransaction(GymTransaction transaction) async {
    try {
      isLoading.value = true;
      _mockData.updateGymTransaction(transaction);
      await loadTransactions();
      Get.snackbar('Success', 'Transaction updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Member>> loadMembers() async {
    try {
      return _mockData.getActiveMembers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load members: $e');
      return [];
    }
  }

  Future<List<GymPackage>> loadGymPackages() async {
    try {
      return _mockData.getActiveGymPackages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load gym packages: $e');
      return [];
    }
  }

  void selectMember(Member member) {
    selectedMember.value = member;
  }

  void selectPackage(GymPackage package) {
    selectedPackage.value = package;
  }

  Future<double> getTotalRevenue() async {
    try {
      return _mockData.totalGymRevenue;
    } catch (e) {
      return 0;
    }
  }

  void filterTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      isLoading.value = true;
      final filtered = _mockData.getGymTransactionsInRange(startDate, endDate);
      filteredTransactions.value = filtered;
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
