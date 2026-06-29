import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../admin/screens/master/admin_master_data_service.dart';

/// Halaman registrasi member baru yang dibuka di HP setelah memindai QR di
/// kasir (`.../#/member-register?trx=<kode_transaksi>`). Member mengisi data
/// diri → disimpan ke database & tertaut ke transaksi gym-nya.
class MemberRegisterScreen extends StatefulWidget {
  const MemberRegisterScreen({super.key});

  @override
  State<MemberRegisterScreen> createState() => _MemberRegisterScreenState();
}

class _MemberRegisterScreenState extends State<MemberRegisterScreen> {
  static const _accent = Color(0xFF1D4ED8);
  static const _navy = Color(0xFF071A3D);

  final _repository = AdminMasterDataRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Male';
  DateTime? _dob;

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  RegisterInfo? _info;
  String? _successMemberCode;

  String get _trx =>
      (Get.parameters['trx'] ?? Uri.base.queryParameters['trx'] ?? '').trim();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_trx.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Tautan registrasi tidak valid. Scan ulang QR dari kasir.';
      });
      return;
    }
    try {
      final info = await _repository.registerInfo(_trx);
      if (!mounted) return;
      _nameCtrl.text = info.customerName;
      setState(() {
        _loading = false;
        _info = info;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dob == null) {
      Get.snackbar('Tanggal Lahir', 'Pilih tanggal lahir terlebih dahulu.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final code = await _repository.registerMember(
        trx: _trx,
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gender: _gender,
        dateOfBirth: _fmtDate(_dob!),
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _successMemberCode = code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _loading
                      ? _buildLoading()
                      : _error != null
                      ? _buildMessage(
                          Icons.error_outline_rounded,
                          const Color(0xFFB91C1C),
                          'Registrasi Gagal',
                          _error!,
                        )
                      : _successMemberCode != null
                      ? _buildMessage(
                          Icons.verified_rounded,
                          const Color(0xFF15803D),
                          'Registrasi Berhasil',
                          'Selamat bergabung, ${_nameCtrl.text.trim()}!\n'
                              'Kode member Anda: $_successMemberCode',
                        )
                      : (_info?.alreadyRegistered ?? false)
                      ? _buildMessage(
                          Icons.info_outline_rounded,
                          const Color(0xFFB45309),
                          'Sudah Terdaftar',
                          'Transaksi ini sudah dipakai untuk registrasi member '
                              '(${_info?.memberCode ?? '-'}).',
                        )
                      : _buildForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMessage(IconData icon, Color color, String title, String body) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 64),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF334155), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.app_registration_rounded, color: _accent, size: 42),
          const SizedBox(height: 10),
          const Text(
            'Registrasi Member',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Paket: ${_info?.packageName ?? '-'}',
            style: const TextStyle(
              color: _accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          _field(_nameCtrl, 'Nama lengkap', Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _field(
            _emailCtrl,
            'Email',
            Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Email wajib diisi';
              if (!t.contains('@') || !t.contains('.')) return 'Email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            _phoneCtrl,
            'Nomor HP',
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _field(
            _addressCtrl,
            'Alamat',
            Icons.home_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: _decoration('Jenis kelamin', Icons.wc_rounded),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Female', child: Text('Perempuan')),
            ],
            onChanged: (v) => setState(() => _gender = v ?? 'Male'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: _decoration('Tanggal lahir', Icons.cake_outlined),
              child: Text(
                _dob == null ? 'Pilih tanggal' : _fmtDate(_dob!),
                style: TextStyle(
                  color: _dob == null ? const Color(0xFF94A3B8) : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text(
                'Simpan & Daftar',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textCapitalization: label == 'Email'
          ? TextCapitalization.none
          : TextCapitalization.words,
      validator:
          validator ??
          (v) => (v ?? '').trim().isEmpty ? '$label wajib diisi' : null,
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _accent, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
  }
}
