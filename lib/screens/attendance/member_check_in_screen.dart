import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/attendance_controller.dart';
import '../../models/member.dart';

class MemberCheckInScreen extends StatefulWidget {
  const MemberCheckInScreen({super.key});

  @override
  State<MemberCheckInScreen> createState() => _MemberCheckInScreenState();
}

class _MemberCheckInScreenState extends State<MemberCheckInScreen> {
  late final AttendanceController _controller;
  Member? _member;
  bool _loading = true;
  bool _submitting = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
    final memberId =
        Get.parameters['member'] ?? Uri.base.queryParameters['member'];
    _member = _controller.members.firstWhereOrNull(
      (member) => member.memberId.toUpperCase() == memberId?.toUpperCase(),
    );
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final member = _member;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : member == null
                      ? _buildInvalidState()
                      : _buildMemberState(member),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvalidState() {
    return const Column(
      children: [
        Icon(Icons.link_off_rounded, color: Color(0xFFB91C1C), size: 56),
        SizedBox(height: 14),
        Text(
          'Tautan Absensi Tidak Valid',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8),
        Text(
          'Member tidak ditemukan. Silakan scan ulang barcode dari kasir.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMemberState(Member member) {
    final active = member.isActive && !member.isExpired;
    if (_success) {
      return Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF15803D),
            size: 72,
          ),
          const SizedBox(height: 14),
          const Text(
            'Absensi Berhasil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${member.name} sudah tercatat hadir hari ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Icon(
          Icons.fitness_center_rounded,
          color: Color(0xFF1D4ED8),
          size: 48,
        ),
        const SizedBox(height: 14),
        const Text(
          'Konfirmasi Absensi',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFFE8F4FF),
          child: Text(
            member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(member.memberId, style: const TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: !active || _submitting ? null : () => _checkIn(member),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1D4ED8),
            ),
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.how_to_reg_rounded),
            label: Text(
              active ? 'Absen Sekarang' : 'Membership Tidak Aktif',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkIn(Member member) async {
    setState(() => _submitting = true);
    final success = await _controller.processCredential(
      member.memberId,
      'barcode',
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _success = success;
    });
  }
}
