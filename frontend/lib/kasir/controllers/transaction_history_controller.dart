import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';

/// Controller riwayat transaksi kasir. Sumber data = backend.
///
/// Memuat transaksi gym, F&B, dan kunjungan (absensi) dari backend.
class TransactionHistoryController extends GetxController {
  TransactionHistoryController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  final gymTransactions = <GymTransaction>[].obs;
  final fbTransactions = <FoodBeverageTransaction>[].obs;
  final attendanceRecords = <Attendance>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final gym = await _repository.listGymTransactions();
      gym.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      gymTransactions.value = gym;

      final fnb = await _repository.listFnbTransactions();
      fnb.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      fbTransactions.value = fnb;

      attendanceRecords.value = await _repository.listAttendance();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat riwayat: ${_msg(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
