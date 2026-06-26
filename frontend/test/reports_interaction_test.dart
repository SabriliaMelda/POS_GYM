import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pos_gym/admin/screens/reports/reports_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GetMaterialApp(home: ReportsScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('opens split options panel when a report is tapped',
      (tester) async {
    await pump(tester, const Size(1200, 900));

    await tester.tap(find.text('Laporan Member'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('FORMAT FILE'), findsOneWidget);
    expect(find.text('PERIODE LAPORAN'), findsOneWidget);
    expect(find.text('Rentang Khusus'), findsOneWidget);
  });

  testWidgets('custom range shows inline calendar without navigating',
      (tester) async {
    await pump(tester, const Size(1200, 900));

    await tester.tap(find.text('Laporan Transaksi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rentang Khusus'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Weekday header of the inline calendar is visible (no separate page).
    expect(find.text('Sn'), findsOneWidget);
    expect(find.text('Mg'), findsOneWidget);
  });
}
