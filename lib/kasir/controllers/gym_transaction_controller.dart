import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';

/// Controller transaksi gym untuk kasir. Sumber data = backend.
class GymTransactionController extends GetxController {
  GymTransactionController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  /// Biaya pendaftaran member baru (sinkron dengan backend).
  static const double newMemberAdminFee = 100000;

  final transactions = <GymTransaction>[].obs;
  final filteredTransactions = <GymTransaction>[].obs;
  final packages = <GymPackage>[].obs;
  final members = <Member>[].obs;
  final selectedTransaction = Rx<GymTransaction?>(null);
  final isLoading = false.obs;
  final selectedMember = Rx<Member?>(null);
  final selectedPackage = Rx<GymPackage?>(null);
  final customerType = 'new'.obs;
  // POS hanya menerima QRIS dan Debit (via mesin EDC). Tidak menerima tunai.
  final paymentMethod = 'QRIS'.obs;

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
      final loaded = await _repository.listGymTransactions();
      transactions.value = loaded;
      filteredTransactions.value = loaded;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat transaksi: ${_msg(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<GymPackage>> loadGymPackages() async {
    try {
      final loaded = (await _repository.listGymPackages())
          .where((p) => p.isActive)
          .toList();
      packages.value = loaded;
      return loaded;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat paket gym: ${_msg(e)}');
      return [];
    }
  }

  Future<void> loadMemberOptions() async {
    try {
      members.value = await _repository.listMembers();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: ${_msg(e)}');
    }
  }

  void selectMember(Member member) => selectedMember.value = member;

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
      selectedPackage.value = _firstPackageWhere(
        (p) => p.packageId == 'PKG-DAILY',
      );
    } else if (selectedPackage.value?.packageId == 'PKG-DAILY') {
      selectedPackage.value = null;
    }
  }

  /// Menyiapkan layar untuk perpanjangan member tertentu (dipanggil dari
  /// halaman member saat menekan "Perpanjang").
  Future<void> startRenewal(Member member) async {
    customerType.value = 'member';
    selectedMember.value = member;
    paymentMethod.value = 'QRIS';
    if (packages.isEmpty) await loadGymPackages();
    selectedPackage.value =
        _firstPackageWhere((p) => p.packageId == member.gymPackageId) ??
        (packages.isNotEmpty ? packages.first : null);
  }

  double get adminFee =>
      customerType.value == 'new' ? newMemberAdminFee : 0;

  double get transactionTotal => (selectedPackage.value?.price ?? 0) + adminFee;

  /// Memproses pembayaran ke backend.
  /// Mengembalikan pesan sukses, atau null jika gagal/validasi tidak lolos.
  Future<String?> processPayment() async {
    final package = selectedPackage.value;
    if (package == null) {
      Get.snackbar('Paket Belum Dipilih', 'Pilih paket terlebih dahulu.');
      return null;
    }
    final type = customerType.value;
    if (type == 'member' && selectedMember.value == null) {
      Get.snackbar(
        'Member Belum Dipilih',
        'Pilih member yang akan diperpanjang.',
      );
      return null;
    }
    try {
      isLoading.value = true;
      final notes = switch (type) {
        'new' => 'Pembayaran member baru | Data diri via QR registrasi kasir',
        'guest' => 'Kunjungan harian non-member',
        _ => 'Perpanjangan member',
      };
      await _repository.createGymTransaction(
        customerType: type,
        memberId: type == 'member' ? selectedMember.value!.id : null,
        packageCode: package.packageId,
        paymentMethod: paymentMethod.value,
        notes: notes,
      );
      await loadTransactions();
      if (type == 'member') await loadMemberOptions();
      return switch (type) {
        'new' => 'Pembayaran diterima. Arahkan pelanggan scan QR registrasi.',
        'guest' => 'Pembayaran daily pass berhasil.',
        _ => 'Perpanjangan ${selectedMember.value?.name ?? 'member'} berhasil.',
      };
    } catch (e) {
      Get.snackbar('Gagal', 'Pembayaran gagal: ${_msg(e)}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void clearTransaction() {
    selectedMember.value = null;
    selectedPackage.value = null;
    customerType.value = 'new';
    paymentMethod.value = 'QRIS';
  }

  void filterTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    filteredTransactions.value = transactions
        .where(
          (t) =>
              !t.transactionDate.isBefore(start) &&
              !t.transactionDate.isAfter(end),
        )
        .toList();
  }

  GymPackage? _firstPackageWhere(bool Function(GymPackage) test) {
    for (final p in packages) {
      if (test(p)) return p;
    }
    return null;
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
