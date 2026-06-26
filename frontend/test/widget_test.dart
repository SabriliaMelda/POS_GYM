import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_gym/auth/auth_service.dart';
import 'package:pos_gym/main.dart';

void main() {
  testWidgets('POS Gym app opens login and enters cashier page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(authRepository: _FakeAuthRepository(role: 'kasir')),
    );

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('username-field')), 'kasir');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Member'), findsOneWidget);
  });

  testWidgets('Admin login opens reports page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(authRepository: _FakeAuthRepository(role: 'admin')),
    );

    await tester.tap(find.byKey(const Key('role-admin')));
    await tester.enterText(find.byKey(const Key('username-field')), 'admin');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Dashboard Admin'), findsOneWidget);
    expect(find.text('Pengelolaan Sistem'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository({required this.role});

  final String role;

  @override
  Future<LoginSession> login({
    required String username,
    required String password,
    required String role,
  }) async {
    return LoginSession(
      token: 'test-token',
      tokenType: 'Bearer',
      expiresIn: 86400,
      mustChangePassword: false,
      user: AuthUser(
        id: 1,
        username: username,
        fullName: 'Test User',
        role: this.role,
        isActive: true,
        mustChangePassword: false,
      ),
    );
  }
}
