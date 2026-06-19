import 'package:flutter/material.dart';

import '../../../kasir/models/member.dart';
import '../../../kasir/services/mock_data_service.dart';

enum _MemberFilter { all, active, renewalDue, expired, inactive }

class AdminMemberScreen extends StatefulWidget {
  const AdminMemberScreen({super.key});

  static const Color _background = Color(0xFFF4F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _navy = Color(0xFF071A3D);
  static const Color _green = Color(0xFF047857);
  static const Color _amber = Color(0xFFB45309);
  static const Color _red = Color(0xFFB91C1C);

  @override
  State<AdminMemberScreen> createState() => _AdminMemberScreenState();
}

class _AdminMemberScreenState extends State<AdminMemberScreen> {
  final MockDataService _service = MockDataService.instance;
  final TextEditingController _searchController = TextEditingController();
  _MemberFilter _selectedFilter = _MemberFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = List<Member>.from(
      _service.members,
    )..sort((a, b) => a.membershipExpiryDate.compareTo(b.membershipExpiryDate));
    final activeMembers = members.where(_isActiveMember).toList();
    final renewalDueMembers = members.where(_isRenewalDueMember).toList();
    final expiredMembers = members.where((member) => member.isExpired).toList();
    final inactiveMembers = members
        .where((member) => !member.isActive)
        .toList();
    final monitoringMembers = [
      ...expiredMembers,
      ...renewalDueMembers.where((member) => !member.isExpired),
    ];
    final filteredMembers = _filteredMembers(members);

    return Scaffold(
      backgroundColor: AdminMemberScreen._background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AdminHeader(
                    title: 'Kelola Member',
                    subtitle:
                        'Pantau data member hasil form pendaftaran dan kelola daftar member.',
                    icon: Icons.groups_rounded,
                  ),
                  const SizedBox(height: 14),
                  _SummaryGrid(
                    isWide: isWide,
                    items: [
                      _SummaryItem(
                        title: 'Total Member',
                        value: members.length.toString(),
                        icon: Icons.badge_rounded,
                      ),
                      _SummaryItem(
                        title: 'Member Aktif',
                        value: activeMembers.length.toString(),
                        icon: Icons.verified_user_rounded,
                      ),
                      _SummaryItem(
                        title: 'Perlu Perpanjangan',
                        value: renewalDueMembers.length.toString(),
                        icon: Icons.event_busy_rounded,
                      ),
                      _SummaryItem(
                        title: 'Kadaluwarsa',
                        value: expiredMembers.length.toString(),
                        icon: Icons.person_off_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _RenewalMonitorPanel(
                    members: monitoringMembers.take(4).toList(),
                    totalCount: monitoringMembers.length,
                    onShowRenewalDue: () {
                      setState(
                        () => _selectedFilter = _MemberFilter.renewalDue,
                      );
                    },
                    onShowExpired: () {
                      setState(() => _selectedFilter = _MemberFilter.expired);
                    },
                    onFollowUp: _showFollowUpNotificationDialog,
                  ),
                  const SizedBox(height: 14),
                  _MemberToolbar(
                    searchController: _searchController,
                    selectedFilter: _selectedFilter,
                    counts: {
                      _MemberFilter.all: members.length,
                      _MemberFilter.active: activeMembers.length,
                      _MemberFilter.renewalDue: renewalDueMembers.length,
                      _MemberFilter.expired: expiredMembers.length,
                      _MemberFilter.inactive: inactiveMembers.length,
                    },
                    onSearchChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onFilterChanged: (filter) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                  const SizedBox(height: 14),
                  _Panel(
                    title: 'Daftar Member',
                    helper:
                        '${filteredMembers.length} data ditampilkan dari ${members.length} member.',
                    child: filteredMembers.isEmpty
                        ? const _EmptyMemberState()
                        : Column(
                            children: [
                              if (isWide) const _MemberListHeader(),
                              ...filteredMembers.map((member) {
                                return _MemberRowTile(
                                  member: member,
                                  packageName: _packageName(
                                    member.gymPackageId,
                                  ),
                                  isWide: isWide,
                                  onOpenDetail: () =>
                                      _openMemberDetailPage(member),
                                  onDelete: () => _confirmDeleteMember(member),
                                );
                              }),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Member> _filteredMembers(List<Member> members) {
    final query = _searchQuery.trim().toLowerCase();
    return members.where((member) {
      final matchesFilter = switch (_selectedFilter) {
        _MemberFilter.all => true,
        _MemberFilter.active => _isActiveMember(member),
        _MemberFilter.renewalDue => _isRenewalDueMember(member),
        _MemberFilter.expired => member.isExpired,
        _MemberFilter.inactive => !member.isActive,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      return member.name.toLowerCase().contains(query) ||
          member.memberId.toLowerCase().contains(query) ||
          member.phoneNumber.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query);
    }).toList();
  }

  bool _isActiveMember(Member member) {
    return member.isActive && !member.isExpired;
  }

  bool _isRenewalDueMember(Member member) {
    return _isActiveMember(member) && member.daysUntilExpiry <= 7;
  }

  String _packageName(String packageId) {
    for (final package in _service.gymPackages) {
      if (package.packageId == packageId) return package.name;
    }
    return packageId;
  }

  void _openMemberDetailPage(Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AdminMemberDetailPage(
          member: member,
          packageName: _packageName(member.gymPackageId),
        ),
      ),
    );
  }

  Future<void> _showFollowUpNotificationDialog(Member member) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Follow-up Member'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogInfoRow(label: 'Member', value: member.name),
                  _DialogInfoRow(label: 'Email', value: member.email),
                  _DialogInfoRow(
                    label: 'Masa aktif',
                    value: _formatDate(member.membershipExpiryDate),
                  ),
                  const SizedBox(height: 14),
                  _GmailPreviewCard(
                    recipient: member.email,
                    subject: _followUpNotificationSubject(member),
                    message: _followUpNotificationMessage(member),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.mark_email_read_rounded),
              label: const Text('Kirim Follow-up'),
            ),
          ],
        );
      },
    );

    if (sent == true && mounted) {
      _showSnackBar(
        'Notifikasi Gmail follow-up disiapkan untuk ${member.email}.',
      );
    }
  }

  Future<void> _confirmDeleteMember(Member member) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Member'),
          content: Text(
            'Hapus data ${member.name}? Tindakan ini menghapus member dari daftar pengelolaan admin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AdminMemberScreen._red,
              ),
              onPressed: () {
                final id = member.id;
                if (id != null) _service.deleteMember(id);
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (deleted == true && mounted) {
      setState(() {});
      _showSnackBar('Data member berhasil dihapus.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminMemberScreen._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMemberDetailPage extends StatelessWidget {
  const _AdminMemberDetailPage({
    required this.member,
    required this.packageName,
  });

  final Member member;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    final status = _memberStatus(member);
    final statusColor = status.color;

    return Scaffold(
      backgroundColor: AdminMemberScreen._background,
      appBar: AppBar(
        title: const Text('Data Member'),
        backgroundColor: AdminMemberScreen._surface,
        foregroundColor: AdminMemberScreen._text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MemberProfileHero(
                member: member,
                packageName: packageName,
                status: status,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final cards = [
                    _DetailMetricCard(
                      icon: Icons.event_available_rounded,
                      label: 'Masa Aktif',
                      value: _expiryDetail(member),
                      color: statusColor,
                    ),
                    _DetailMetricCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Paket',
                      value: packageName,
                      color: AdminMemberScreen._navy,
                    ),
                    _DetailMetricCard(
                      icon: Icons.app_registration_rounded,
                      label: 'Tanggal Daftar',
                      value: _formatDate(member.registrationDate),
                      color: const Color(0xFF2563EB),
                    ),
                  ];

                  return GridView.builder(
                    itemCount: cards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 84,
                    ),
                    itemBuilder: (context, index) => cards[index],
                  );
                },
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  final sections = [
                    _DetailSection(
                      title: 'Informasi Kontak',
                      accentColor: const Color(0xFF2563EB),
                      children: [
                        _DetailInfoTile(
                          icon: Icons.mail_rounded,
                          label: 'Email',
                          value: member.email,
                          color: const Color(0xFF2563EB),
                        ),
                        _DetailInfoTile(
                          icon: Icons.call_rounded,
                          label: 'Nomor HP',
                          value: member.phoneNumber,
                          color: const Color(0xFF0F766E),
                        ),
                        _DetailInfoTile(
                          icon: Icons.home_rounded,
                          label: 'Alamat Rumah',
                          value: member.address,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: 'Data Pribadi',
                      accentColor: const Color(0xFF7C3AED),
                      children: [
                        _DetailInfoTile(
                          icon: Icons.badge_rounded,
                          label: 'ID Member',
                          value: member.memberId,
                          color: const Color(0xFF7C3AED),
                        ),
                        _DetailInfoTile(
                          icon: Icons.wc_rounded,
                          label: 'Jenis Kelamin',
                          value: _genderLabel(member.gender),
                          color: const Color(0xFFBE185D),
                        ),
                        _DetailInfoTile(
                          icon: Icons.cake_rounded,
                          label: 'Tanggal Lahir',
                          value: _formatDate(member.dateOfBirth),
                          color: const Color(0xFFB45309),
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: 'Membership',
                      accentColor: statusColor,
                      children: [
                        _DetailInfoTile(
                          icon: Icons.fitness_center_rounded,
                          label: 'Paket Gym',
                          value: packageName,
                          color: AdminMemberScreen._navy,
                        ),
                        _DetailInfoTile(
                          icon: Icons.event_available_rounded,
                          label: 'Masa Aktif Sampai',
                          value:
                              '${_formatDate(member.membershipExpiryDate)} (${_expiryDetail(member)})',
                          color: statusColor,
                        ),
                        _DetailInfoTile(
                          icon: status.icon,
                          label: 'Status',
                          value: status.label,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ];

                  if (!isWide) {
                    return Column(
                      children: [
                        for (final section in sections) ...[
                          section,
                          if (section != sections.last)
                            const SizedBox(height: 12),
                        ],
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sections[0]),
                          const SizedBox(width: 12),
                          Expanded(child: sections[1]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      sections[2],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberProfileHero extends StatelessWidget {
  const _MemberProfileHero({
    required this.member,
    required this.packageName,
    required this.status,
  });

  final Member member;
  final String packageName;
  final _MemberStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminMemberScreen._navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._navy),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final identity = Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                foregroundColor: Colors.white,
                child: Text(
                  member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${member.memberId} - $packageName',
                      style: const TextStyle(
                        color: Color(0xFFDCEBFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 12),
                _StatusPill(status: status),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 12),
              _StatusPill(status: status),
            ],
          );
        },
      ),
    );
  }
}

class _DetailMetricCard extends StatelessWidget {
  const _DetailMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminMemberScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminMemberScreen._muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
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
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.accentColor,
    required this.children,
  });

  final String title;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminMemberScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AdminMemberScreen._text,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailInfoTile extends StatelessWidget {
  const _DetailInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminMemberScreen._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items, required this.isWide});

  final List<_SummaryItem> items;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 86,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminMemberScreen._surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminMemberScreen._border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AdminMemberScreen._navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: AdminMemberScreen._navy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  color: AdminMemberScreen._text,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RenewalMonitorPanel extends StatelessWidget {
  const _RenewalMonitorPanel({
    required this.members,
    required this.totalCount,
    required this.onShowRenewalDue,
    required this.onShowExpired,
    required this.onFollowUp,
  });

  final List<Member> members;
  final int totalCount;
  final VoidCallback onShowRenewalDue;
  final VoidCallback onShowExpired;
  final ValueChanged<Member> onFollowUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminMemberScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final title = Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AdminMemberScreen._amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AdminMemberScreen._amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pantauan Perpanjangan',
                          style: TextStyle(
                            color: AdminMemberScreen._text,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          totalCount == 0
                              ? 'Tidak ada member yang perlu ditindaklanjuti.'
                              : '$totalCount member perlu dipantau admin.',
                          style: const TextStyle(
                            color: AdminMemberScreen._muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onShowRenewalDue,
                    icon: const Icon(Icons.event_busy_rounded, size: 18),
                    label: const Text('Hampir Habis'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShowExpired,
                    icon: const Icon(Icons.person_off_rounded, size: 18),
                    label: const Text('Kadaluwarsa'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 10), actions],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: members.map((member) {
                    return SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 10) / 2
                          : constraints.maxWidth,
                      child: _MonitorMemberTile(
                        member: member,
                        onFollowUp: () => onFollowUp(member),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MonitorMemberTile extends StatelessWidget {
  const _MonitorMemberTile({required this.member, required this.onFollowUp});

  final Member member;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context) {
    final status = _memberStatus(member);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          _StatusDot(color: status.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${member.memberId} - ${_formatDate(member.membershipExpiryDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminMemberScreen._muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onFollowUp,
            icon: const Icon(Icons.mark_email_read_rounded, size: 17),
            label: const Text('Follow-up'),
          ),
        ],
      ),
    );
  }
}

class _MemberToolbar extends StatelessWidget {
  const _MemberToolbar({
    required this.searchController,
    required this.selectedFilter,
    required this.counts,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final _MemberFilter selectedFilter;
  final Map<_MemberFilter, int> counts;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_MemberFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminMemberScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama, ID member, email, atau nomor telepon',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Bersihkan pencarian',
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminMemberScreen._border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminMemberScreen._border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _MemberFilter.values.map((filter) {
              return ChoiceChip(
                selected: selectedFilter == filter,
                onSelected: (_) => onFilterChanged(filter),
                avatar: Icon(_filterIcon(filter), size: 16),
                label: Text('${_filterLabel(filter)} (${counts[filter] ?? 0})'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _filterLabel(_MemberFilter filter) {
    return switch (filter) {
      _MemberFilter.all => 'Semua',
      _MemberFilter.active => 'Aktif',
      _MemberFilter.renewalDue => 'Perlu Perpanjangan',
      _MemberFilter.expired => 'Kadaluwarsa',
      _MemberFilter.inactive => 'Nonaktif',
    };
  }

  IconData _filterIcon(_MemberFilter filter) {
    return switch (filter) {
      _MemberFilter.all => Icons.list_alt_rounded,
      _MemberFilter.active => Icons.verified_user_rounded,
      _MemberFilter.renewalDue => Icons.event_busy_rounded,
      _MemberFilter.expired => Icons.person_off_rounded,
      _MemberFilter.inactive => Icons.block_rounded,
    };
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.helper,
    required this.child,
  });

  final String title;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminMemberScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  helper,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AdminMemberScreen._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
}

class _MemberRowTile extends StatelessWidget {
  const _MemberRowTile({
    required this.member,
    required this.packageName,
    required this.isWide,
    required this.onOpenDetail,
    required this.onDelete,
  });

  final Member member;
  final String packageName;
  final bool isWide;
  final VoidCallback onOpenDetail;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = _memberStatus(member);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onOpenDetail,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminMemberScreen._border),
            ),
            child: isWide
                ? Row(
                    children: [
                      Expanded(flex: 2, child: _MemberIdentity(member: member)),
                      Expanded(child: _MemberMeta(packageName: packageName)),
                      Expanded(child: _ExpiryMeta(member: member)),
                      SizedBox(width: 166, child: _StatusPill(status: status)),
                      SizedBox(
                        width: 72,
                        child: _MemberActions(onDelete: onDelete),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MemberIdentity(member: member),
                      const SizedBox(height: 10),
                      _MemberMeta(packageName: packageName),
                      const SizedBox(height: 8),
                      _ExpiryMeta(member: member),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatusPill(status: status),
                          const Spacer(),
                          _MemberActions(onDelete: onDelete),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MemberListHeader extends StatelessWidget {
  const _MemberListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderText('Member')),
          Expanded(child: _HeaderText('Paket')),
          Expanded(child: _HeaderText('Masa Aktif')),
          SizedBox(width: 166, child: _HeaderText('Status')),
          SizedBox(width: 72, child: _HeaderText('Aksi')),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AdminMemberScreen._muted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MemberIdentity extends StatelessWidget {
  const _MemberIdentity({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AdminMemberScreen._navy.withValues(alpha: 0.1),
          foregroundColor: AdminMemberScreen._navy,
          child: Text(
            member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AdminMemberScreen._text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${member.memberId} - ${member.phoneNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AdminMemberScreen._muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberMeta extends StatelessWidget {
  const _MemberMeta({required this.packageName});

  final String packageName;

  @override
  Widget build(BuildContext context) {
    return _InlineMeta(
      icon: Icons.fitness_center_rounded,
      title: 'Paket',
      value: packageName,
    );
  }
}

class _ExpiryMeta extends StatelessWidget {
  const _ExpiryMeta({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final days = member.daysUntilExpiry;
    final dayLabel = member.isExpired
        ? 'Lewat ${days.abs()} hari'
        : days == 0
        ? 'Habis hari ini'
        : '$days hari lagi';

    return _InlineMeta(
      icon: Icons.event_available_rounded,
      title: 'Masa aktif',
      value: '${_formatDate(member.membershipExpiryDate)} - $dayLabel',
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AdminMemberScreen._muted, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AdminMemberScreen._muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AdminMemberScreen._text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _MemberStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MemberActions extends StatelessWidget {
  const _MemberActions({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        IconButton.filledTonal(
          tooltip: 'Hapus member',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_rounded),
        ),
      ],
    );
  }
}

class _GmailPreviewCard extends StatelessWidget {
  const _GmailPreviewCard({
    required this.recipient,
    required this.subject,
    required this.message,
  });

  final String recipient;
  final String subject;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                color: AdminMemberScreen._navy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gmail ke $recipient',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminMemberScreen._text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          const Text(
            'Subjek',
            style: TextStyle(
              color: AdminMemberScreen._muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject,
            style: const TextStyle(
              color: AdminMemberScreen._text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pesan',
            style: TextStyle(
              color: AdminMemberScreen._muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              color: AdminMemberScreen._text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  const _DialogInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                color: AdminMemberScreen._muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AdminMemberScreen._text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMemberState extends StatelessWidget {
  const _EmptyMemberState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMemberScreen._border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AdminMemberScreen._muted,
            size: 34,
          ),
          SizedBox(height: 8),
          Text(
            'Tidak ada member sesuai filter.',
            style: TextStyle(
              color: AdminMemberScreen._text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _MemberStatus {
  const _MemberStatus({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_MemberStatus _memberStatus(Member member) {
  if (!member.isActive) {
    return const _MemberStatus(
      label: 'Nonaktif',
      icon: Icons.block_rounded,
      color: AdminMemberScreen._red,
    );
  }
  if (member.isExpired) {
    return const _MemberStatus(
      label: 'Kadaluwarsa',
      icon: Icons.person_off_rounded,
      color: AdminMemberScreen._red,
    );
  }
  if (member.daysUntilExpiry <= 7) {
    return const _MemberStatus(
      label: 'Perlu Perpanjangan',
      icon: Icons.event_busy_rounded,
      color: AdminMemberScreen._amber,
    );
  }
  return const _MemberStatus(
    label: 'Aktif',
    icon: Icons.verified_user_rounded,
    color: AdminMemberScreen._green,
  );
}

String _followUpNotificationSubject(Member member) {
  if (member.isExpired || !member.isActive) {
    return 'Informasi Aktivasi Ulang Membership X-FIT';
  }
  return 'Pengingat Perpanjangan Membership X-FIT';
}

String _followUpNotificationMessage(Member member) {
  if (member.isExpired || !member.isActive) {
    return 'Halo ${member.name}, masa aktif membership X-FIT Anda telah kadaluwarsa sejak ${_formatDate(member.membershipExpiryDate)}. Untuk mengaktifkan kembali membership, silakan melakukan pembayaran perpanjangan di kasir gym. Karena status membership sudah kadaluwarsa, proses aktivasi ulang akan mengikuti biaya paket dan biaya admin yang berlaku.';
  }

  return 'Halo ${member.name}, masa aktif membership X-FIT Anda akan habis pada ${_formatDate(member.membershipExpiryDate)}. Silakan lakukan perpanjangan di kasir gym sebelum tanggal tersebut agar akses latihan tetap aktif.';
}

String _expiryDetail(Member member) {
  final days = member.daysUntilExpiry;
  if (member.isExpired) return 'lewat ${days.abs()} hari';
  if (days == 0) return 'habis hari ini';
  return '$days hari lagi';
}

String _genderLabel(String gender) {
  final normalized = gender.toLowerCase();
  if (normalized == 'male') return 'Laki-laki';
  if (normalized == 'female') return 'Perempuan';
  return gender;
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
