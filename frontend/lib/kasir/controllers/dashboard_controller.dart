import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';

/// Controller Beranda kasir. Semua angka dihitung dari data backend.
class DashboardController extends GetxController {
  DashboardController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  final totalMembers = 0.obs;
  final activeMembers = 0.obs;
  final expiredMembers = 0.obs;
  final totalGymRevenue = 0.0.obs;
  final totalFBRevenue = 0.0.obs;
  final totalCombinedRevenue = 0.0.obs;
  final gymTransactionCount = 0.obs;
  final fbTransactionCount = 0.obs;
  final todayAttendanceCount = 0.obs;
  final memberGrowthChart = <MemberGrowthPoint>[].obs;
  final selectedMemberGrowthPoint = Rxn<MemberGrowthPoint>();

  // Tren transaksi 7 hari terakhir (grafik 2 garis Gym vs F&B di beranda admin).
  final trendDays = <DateTime>[].obs;
  final gymTrend = <int>[].obs;
  final fnbTrend = <int>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final members = await _repository.listMembers();
      final gym = await _repository.listGymTransactions();
      final fnb = await _repository.listFnbTransactions();
      final attendance = await _repository.listAttendance();

      totalMembers.value = members.length;
      activeMembers.value = members.where((m) => !m.isExpired).length;
      expiredMembers.value = members.where((m) => m.isExpired).length;

      totalGymRevenue.value = gym
          .where((t) => t.status.toLowerCase() == 'completed')
          .fold<double>(0, (sum, t) => sum + t.amount);
      totalFBRevenue.value = fnb
          .where((t) => t.status.toLowerCase() == 'completed')
          .fold<double>(0, (sum, t) => sum + t.finalAmount);
      totalCombinedRevenue.value = totalGymRevenue.value + totalFBRevenue.value;

      gymTransactionCount.value = gym.length;
      fbTransactionCount.value = fnb.length;

      final now = DateTime.now();
      todayAttendanceCount.value = attendance
          .where(
            (a) =>
                a.attendanceDate.year == now.year &&
                a.attendanceDate.month == now.month &&
                a.attendanceDate.day == now.day,
          )
          .length;

      // "Member baru" = pendaftaran member baru (transaksi gym tipe 'new'),
      // sesuai yang tampil di Riwayat — termasuk yang belum isi form registrasi.
      final newMemberDates = gym
          .where((t) => (t.customerType ?? '') == 'new')
          .map((t) => t.transactionDate)
          .toList();
      memberGrowthChart.value = _buildMemberGrowthChart(newMemberDates);
      selectedMemberGrowthPoint.value = null;

      final last7 = _last7Days();
      trendDays.value = last7;
      gymTrend.value = _dailyCounts(
        gym.map((t) => t.transactionDate).toList(),
        last7,
      );
      fnbTrend.value = _dailyCounts(
        fnb.map((t) => t.transactionDate).toList(),
        last7,
      );
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data beranda: ${_msg(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async => loadDashboardData();

  void selectMemberGrowthPoint(MemberGrowthPoint point) {
    selectedMemberGrowthPoint.value = point;
  }

  // Grafik "member baru" 7 hari terakhir (per tanggal, bukan per minggu) agar
  // tanggalnya sesuai tanggal pendaftaran sebenarnya.
  List<MemberGrowthPoint> _buildMemberGrowthChart(List<DateTime> dates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final points = <MemberGrowthPoint>[];

    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final count = dates
          .where(
            (d) => d.year == day.year && d.month == day.month && d.day == day.day,
          )
          .length;
      final previousCount = points.isEmpty ? 0 : points.last.count;
      final percentChange = _calculatePercentChange(previousCount, count);

      points.add(
        MemberGrowthPoint(
          date: day,
          count: count,
          percentChange: percentChange,
        ),
      );
    }

    return points;
  }

  List<DateTime> _last7Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];
  }

  List<int> _dailyCounts(List<DateTime> dates, List<DateTime> days) {
    return days
        .map(
          (day) => dates
              .where(
                (d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day,
              )
              .length,
        )
        .toList();
  }

  double _calculatePercentChange(int previousCount, int currentCount) {
    if (previousCount == 0) {
      return currentCount == 0 ? 0 : 100;
    }
    return ((currentCount - previousCount) / previousCount) * 100;
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}

class MemberGrowthPoint {
  final DateTime date;
  final int count;
  final double percentChange;

  const MemberGrowthPoint({
    required this.date,
    required this.count,
    this.percentChange = 0,
  });
}
