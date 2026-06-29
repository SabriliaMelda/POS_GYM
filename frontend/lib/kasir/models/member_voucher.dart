import 'member.dart';

/// Jumlah kunjungan untuk membuka satu voucher F&B.
const int kVisitsPerVoucher = 50;

/// Urutan besaran diskon voucher yang BERULANG tiap 6 milestone (300 kunjungan):
/// 50x->10%, 100x->25%, 150x->35%, 200x->45%, 250x->55%, 300x->70%, lalu ulang.
const List<int> kVoucherCycle = [10, 25, 35, 45, 55, 70];

/// Besaran diskon (persen) untuk milestone ke-[index].
/// index 1 = kunjungan ke-50, index 2 = ke-100, dst.
int voucherPercentForMilestone(int index) {
  if (index < 1) return kVoucherCycle.first;
  return kVoucherCycle[(index - 1) % kVoucherCycle.length];
}

/// Voucher berikutnya yang akan terbuka. Selalu ada karena siklus berulang.
class VoucherTier {
  const VoucherTier({required this.visits, required this.percent});

  /// Jumlah kunjungan saat voucher ini terbuka (kelipatan 50).
  final int visits;

  /// Besaran diskon F&B (persen).
  final int percent;
}

/// Status sebuah voucher yang sudah didapat member. Lifecycle dihitung backend
/// (aktif / dipakai / hangus) berdasarkan tanggal aktif + kadaluwarsa 30 hari.
class MemberVoucherStatus {
  const MemberVoucherStatus({
    required this.visits,
    required this.percent,
    required this.activatedAt,
    required this.expiresAt,
    required this.usedAt,
    required this.status,
  });

  final int visits;
  final int percent;
  final DateTime activatedAt;
  final DateTime expiresAt;

  /// Tanggal voucher dipakai, atau null jika belum dipakai.
  final DateTime? usedAt;

  /// 'active' | 'used' | 'expired' (dari backend).
  final String status;

  bool get used => status == 'used';

  /// Sudah lewat 30 hari tanpa dipakai -> hangus.
  bool get expired => status == 'expired';

  /// Masih bisa ditukar di kasir.
  bool get available => status == 'active';

  /// Sisa hari sebelum hangus (untuk voucher aktif).
  int get daysUntilExpiry =>
      expiresAt.difference(DateTime.now()).inDays;
}

/// Daftar voucher yang sudah DIDAPAT member (dari backend), urut milestone.
List<MemberVoucherStatus> memberVoucherStatuses(Member member) {
  final list =
      member.vouchers
          .map(
            (v) => MemberVoucherStatus(
              visits: v.visitMilestone,
              percent: v.percent,
              activatedAt: v.activatedAt,
              expiresAt: v.expiresAt,
              usedAt: v.usedAt,
              status: v.status,
            ),
          )
          .toList()
        ..sort((a, b) => a.visits.compareTo(b.visits));
  return list;
}

/// Voucher berikutnya yang akan terbuka. Selalu ada karena siklus berulang.
VoucherTier nextVoucherTier(int totalVisits) {
  final nextIndex = (totalVisits ~/ kVisitsPerVoucher) + 1;
  return VoucherTier(
    visits: nextIndex * kVisitsPerVoucher,
    percent: voucherPercentForMilestone(nextIndex),
  );
}

/// Sisa kunjungan menuju voucher berikutnya.
int visitsToNextTier(int totalVisits) {
  return kVisitsPerVoucher - (totalVisits % kVisitsPerVoucher);
}

/// Voucher yang sudah didapat dan masih AKTIF (siap ditukar di kasir).
List<MemberVoucherStatus> availableVouchers(Member member) {
  return memberVoucherStatuses(member).where((s) => s.available).toList();
}
