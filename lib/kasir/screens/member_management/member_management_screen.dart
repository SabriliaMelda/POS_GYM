import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_management_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

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
              : RefreshIndicator(
                  onRefresh: () => controller.loadMembers(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(controller)),
                      SliverToBoxAdapter(child: _buildSearchBar(controller)),
                      SliverToBoxAdapter(child: _buildSummary(controller)),
                      if (controller.filteredMembers.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            title: 'Member Tidak Ditemukan',
                            subtitle:
                                'Data member akan muncul setelah scan QR dan pembayaran berhasil',
                            icon: Icons.person_search_rounded,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          sliver: SliverList.separated(
                            itemCount: controller.filteredMembers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final member = controller.filteredMembers[index];
                              return _buildMemberCard(member, controller);
                            },
                          ),
                        ),
                    ],
                  ),
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

  Widget _buildSummary(MemberManagementController controller) {
    final total = controller.members.length;
    final active = controller.members
        .where((member) => member.isActive && !member.isExpired)
        .length;
    final expired = controller.members
        .where((member) => member.isExpired)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatTile(
              'Total',
              total.toString(),
              Icons.people_alt_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatTile(
              'Aktif',
              active.toString(),
              Icons.verified_user_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatTile(
              'Kedaluwarsa',
              expired.toString(),
              Icons.event_busy_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    Member member,
    MemberManagementController controller,
  ) {
    final isExpired = member.isExpired;
    final isActive = member.isActive && !isExpired;
    final statusText = isActive
        ? 'Aktif'
        : isExpired
        ? 'Kedaluwarsa'
        : 'Tidak Aktif';
    final statusColor = isActive ? _success : _danger;
    final daysText = isExpired
        ? 'Berakhir ${member.daysUntilExpiry.abs()} hari lalu'
        : 'Sisa ${member.daysUntilExpiry} hari';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.snackbar('Pratinjau UI', 'Detail member belum diaktifkan.');
      },
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
                            member.gymPackageId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                _buildActionMenu(member, controller),
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
          ],
        ),
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

  Widget _buildActionMenu(
    Member member,
    MemberManagementController controller,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Aksi member',
      icon: const Icon(Icons.more_horiz_rounded, color: _muted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          Get.snackbar('Pratinjau UI', 'Form edit member belum diaktifkan.');
        } else if (value == 'renew') {
          Get.snackbar(
            'Pratinjau UI',
            'Perpanjangan keanggotaan belum diaktifkan.',
          );
        } else if (value == 'delete') {
          _confirmDelete(member, controller);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'renew',
          child: Row(
            children: [
              Icon(Icons.autorenew_rounded, size: 18),
              SizedBox(width: 10),
              Text('Perpanjang'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18),
              SizedBox(width: 10),
              Text('Hapus'),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Member member, MemberManagementController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Member'),
        content: Text('Yakin ingin menghapus ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              controller.deleteMember(member.id ?? 0);
              Get.back();
            },
            style: FilledButton.styleFrom(backgroundColor: _danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
