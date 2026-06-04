import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class AttendanceController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var attendanceRecords = <Attendance>[].obs;
  var todayAttendance = <Attendance>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
    loadTodayAttendance();
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

  Future<void> checkOutMember(int attendanceId, DateTime checkOutTime) async {
    try {
      final attendance = _mockData.getAttendanceById(attendanceId);
      if (attendance != null) {
        final updatedAttendance = Attendance(
          id: attendance.id,
          memberId: attendance.memberId,
          memberName: attendance.memberName,
          attendanceDate: attendance.attendanceDate,
          checkInTime: attendance.checkInTime,
          checkOutTime: '${checkOutTime.hour}:${checkOutTime.minute}',
          rfidCardNumber: attendance.rfidCardNumber,
          createdAt: attendance.createdAt,
          updatedAt: DateTime.now(),
        );
        _mockData.updateAttendance(updatedAttendance);
        await loadTodayAttendance();
        Get.snackbar('Berhasil', 'Member berhasil check-out');
      }
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal check-out member: $e');
    }
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
