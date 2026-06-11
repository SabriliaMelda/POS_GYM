import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class AttendanceController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var attendanceRecords = <Attendance>[].obs;
  var todayAttendance = <Attendance>[].obs;
  var members = <Member>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
    loadTodayAttendance();
    members.value = _mockData.searchMembers('');
  }

  Future<void> loadAttendance() async {
    try {
      isLoading.value = true;
      final records = List<Attendance>.from(_mockData.attendanceRecords);
      attendanceRecords.value = records;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat absensi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTodayAttendance() async {
    try {
      final records = _mockData.getTodayAttendance();
      todayAttendance.value = records;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat absensi hari ini: $e');
    }
  }

  Future<void> recordAttendance(Attendance attendance) async {
    try {
      isLoading.value = true;
      _mockData.addAttendance(attendance);
      await loadTodayAttendance();
      Get.snackbar('Berhasil', 'Absensi berhasil dicatat');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal mencatat absensi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Attendance?> checkInMember(int memberId) async {
    try {
      final member = _mockData.getMemberById(memberId);
      if (member == null) {
        Get.snackbar('Kesalahan', 'Member tidak ditemukan');
        return null;
      }

      final now = DateTime.now();
      final attendance = Attendance(
        memberId: memberId,
        memberName: member.name,
        attendanceDate: now,
        checkInTime: '${now.hour}:${now.minute}',
        rfidCardNumber: '',
        createdAt: now,
        updatedAt: now,
      );

      await recordAttendance(attendance);
      return attendance;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal check-in member: $e');
      return null;
    }
  }

  Future<bool> processCredential(String credential, String method) async {
    final normalized = credential.trim().toUpperCase();
    if (normalized.isEmpty) {
      Get.snackbar('Kode Kosong', 'Pindai atau masukkan kode akses.');
      return false;
    }

    Member? member;
    if (method == 'rfid') {
      final digits = RegExp(r'\d+').firstMatch(normalized)?.group(0);
      final memberId = int.tryParse(digits ?? '');
      member = members.firstWhereOrNull((item) => item.id == memberId);
    } else {
      member = members.firstWhereOrNull(
        (item) => item.memberId.toUpperCase() == normalized,
      );
    }

    if (member == null) {
      Get.snackbar('Akses Ditolak', 'Kartu atau barcode tidak terdaftar.');
      return false;
    }
    if (!member.isActive || member.isExpired) {
      Get.snackbar('Akses Ditolak', 'Membership ${member.name} tidak aktif.');
      return false;
    }
    final cardReady =
        DateTime.now().difference(member.registrationDate).inDays >= 7;
    if (method == 'rfid' && !cardReady) {
      Get.snackbar(
        'RFID Belum Siap',
        'Gunakan barcode sementara sampai 7 hari setelah registrasi.',
      );
      return false;
    }

    final existing = todayAttendance.firstWhereOrNull(
      (record) => record.memberId == member!.id,
    );
    if (existing != null) {
      Get.snackbar(
        'Sudah Hadir',
        '${member.name} sudah tercatat hadir hari ini pukul ${existing.checkInTime}.',
      );
      return false;
    }

    final now = DateTime.now();
    await recordAttendance(
      Attendance(
        memberId: member.id ?? 0,
        memberName: member.name,
        attendanceDate: now,
        checkInTime: _formatTime(now),
        rfidCardNumber: method == 'rfid'
            ? 'RFID:$normalized'
            : 'BARCODE:$normalized',
        createdAt: now,
        updatedAt: now,
      ),
    );
    return true;
  }

  Future<void> grantDailyAccess() async {
    final now = DateTime.now();
    await recordAttendance(
      Attendance(
        memberId: 0,
        memberName: 'Daily Pass',
        attendanceDate: now,
        checkInTime: _formatTime(now),
        rfidCardNumber: 'DAILY:CASHIER',
        createdAt: now,
        updatedAt: now,
      ),
    );
    Get.snackbar(
      'Pintu Dibuka Kasir',
      'Akses Daily Pass dicatat tanpa RFID atau barcode.',
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<int> getTodayAttendanceCount() async {
    try {
      final now = DateTime.now();
      return _mockData.getAttendanceCountByDate(now);
    } catch (e) {
      return 0;
    }
  }

  Future<List<Attendance>> getMemberAttendanceHistory(int memberId) async {
    try {
      return _mockData.getAttendanceByMemberId(memberId);
    } catch (e) {
      return [];
    }
  }
}
