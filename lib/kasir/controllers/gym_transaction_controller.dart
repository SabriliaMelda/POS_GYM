import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class GymTransactionController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var transactions = <GymTransaction>[].obs;
  var filteredTransactions = <GymTransaction>[].obs;
  var packages = <GymPackage>[].obs;
  var members = <Member>[].obs;
  var selectedTransaction = Rx<GymTransaction?>(null);
  var isLoading = false.obs;
  var selectedMember = Rx<Member?>(null);
  var selectedPackage = Rx<GymPackage?>(null);
  var customerType = 'new'.obs;
  // POS hanya menerima QRIS dan Debit (via mesin EDC). Tidak menerima tunai.
  var paymentMethod = 'QRIS'.obs;

  @override
  void onInit() {
    super.onInit();
    loadGymPackages();
    loadMemberOptions();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final loadedTransactions = List<GymTransaction>.from(
        _mockData.gymTransactions,
      );
      transactions.value = loadedTransactions;
      filteredTransactions.value = loadedTransactions;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransaction(GymTransaction transaction) async {
    try {
      isLoading.value = true;
      _mockData.addGymTransaction(transaction);
      await loadTransactions();
      Get.snackbar('Berhasil', 'Transaksi berhasil dibuat');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal membuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransaction(GymTransaction transaction) async {
    try {
      isLoading.value = true;
      _mockData.updateGymTransaction(transaction);
      await loadTransactions();
      Get.snackbar('Berhasil', 'Transaksi berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memperbarui transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Member>> loadMembers() async {
    try {
      return _mockData.getActiveMembers();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: $e');
      return [];
    }
  }

  void loadMemberOptions() {
    members.value = _mockData.searchMembers('');
  }

  Future<List<GymPackage>> loadGymPackages() async {
    try {
      final loadedPackages = _mockData.getActiveGymPackages();
      packages.value = loadedPackages;
      return loadedPackages;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat paket gym: $e');
      return [];
    }
  }

  void selectMember(Member member) {
    selectedMember.value = member;
  }

  void selectPackage(GymPackage package) {
    selectedPackage.value = package;
    if (package.packageId == 'PKG-DAILY') {
      customerType.value = 'guest';
      selectedMember.value = null;
    } else if (customerType.value == 'guest') {
      customerType.value = 'new';
    }
  }

  void setCustomerType(String type) {
    customerType.value = type;
    selectedMember.value = null;

    if (type == 'guest') {
      selectedPackage.value = packages.firstWhereOrNull(
        (package) => package.packageId == 'PKG-DAILY',
      );
    } else if (selectedPackage.value?.packageId == 'PKG-DAILY') {
      selectedPackage.value = null;
    }
  }

  double get adminFee => customerType.value == 'new' ? 100000 : 0;

  double get transactionTotal => (selectedPackage.value?.price ?? 0) + adminFee;

  void clearTransaction() {
    selectedMember.value = null;
    selectedPackage.value = null;
    customerType.value = 'new';
    paymentMethod.value = 'QRIS';
  }

  Future<double> getTotalRevenue() async {
    try {
      return _mockData.totalGymRevenue;
    } catch (e) {
      return 0;
    }
  }

  void filterTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      isLoading.value = true;
      final filtered = _mockData.getGymTransactionsInRange(startDate, endDate);
      filteredTransactions.value = filtered;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memfilter transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
