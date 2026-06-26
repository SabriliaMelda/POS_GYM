import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../admin/screens/master/admin_master_data_service.dart';

/// Halaman yang dibuka di HP member (di browser/Chrome) setelah memindai QR
/// absensi (`.../#/member-check-in?member=<member_code>`). Menampilkan nama
/// member, lalu member menekan tombol "Hadir Sekarang" untuk mencatat
/// kehadiran ke backend.
class MemberCheckInScreen extends StatefulWidget {
  const MemberCheckInScreen({super.key});

  @override
  State<MemberCheckInScreen> createState() => _MemberCheckInScreenState();
}

class _MemberCheckInScreenState extends State<MemberCheckInScreen> {
  final _repository = AdminMasterDataRepository();

  bool _loading = true; // memuat data member
  bool _submitting = false; // proses tekan "Hadir"
  String? _error;
  AttendanceMember? _member;
  AttendanceCheckIn? _result; // terisi setelah berhasil hadir

  String get _code =>
      (Get.parameters['member'] ?? Uri.base.queryParameters['member'] ?? '')
          .trim();

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    if (_code.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'Tautan absensi tidak valid. Silakan scan ulang barcode dari kasir.';
      });
      return;
    }
    try {
      final member = await _repository.lookupAttendanceMember(_code);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _member = member;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submitCheckIn() async {
    setState(() => _submitting = true);
    try {
      final result = await _repository.checkInAttendance(_code);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.all(28),
                  child: _loading
                      ? _buildLoading()
                      : _error != null
                      ? _buildError(_error!)
                      : _result != null
                      ? _buildSuccess(_result!)
                      : _buildConfirm(_member!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        SizedBox(height: 16),
        Text('Memuat data member...', style: TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildError(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFB91C1C),
          size: 60,
        ),
        const SizedBox(height: 14),
        const Text(
          'Absensi Gagal',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildConfirm(AttendanceMember member) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.fitness_center_rounded,
          color: Color(0xFF1D4ED8),
          size: 48,
        ),
        const SizedBox(height: 14),
        const Text(
          'Konfirmasi Kehadiran',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFFE8F4FF),
          child: Text(
            member.memberName.isEmpty
                ? '?'
                : member.memberName[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          member.memberName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          member.memberCode,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: !member.active || _submitting ? null : _submitCheckIn,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
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
              member.active ? 'Hadir Sekarang' : 'Membership Tidak Aktif',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(AttendanceCheckIn result) {
    final alreadyHere = result.already;
    final color = alreadyHere
        ? const Color(0xFFB45309)
        : const Color(0xFF15803D);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          alreadyHere ? Icons.verified_rounded : Icons.check_circle_rounded,
          color: color,
          size: 76,
        ),
        const SizedBox(height: 14),
        Text(
          'HADIR',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          result.memberName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 6),
              Text(
                'Check-in pukul ${result.checkInTime}',
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          result.message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
      ],
    );
  }
}
