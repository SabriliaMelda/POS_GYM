import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode/barcode.dart';

import '../../controllers/attendance_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AttendanceView();
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  static const _background = Color(0xFFF5F7FB);
  static const _surface = Colors.white;
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _primary = Color(0xFF1D4ED8);
  static const _navy = Color(0xFF071A3D);
  static const _softBlue = Color(0xFFE8F4FF);

  late final AttendanceController _controller;
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
            ),
          ),
        ),
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Absensi Member',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Pilih member dan tampilkan barcode absensi',
              style: TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _controller.loadAttendance();
              _controller.loadTodayAttendance();
            },
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final records = _controller.todayAttendance.toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final terminal = _buildAccessTerminal();
            final attendance = _buildAttendancePanel(records);

            return RefreshIndicator(
              onRefresh: _controller.loadTodayAttendance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  children: [
                    _buildStatusHero(records.length),
                    const SizedBox(height: 14),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: terminal),
                          const SizedBox(width: 14),
                          Expanded(flex: 5, child: attendance),
                        ],
                      )
                    else ...[
                      terminal,
                      const SizedBox(height: 14),
                      attendance,
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusHero(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode absensi siap digunakan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Cari member, tampilkan barcode, lalu scan menggunakan ponsel untuk membuka halaman konfirmasi absensi.',
                  style: TextStyle(
                    color: Color(0xFFC8DDF2),
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildHeroMetric(
            'Absensi hari ini',
            '$total',
            Icons.how_to_reg_rounded,
          ),
          _buildHeroMetric(
            'Status absensi',
            'Aktif',
            Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value, IconData icon) {
    return Container(
      width: 142,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC857), size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFC8DDF2),
                    fontSize: 9,
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

  Widget _buildAccessTerminal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Member',
            style: TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Cari berdasarkan nama, ID member, atau nomor telepon.',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Autocomplete<Member>(
            displayStringForOption: (member) =>
                '${member.name} (${member.memberId})',
            optionsBuilder: (value) {
              final query = value.text.trim().toLowerCase();
              if (query.isEmpty) return const Iterable<Member>.empty();
              return _controller.members.where(
                (member) =>
                    member.name.toLowerCase().contains(query) ||
                    member.memberId.toLowerCase().contains(query) ||
                    member.phoneNumber.contains(query),
              );
            },
            onSelected: (member) => setState(() => _selectedMember = member),
            fieldViewBuilder: (context, textController, focusNode, _) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Pilih atau cari member',
                  hintText: 'Contoh: Andi atau MBR-58310427',
                  prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                  suffixIcon: _selectedMember == null
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pilihan',
                          onPressed: () {
                            textController.clear();
                            setState(() => _selectedMember = null);
                            focusNode.requestFocus();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_selectedMember == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_2_rounded, color: _muted, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Barcode muncul setelah member dipilih',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildMemberBarcode(_selectedMember!),
        ],
      ),
    );
  }

  Widget _buildMemberBarcode(Member member) {
    final attendanceUrl = _attendanceUrl(member.memberId);
    final active = member.isActive && !member.isExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Text(
            member.name,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            member.memberId,
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          if (active)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: CustomPaint(
                size: const Size.square(210),
                painter: _BarcodePainter(attendanceUrl),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Icon(Icons.block_rounded, color: Color(0xFFB91C1C), size: 44),
                  SizedBox(height: 8),
                  Text(
                    'Membership tidak aktif',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            active
                ? 'Scan barcode, buka tautan di browser, lalu klik Absen Sekarang.'
                : 'Perpanjang membership sebelum melakukan absensi.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 10, height: 1.35),
          ),
        ],
      ),
    );
  }

  String _attendanceUrl(String memberId) {
    const configuredBase = String.fromEnvironment('ATTENDANCE_BASE_URL');
    final base = configuredBase.isNotEmpty
        ? configuredBase
        : Uri.base.replace(query: null, fragment: '').toString();
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    return '$normalizedBase#/member-check-in?member=${Uri.encodeQueryComponent(memberId)}';
  }

  Widget _buildAttendancePanel(List<Attendance> records) {
    return Container(
      height: 620,
      decoration: _panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kehadiran Hari Ini',
                        style: TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Nama, tanggal, dan jam kehadiran member',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${records.length} hadir',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          if (records.isEmpty)
            const Expanded(
              child: EmptyStateWidget(
                title: 'Belum Ada Absensi',
                subtitle: 'Aktivitas akses hari ini akan muncul di sini',
                icon: Icons.people_outline_rounded,
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: records.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: _border),
                itemBuilder: (context, index) =>
                    _buildAttendanceRow(records[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(Attendance attendance) {
    final method = _accessMethod(attendance);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: method.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(method.icon, color: method.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.memberName ?? 'Member Tidak Diketahui',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${method.label} | ${_formatDate(attendance.attendanceDate)} | ${attendance.checkInTime ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'HADIR',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14071A3D),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  ({String label, IconData icon, Color color}) _accessMethod(
    Attendance attendance,
  ) {
    final credential = attendance.rfidCardNumber ?? '';
    if (credential.startsWith('BARCODE:')) {
      return (
        label: 'Barcode',
        icon: Icons.qr_code_2_rounded,
        color: const Color(0xFF7C3AED),
      );
    }
    if (credential.startsWith('DAILY:')) {
      return (
        label: 'Kasir / Daily Pass',
        icon: Icons.door_front_door_outlined,
        color: const Color(0xFFB7791F),
      );
    }
    return (label: 'RFID', icon: Icons.contactless_rounded, color: _primary);
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final elements = Barcode.qrCode().make(
      data,
      width: size.width,
      height: size.height,
    );
    final paint = Paint()..color = Colors.black;
    for (final element in elements) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
