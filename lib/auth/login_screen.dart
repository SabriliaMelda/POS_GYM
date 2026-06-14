import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'Kasir';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    Get.offAllNamed(_selectedRole == 'Admin' ? '/admin' : '/kasir');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (isDesktop) const Expanded(flex: 11, child: _LoginHeroPanel()),
              Expanded(
                flex: isDesktop ? 9 : 1,
                child: _LoginFormPanel(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  selectedRole: _selectedRole,
                  obscurePassword: _obscurePassword,
                  onRoleChanged: (role) {
                    setState(() => _selectedRole = role);
                  },
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onLogin: _login,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginHeroPanel extends StatelessWidget {
  const _LoginHeroPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/gym/premium-gym-hero.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99040B18), Color(0xF2071938)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandMark(light: true),
              const Spacer(),
              Container(
                width: 52,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Kelola gym lebih cepat,\nrapi, dan terintegrasi.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Satu sistem untuk transaksi, member, absensi,\ndan laporan operasional harian.',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 44),
              const Text(
                'X-FIT DIGITAL INDONESIA',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  const _LoginFormPanel({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.selectedRole,
    required this.obscurePassword,
    required this.onRoleChanged,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String selectedRole;
  final bool obscurePassword;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(light: false),
                  const SizedBox(height: 48),
                  const Text(
                    'Selamat datang',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Masuk untuk melanjutkan ke sistem POS Gym.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _RoleSelector(
                    selectedRole: selectedRole,
                    onChanged: onRoleChanged,
                  ),
                  const SizedBox(height: 26),
                  const _FieldLabel('Username'),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('username-field'),
                    controller: usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      hintText: 'Masukkan username',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Username wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('password-field'),
                    controller: passwordController,
                    obscureText: obscurePassword,
                    onFieldSubmitted: (_) => onLogin(),
                    decoration: _inputDecoration(
                      hintText: 'Masukkan password',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        tooltip: obscurePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: onTogglePassword,
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 21,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hubungi admin untuk mengatur ulang password.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Lupa password?'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      key: const Key('login-button'),
                      onPressed: onLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF071A3D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk ke Sistem',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'POS Gym v1.0  •  Sistem internal perusahaan',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565D8), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selectedRole, required this.onChanged});

  final String selectedRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Kasir', 'Admin'].map((role) {
          final selected = role == selectedRole;
          return Expanded(
            child: InkWell(
              key: Key('role-${role.toLowerCase()}'),
              onTap: () => onChanged(role),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Color(0x120F172A),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      role == 'Kasir'
                          ? Icons.point_of_sale_rounded
                          : Icons.admin_panel_settings_outlined,
                      size: 18,
                      color: selected
                          ? const Color(0xFF071A3D)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      role,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF071A3D)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final primaryColor = light ? Colors.white : const Color(0xFF071A3D);
    final secondaryColor = light
        ? const Color(0xFFB8C7DB)
        : const Color(0xFF64748B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/images/logogym.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POS GYM',
              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'MANAGEMENT SYSTEM',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
