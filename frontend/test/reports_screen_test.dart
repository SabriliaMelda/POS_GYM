import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pos_gym/admin/screens/reports/reports_screen.dart';

void main() {
  Future<void> pumpReports(WidgetTester tester, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GetMaterialApp(home: ReportsScreen()));
    await tester.pump();
  }

  testWidgets('reports page renders on mobile', (tester) async {
    await pumpReports(tester, size: const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.text('Laporan Omzet'), findsNothing);
    expect(find.text('Laporan Member'), findsOneWidget);
  });

  testWidgets('reports page renders on desktop', (tester) async {
    await pumpReports(tester, size: const Size(1200, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('Laporan Transaksi'), findsOneWidget);
  });
}
