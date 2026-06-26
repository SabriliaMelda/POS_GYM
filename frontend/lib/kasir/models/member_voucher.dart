import 'member.dart';

/// Jumlah kunjungan untuk membuka satu voucher F&B.
const int kVisitsPerVoucher = 50;

/// Urutan besaran diskon voucher yang BERULANG setiap [kVisitsPerVoucher]
/// kunjungan: 30% -> 50% -> 70% -> 100% -> 30% -> ... dan seterusnya.
///
/// Jadi tiap 50 kunjungan member dapat 1 voucher, dan persennya memutar
/// siklus ini tanpa berhenti:
///   50  -> 30%    250 -> 30%
///   100 -> 50%    300 -> 50%
///   150 -> 70%    350 -> 70%
///   200 -> 100%   400 -> 100%
///
/// Logika ini dipakai bersama oleh layar admin (tampilan) dan kasir
/// (penukaran voucher) agar konsisten.
const List<int> kVoucherCycle = [30, 50, 70, 100];

/// Besaran diskon (persen) untuk milestone ke-[index].
/// index 1 = kunjungan ke-50, index 2 = ke-100, dst.
int voucherPercentForMilestone(int index) {
  if (index < 1) return kVoucherCycle.first;
  return kVoucherCycle[(index - 1) % kVoucherCycle.length];
}

/// Satu voucher pada milestone kunjungan tertentu.
class VoucherTier {
  const VoucherTier({required this.visits, required this.percent});

  /// Jumlah kunjungan saat voucher ini terbuka (kelipatan 50).
  final int visits;

  /// Besaran diskon F&B (persen).
  final int percent;
}

/// Status sebuah voucher yang sudah didapat member.
class MemberVoucherStatus {
  const MemberVoucherStatus({required this.tier, required this.usedAt});

  final VoucherTier tier;

  /// Tanggal voucher dipakai, atau null jika belum dipakai.
  final DateTime? usedAt;

  int get percent => tier.percent;
  int get visits => tier.visits;

  /// Voucher yang sudah didapat selalu terbuka.
  bool get unlocked => true;

  bool get used => usedAt != null;

  /// Sudah didapat tapi belum ditukar -> bisa dipakai di kasir.
  bool get available => !used;
}

/// Daftar voucher yang sudah DIDAPAT member, berurutan dari milestone
/// pertama (50 kunjungan) sampai milestone terakhir yang sudah dicapai.
List<MemberVoucherStatus> memberVoucherStatuses(Member member) {
  final earned = member.totalVisits ~/ kVisitsPerVoucher;
  final usedByMilestone = <int, DateTime>{};
  for (final redemption in member.voucherRedemptions) {
    usedByMilestone[redemption.visitMilestone] = redemption.usedAt;
  }
  return List.generate(earned, (i) {
    final index = i + 1;
    final visits = index * kVisitsPerVoucher;
    return MemberVoucherStatus(
      tier: VoucherTier(
        visits: visits,
        percent: voucherPercentForMilestone(index),
      ),
      usedAt: usedByMilestone[visits],
    );
  });
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

/// Voucher yang sudah didapat dan belum dipakai (siap ditukar di kasir).
List<MemberVoucherStatus> availableVouchers(Member member) {
  return memberVoucherStatuses(member).where((s) => s.available).toList();
}
