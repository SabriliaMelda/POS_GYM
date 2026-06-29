import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_management_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';
import 'member_detail_screen.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _accent = Color(0xFF1D4ED8);
  static const Color _softAccent = Color(0xFFE8F4FF);
  static const Color _success = Color(0xFF15803D);
  static const Color _warning = Color(0xFFD97706);
  static const Color _danger = Color(0xFFB91C1C);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberManagementController());

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const LoadingWidget(message: 'Memuat data member...')
              : Column(
                  children: [
                    // Bagian atas tetap (tidak ikut scroll).
                    _buildHeader(controller),
                    _buildSearchBar(controller),
                    _buildFilterChips(controller),
                    // Hanya daftar member yang menggulir.
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.loadMembers(),
                        child: controller.filteredMembers.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 60),
                                  EmptyStateWidget(
                                    title: 'Member Tidak Ditemukan',
                                    subtitle:
                                        'Data member akan muncul setelah scan QR dan pembayaran berhasil',
                                    icon: Icons.person_search_rounded,
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                                itemCount: controller.filteredMembers.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final member =
                                      controller.filteredMembers[index];
                                  return _buildMemberCard(member, controller);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(MemberManagementController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Member',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.filteredMembers.length} dari '
                  '${controller.members.length} member ditampilkan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE8F4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => controller.loadMembers(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF071A3D),
              backgroundColor: const Color(0xFFFFC857),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MemberManagementController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        onChanged: (query) => controller.searchMembers(query),
        decoration: InputDecoration(
          hintText: 'Cari nama, ID, atau nomor telepon',
          hintStyle: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: _muted),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MemberManagementController controller) {
    const items = [
      (MemberFilter.all, 'Semua', Icons.groups_rounded),
      (MemberFilter.active, 'Aktif', Icons.verified_user_rounded),
      (MemberFilter.renewalDue, 'Perlu Perpanjangan', Icons.autorenew_rounded),
      (MemberFilter.expired, 'Kadaluwarsa', Icons.event_busy_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (filter, label, icon) in items) ...[
              _buildFilterChip(
                controller: controller,
                filter: filter,
                label: label,
                icon: icon,
                count: controller.countFor(filter),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required MemberManagementController controller,
    required MemberFilter filter,
    required String label,
    required IconData icon,
    required int count,
  }) {
    final selected = controller.memberFilter.value == filter;
    final color = switch (filter) {
      MemberFilter.expired => _danger,
      MemberFilter.renewalDue => _warning,
      MemberFilter.active => _success,
      MemberFilter.all => _accent,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => controller.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : _surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : _border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? color : _muted),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                color: selected ? color : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    Member member,
    MemberManagementController controller,
  ) {
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
    final daysText = isExpired
        ? 'Berakhir ${member.daysUntilExpiry.abs()} hari lalu'
        : 'Sisa ${member.daysUntilExpiry} hari';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.to(
        () => MemberDetailScreen(member: member, controller: controller),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(member),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(statusText, statusColor),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildInfoChip(Icons.badge_rounded, member.memberId),
                          _buildInfoChip(
                            Icons.card_membership_rounded,
                            controller.packageName(member.gymPackageId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailLine(
                          Icons.phone_rounded,
                          member.phoneNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailLine(
                          Icons.calendar_month_rounded,
                          daysText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailLine(
                          Icons.location_on_rounded,
                          member.address,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailLine(
                          Icons.event_available_rounded,
                          'Daftar ${DateTimeUtils.formatDate(member.registrationDate)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (MemberManagementController.canRenew(member))
              Align(
                alignment: Alignment.centerRight,
                child: _buildRenewButton(member, controller),
              )
            else
              _buildReregisterNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildReregisterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _danger.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _danger, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Membership habis — harus daftar/bayar ulang, tidak bisa diperpanjang.',
              style: TextStyle(
                color: _danger,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Member member) {
    final initial = member.name.trim().isEmpty
        ? 'M'
        : member.name.trim()[0].toUpperCase();

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: _accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _muted, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRenewButton(
    Member member,
    MemberManagementController controller,
  ) {
    // Hanya bisa diperpanjang mulai H-7 sebelum masa paket berakhir.
    final canRenewNow = MemberManagementController.isRenewalDue(member);
    return FilledButton.tonalIcon(
      onPressed: canRenewNow ? () => openRenewalFlow(member) : null,
      icon: const Icon(Icons.autorenew_rounded, size: 18),
      label: Text(canRenewNow ? 'Perpanjang' : 'Perpanjang (mulai H-7)'),
      style: FilledButton.styleFrom(
        backgroundColor: _softAccent,
        foregroundColor: _accent,
        disabledBackgroundColor: const Color(0xFFEEF1F5),
        disabledForegroundColor: const Color(0xFF94A3B8),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}
