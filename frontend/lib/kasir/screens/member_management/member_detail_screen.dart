import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/food_beverage_transaction_controller.dart';
import '../../controllers/gym_transaction_controller.dart';
import '../../controllers/kasir_shell_controller.dart';
import '../../controllers/member_management_controller.dart';
import '../../models/index.dart';
import '../../models/member_voucher.dart';
import '../../utils/utils.dart';

/// Membuka layar transaksi gym dalam mode perpanjangan untuk [member].
/// Pembayaran di sana otomatis tercatat sebagai transaksi gym + perpanjangan.
void openRenewalFlow(Member member) {
  // Tutup layar yang menumpuk (mis. detail member) DULU, supaya controller
  // terdaftar pada shell yang persisten — bukan pada route yang langsung ditutup
  // (kalau tidak, GetX membuang controllernya -> "GymTransactionController not
  // found"). Lalu siapkan perpanjangan dan pindah ke TAB Gym (navbar tetap).
  Get.until((route) => route.isFirst);
  final gym = Get.isRegistered<GymTransactionController>()
      ? Get.find<GymTransactionController>()
      : Get.put(GymTransactionController());
  gym.startRenewal(member);
  if (Get.isRegistered<KasirShellController>()) {
    Get.find<KasirShellController>().goTo(KasirTab.gym);
  }
}

const Color _background = Color(0xFFF5F7FB);
const Color _surface = Colors.white;
const Color _text = Color(0xFF111827);
const Color _muted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _accent = Color(0xFF1D4ED8);
const Color _softAccent = Color(0xFFE8F4FF);
const Color _success = Color(0xFF15803D);
const Color _warning = Color(0xFFD97706);
const Color _danger = Color(0xFFB91C1C);

/// Detail member untuk kasir, data dari backend (sama konsep dengan admin):
/// info pribadi, status membership, riwayat perpanjangan, voucher, follow-up.
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.controller,
  });

  final Member member;
  final MemberManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF071A3D),
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Member',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: Obx(() {
        // Selalu pakai versi terbaru dari controller (mis. setelah perpanjang).
        final data = controller.memberById(member.id) ?? member;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _buildHeaderCard(data),
            const SizedBox(height: 14),
            if (MemberManagementController.canRenew(data))
              _buildRenewButton(data)
            else
              _buildReregisterNote(),
            const SizedBox(height: 14),
            _buildInfoSection(data),
            const SizedBox(height: 14),
            _buildRenewalSection(data),
            const SizedBox(height: 14),
            _buildVoucherSection(data),
            const SizedBox(height: 14),
            _buildFollowUpSection(data),
          ],
        );
      }),
    );
  }

  // --------------------------------------------------------------------------
  Widget _buildHeaderCard(Member member) {
    final isExpired = MemberManagementController.isExpired(member);
    final isRenewalDue = MemberManagementController.isRenewalDue(member);
    final statusText = isExpired
        ? 'Kadaluwarsa'
        : isRenewalDue
        ? 'Perlu Perpanjangan'
        : 'Aktif';
    final statusColor = isExpired
        ? _danger
        : isRenewalDue
        ? _warning
        : _success;
    final statusTextColor = isExpired
        ? const Color(0xFFFCA5A5)
        : isRenewalDue
        ? const Color(0xFFFCD34D)
        : const Color(0xFF86EFAC);
    final daysText = isExpired
        ? 'Berakhir ${member.daysUntilExpiry.abs()} hari lalu'
        : 'Sisa ${member.daysUntilExpiry} hari';
    final initial = member.name.trim().isEmpty
        ? 'M'
        : member.name.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.memberId,
                      style: const TextStyle(
                        color: Color(0xFFCFE0F5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  'Paket',
                  controller.packageName(member.gymPackageId),
                  Icons.card_membership_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerStat(
                  'Masa berlaku',
                  DateTimeUtils.formatDate(member.membershipExpiryDate),
                  Icons.event_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            daysText,
            style: const TextStyle(
              color: Color(0xFFE8F4FF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC857), size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFBFD3EC),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewButton(Member member) {
    // Hanya bisa diperpanjang mulai H-7 sebelum masa paket berakhir.
    final canRenewNow = MemberManagementController.isRenewalDue(member);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canRenewNow ? () => openRenewalFlow(member) : null,
        icon: const Icon(Icons.autorenew_rounded, size: 19),
        label: Text(
          canRenewNow
              ? 'Perpanjang Membership'
              : 'Perpanjang tersedia mulai H-7',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildReregisterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _danger.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _danger, size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Membership sudah habis. Member harus daftar/bayar ulang — '
              'tidak bisa diperpanjang.',
              style: TextStyle(
                color: _danger,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  Widget _buildInfoSection(Member member) {
    return _panel(
      title: 'Informasi Member',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          _infoRow(Icons.email_rounded, 'Email', member.email),
          _infoRow(Icons.phone_rounded, 'Telepon', member.phoneNumber),
          _infoRow(Icons.location_on_rounded, 'Alamat', member.address),
          _infoRow(Icons.wc_rounded, 'Gender', _genderLabel(member.gender)),
          _infoRow(
            Icons.cake_rounded,
            'Tgl Lahir',
            DateTimeUtils.formatDate(member.dateOfBirth),
          ),
          _infoRow(
            Icons.event_available_rounded,
            'Tgl Daftar',
            DateTimeUtils.formatDate(member.registrationDate),
          ),
          _infoRow(
            Icons.directions_run_rounded,
            'Total Kunjungan',
            '${member.totalVisits}x',
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalSection(Member member) {
    final renewals = member.renewals;
    // Baseline pendaftaran awal selalu ditampilkan paling bawah, sehingga
    // walau belum pernah perpanjang, paket awalnya tetap terlihat.
    return _panel(
      title: 'Riwayat Membership',
      icon: Icons.autorenew_rounded,
      trailing: '${renewals.length + 1}',
      child: Column(
        children: [
          for (final r in renewals)
            _timelineTile(
              title: r.packageName.isEmpty ? r.packageCode : r.packageName,
              subtitle:
                  '${r.previousExpiryDate == null ? '-' : DateTimeUtils.formatDate(r.previousExpiryDate!)}'
                  ' → ${DateTimeUtils.formatDate(r.newExpiryDate)}',
              trailing: CurrencyUtils.formatCurrency(r.amount),
              date: DateTimeUtils.formatDate(r.renewedAt),
            ),
          _timelineTile(
            title: controller.packageName(member.initialPackageId),
            subtitle: renewals.isEmpty
                ? 'Paket pendaftaran awal (belum pernah diperpanjang)'
                : 'Paket pendaftaran awal',
            trailing: 'Daftar',
            trailingColor: _success,
            date: DateTimeUtils.formatDate(member.registrationDate),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection(Member member) {
    final vouchers = memberVoucherStatuses(member);
    final activeCount = vouchers.where((v) => v.available).length;
    return _panel(
      title: 'Voucher F&B',
      icon: Icons.confirmation_number_rounded,
      trailing: activeCount > 0 ? '$activeCount aktif' : '${vouchers.length}',
      child: vouchers.isEmpty
          ? _emptyHint('Belum ada voucher (butuh $kVisitsPerVoucher kunjungan).')
          : Column(
              children: [
                for (final v in vouchers) _buildVoucherTile(member, v),
              ],
            ),
    );
  }

  Widget _buildVoucherTile(Member member, MemberVoucherStatus v) {
    final label = switch (v.status) {
      'used' => 'Dipakai',
      'expired' => 'Hangus',
      _ => 'Aktif',
    };
    final color = switch (v.status) {
      'used' => _muted,
      'expired' => _danger,
      _ => _success,
    };
    final bg = switch (v.status) {
      'used' => const Color(0xFFF1F5F9),
      'expired' => const Color(0xFFFBEAEA),
      _ => const Color(0xFFE7F6EC),
    };
    final subtitle = switch (v.status) {
      'used' =>
        'Ditukar ${v.usedAt == null ? '-' : DateTimeUtils.formatDate(v.usedAt!)}',
      'expired' => 'Hangus sejak ${DateTimeUtils.formatDate(v.expiresAt)}',
      _ =>
        'Berlaku s/d ${DateTimeUtils.formatDate(v.expiresAt)} • '
            '${v.daysUntilExpiry < 0 ? 0 : v.daysUntilExpiry} hari lagi',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${v.percent}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diskon ${v.percent}% • ${v.visits} kunjungan',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (v.available)
            FilledButton(
              onPressed: () => _confirmRedeem(member, v),
              style: FilledButton.styleFrom(
                backgroundColor: _success,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Pakai'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRedeem(Member member, MemberVoucherStatus v) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Pakai Voucher'),
        content: Text(
          'Pakai voucher diskon ${v.percent}% F&B untuk ${member.name}? '
          'Anda akan diarahkan ke transaksi F&B; voucher tercatat DIPAKAI '
          'setelah pembayaran selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _success),
            onPressed: () => Get.back(result: true),
            child: const Text('Lanjut ke F&B'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // Tutup detail DULU agar controller terdaftar pada shell yang persisten,
    // lalu pasang diskon voucher dan pindah ke TAB F&B (navbar tetap ada).
    Get.until((route) => route.isFirst);
    final fnb = Get.isRegistered<FoodBeverageTransactionController>()
        ? Get.find<FoodBeverageTransactionController>()
        : Get.put(FoodBeverageTransactionController());
    fnb.applyVoucher(member, v.visits, v.percent);
    if (Get.isRegistered<KasirShellController>()) {
      Get.find<KasirShellController>().goTo(KasirTab.fnb);
    }
  }

  Widget _buildFollowUpSection(Member member) {
    final followUps = member.followUps;
    return _panel(
      title: 'Riwayat Follow-up',
      icon: Icons.mark_email_read_rounded,
      trailing: '${followUps.length}',
      child: followUps.isEmpty
          ? _emptyHint('Belum ada follow-up.')
          : Column(
              children: [
                for (final f in followUps)
                  _timelineTile(
                    title: f.subject.isEmpty ? f.type : f.subject,
                    subtitle: f.recipientEmail,
                    trailing: f.type,
                    date: DateTimeUtils.formatDate(f.sentAt),
                  ),
              ],
            ),
    );
  }

  // --------------------------------------------------------------------------
  Widget _panel({
    required String title,
    required IconData icon,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _softAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _softAccent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _muted, size: 17),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: const TextStyle(
                color: _text,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineTile({
    required String title,
    required String subtitle,
    required String trailing,
    required String date,
    Color? trailingColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: TextStyle(
              color: trailingColor ?? _accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _genderLabel(String gender) {
    switch (gender.trim().toLowerCase()) {
      case 'male':
      case 'l':
      case 'laki-laki':
      case 'pria':
        return 'Laki-laki';
      case 'female':
      case 'p':
      case 'perempuan':
      case 'wanita':
        return 'Perempuan';
      default:
        return gender.trim().isEmpty ? '-' : gender;
    }
  }
}
