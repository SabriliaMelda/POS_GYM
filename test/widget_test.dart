// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_gym/main.dart';

void main() {
  testWidgets('POS Gym app opens login and enters cashier page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('username-field')), 'kasir');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Member'), findsOneWidget);
  });

  testWidgets('Admin login opens reports page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('role-admin')));
    await tester.enterText(find.byKey(const Key('username-field')), 'admin');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pusat Laporan'), findsOneWidget);
    expect(find.text('Laporan Omzet'), findsOneWidget);
  });
}
