import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/auth_service.dart';
import 'admin_account_service.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key, this.repository});

  final AdminAccountRepository? repository;

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  static const Color _background = Color(0xFFF4F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _navy = Color(0xFF071A3D);
  static const Color _success = Color(0xFF16A34A);

  final _cashierNameController = TextEditingController();
  final _cashierUsernameController = TextEditingController();
  final _cashierPasswordController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminUsernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final AdminAccountRepository _defaultRepository = AdminAccountRepository();
  AdminAccountRepository get _repository =>
      widget.repository ?? _defaultRepository;

  var _cashiers = <AccountUser>[];
  var _isLoadingCashiers = true;
  var _isCreatingCashier = false;
  var _isSavingProfile = false;
  final _deletingCashierIds = <int>{};
  final _updatingCashierPasswordIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _cashierNameController.dispose();
    _cashierUsernameController.dispose();
    _cashierPasswordController.dispose();
    _adminNameController.dispose();
    _adminUsernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminUsernameController.text =
          preferences.getString('auth_username') ?? '';
      _adminNameController.text = preferences.getString('auth_full_name') ?? '';
    });
    await _loadCashiers();
  }

  Future<void> _loadCashiers() async {
    setState(() => _isLoadingCashiers = true);
    try {
      final cashiers = await _repository.listCashiers();
      if (!mounted) return;
      setState(() {
        _cashiers = cashiers;
        _isLoadingCashiers = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingCashiers = false);
      _showMessage('Gagal memuat kasir', error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCashiers = false);
      _showMessage('Gagal memuat kasir', 'Server tidak dapat dihubungi.');
    }
  }

  Future<void> _createCashier() async {
    final fullName = _cashierNameController.text.trim();
    final username = _cashierUsernameController.text.trim();
    final password = _cashierPasswordController.text;

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      _showMessage(
        'Data belum lengkap',
        'Nama, username, dan password wajib diisi.',
      );
      return;
    }
    if (password.length < 6) {
      _showMessage(
        'Password terlalu pendek',
        'Password awal minimal 6 karakter.',
      );
      return;
    }

    setState(() => _isCreatingCashier = true);
    try {
      final cashier = await _repository.createCashier(
        fullName: fullName,
        username: username,
        password: password,
      );
      if (!mounted) return;
      setState(() {
        _cashiers = [cashier, ..._cashiers];
        _isCreatingCashier = false;
      });
      _cashierNameController.clear();
      _cashierUsernameController.clear();
      _cashierPasswordController.clear();
      _showMessage(
        'Akun kasir dibuat',
        '${cashier.fullName} sudah bisa login.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _isCreatingCashier = false);
      _showMessage('Gagal membuat akun', error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCreatingCashier = false);
      _showMessage('Gagal membuat akun', 'Server tidak dapat dihubungi.');
    }
  }

  Future<void> _saveAdminProfile() async {
    final fullName = _adminNameController.text.trim();
    final username = _adminUsernameController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (fullName.isEmpty || username.isEmpty || currentPassword.isEmpty) {
      _showMessage(
        'Data belum lengkap',
        'Nama, username, dan password saat ini wajib diisi.',
      );
      return;
    }
    if (newPassword.isNotEmpty && newPassword.length < 6) {
      _showMessage(
        'Password terlalu pendek',
        'Password baru minimal 6 karakter.',
      );
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      final account = await _repository.updateCurrentUser(
        fullName: fullName,
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _showMessage(
        'Profil admin disimpan',
        'Username aktif: ${account.username}.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      _showMessage('Gagal menyimpan profil', error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      _showMessage('Gagal menyimpan profil', 'Server tidak dapat dihubungi.');
    }
  }

  Future<void> _deleteCashier(AccountUser cashier) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus akun kasir?'),
          content: Text(
            'Akun ${cashier.fullName} akan dihapus dari database dan tidak bisa login lagi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Hapus'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || !mounted) return;

    setState(() => _deletingCashierIds.add(cashier.id));
    try {
      await _repository.deleteCashier(cashier.id);
      if (!mounted) return;
      setState(() {
        _cashiers = _cashiers
            .where((item) => item.id != cashier.id)
            .toList(growable: false);
        _deletingCashierIds.remove(cashier.id);
      });
      _showMessage('Akun kasir dihapus', '${cashier.fullName} sudah dihapus.');
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _deletingCashierIds.remove(cashier.id));
      _showMessage('Gagal menghapus kasir', error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingCashierIds.remove(cashier.id));
      _showMessage('Gagal menghapus kasir', 'Server tidak dapat dihubungi.');
    }
  }

  Future<void> _resetCashierPassword(AccountUser cashier) async {
    final passwordController = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit password kasir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cashier.fullName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                cashier.username,
                style: const TextStyle(
                  color: _AdminAccountScreenState._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _PasswordInput(
                controller: passwordController,
                label: 'Password baru kasir',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(passwordController.text),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan'),
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    passwordController.dispose();

    if (newPassword == null || !mounted) return;
    if (newPassword.length < 6) {
      _showMessage(
        'Password terlalu pendek',
        'Password baru kasir minimal 6 karakter.',
      );
      return;
    }

    setState(() => _updatingCashierPasswordIds.add(cashier.id));
    try {
      await _repository.resetCashierPassword(
        cashierId: cashier.id,
        password: newPassword,
      );
      if (!mounted) return;
      setState(() => _updatingCashierPasswordIds.remove(cashier.id));
      _showMessage(
        'Password kasir disimpan',
        '${cashier.fullName} bisa login dengan password baru.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _updatingCashierPasswordIds.remove(cashier.id));
      _showMessage('Gagal menyimpan password', error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _updatingCashierPasswordIds.remove(cashier.id));
      _showMessage('Gagal menyimpan password', 'Server tidak dapat dihubungi.');
    }
  }

  void _showMessage(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCashiers,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const _Header(),
              const SizedBox(height: 14),
              _AccountPanel(
                title: 'Buat Akun Kasir',
                subtitle:
                    'Admin dapat menyiapkan akun kasir untuk operasional POS.',
                child: Column(
                  children: [
                    _Input(controller: _cashierNameController, label: 'Nama'),
                    const SizedBox(height: 10),
                    _Input(
                      controller: _cashierUsernameController,
                      label: 'Username kasir',
                    ),
                    const SizedBox(height: 10),
                    _PasswordInput(
                      controller: _cashierPasswordController,
                      label: 'Password awal',
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Buat Akun Kasir',
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: _isCreatingCashier,
                      onPressed: _createCashier,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _AccountPanel(
                title: 'Profil Admin',
                subtitle:
                    'Ganti username atau password admin yang sedang login.',
                child: Column(
                  children: [
                    _Input(
                      controller: _adminNameController,
                      label: 'Nama admin',
                    ),
                    const SizedBox(height: 10),
                    _Input(
                      controller: _adminUsernameController,
                      label: 'Username admin',
                    ),
                    const SizedBox(height: 10),
                    _PasswordInput(
                      controller: _currentPasswordController,
                      label: 'Password saat ini',
                    ),
                    const SizedBox(height: 10),
                    _PasswordInput(
                      controller: _newPasswordController,
                      label: 'Password baru',
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Simpan Profil Admin',
                      icon: Icons.lock_reset_rounded,
                      isLoading: _isSavingProfile,
                      onPressed: _saveAdminProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _AccountPanel(
                title: 'Daftar Kasir',
                subtitle: 'Akun kasir yang tersimpan di database.',
                child: _CashierList(
                  isLoading: _isLoadingCashiers,
                  cashiers: _cashiers,
                  deletingCashierIds: _deletingCashierIds,
                  updatingCashierPasswordIds: _updatingCashierPasswordIds,
                  onEditPassword: _resetCashierPassword,
                  onDelete: _deleteCashier,
                  onRefresh: _loadCashiers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AdminAccountScreenState._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola password admin dan akun kasir.',
                  style: TextStyle(
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

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AdminAccountScreenState._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminAccountScreenState._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _AdminAccountScreenState._text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _AdminAccountScreenState._muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _AdminAccountScreenState._border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _AdminAccountScreenState._border),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        suffixIcon: IconButton(
          tooltip: _obscureText ? 'Tampilkan password' : 'Sembunyikan password',
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
          onPressed: () {
            setState(() => _obscureText = !_obscureText);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _AdminAccountScreenState._border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _AdminAccountScreenState._border),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: _AdminAccountScreenState._navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _AdminAccountScreenState._muted,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _CashierList extends StatelessWidget {
  const _CashierList({
    required this.isLoading,
    required this.cashiers,
    required this.deletingCashierIds,
    required this.updatingCashierPasswordIds,
    required this.onEditPassword,
    required this.onDelete,
    required this.onRefresh,
  });

  final bool isLoading;
  final List<AccountUser> cashiers;
  final Set<int> deletingCashierIds;
  final Set<int> updatingCashierPasswordIds;
  final ValueChanged<AccountUser> onEditPassword;
  final ValueChanged<AccountUser> onDelete;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 70,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cashiers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _AdminAccountScreenState._border),
        ),
        child: const Text(
          'Belum ada akun kasir.',
          style: TextStyle(
            color: _AdminAccountScreenState._muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < cashiers.length; index++) ...[
          _CashierTile(
            cashier: cashiers[index],
            isDeleting: deletingCashierIds.contains(cashiers[index].id),
            isUpdatingPassword: updatingCashierPasswordIds.contains(
              cashiers[index].id,
            ),
            onEditPassword: () => onEditPassword(cashiers[index]),
            onDelete: () => onDelete(cashiers[index]),
          ),
          if (index < cashiers.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Muat Ulang'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _AdminAccountScreenState._navy,
            side: const BorderSide(color: _AdminAccountScreenState._border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _CashierTile extends StatelessWidget {
  const _CashierTile({
    required this.cashier,
    required this.isDeleting,
    required this.isUpdatingPassword,
    required this.onEditPassword,
    required this.onDelete,
  });

  final AccountUser cashier;
  final bool isDeleting;
  final bool isUpdatingPassword;
  final VoidCallback onEditPassword;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminAccountScreenState._border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cashier.isActive
                  ? _AdminAccountScreenState._success.withValues(alpha: 0.12)
                  : _AdminAccountScreenState._muted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.point_of_sale_rounded,
              color: cashier.isActive
                  ? _AdminAccountScreenState._success
                  : _AdminAccountScreenState._muted,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cashier.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminAccountScreenState._text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cashier.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminAccountScreenState._muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(isActive: cashier.isActive),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Edit password kasir',
            onPressed: isUpdatingPassword || isDeleting ? null : onEditPassword,
            icon: isUpdatingPassword
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit_rounded),
            color: _AdminAccountScreenState._navy,
          ),
          IconButton(
            tooltip: 'Hapus akun kasir',
            onPressed: isDeleting || isUpdatingPassword ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? _AdminAccountScreenState._success.withValues(alpha: 0.12)
            : _AdminAccountScreenState._muted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: isActive
              ? _AdminAccountScreenState._success
              : _AdminAccountScreenState._muted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
