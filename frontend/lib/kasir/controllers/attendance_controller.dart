import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';

/// Controller absensi kasir. Sumber data = backend.
///
/// Absensi kini hanya lewat scan barcode (RFID dihapus). Member memindai QR
/// berisi member_code; pencatatan kehadiran dilakukan endpoint publik
/// `POST /api/attendance/check-in` (lihat [MemberCheckInScreen]).
class AttendanceController extends GetxController {
  AttendanceController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  final attendanceRecords = <Attendance>[].obs;
  final todayAttendance = <Attendance>[].obs;
  final members = <Member>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
    loadAttendance();
  }

  Future<void> loadMembers() async {
    try {
      members.value = await _repository.listMembers();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: ${_msg(e)}');
    }
  }

  Future<void> loadAttendance() async {
    try {
      isLoading.value = true;
      final all = await _repository.listAttendance();
      attendanceRecords.value = all;
      final now = DateTime.now();
      todayAttendance.value = all
          .where(
            (a) =>
                a.attendanceDate.year == now.year &&
                a.attendanceDate.month == now.month &&
                a.attendanceDate.day == now.day,
          )
          .toList();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat absensi: ${_msg(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Alias agar layar lama tetap kompatibel; memuat ulang dari backend.
  Future<void> loadTodayAttendance() => loadAttendance();

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
