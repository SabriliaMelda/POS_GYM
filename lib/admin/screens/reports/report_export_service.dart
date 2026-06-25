import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../kasir/models/member_voucher.dart';
import '../../../kasir/services/mock_data_service.dart';
import '../master/admin_master_data_service.dart';
import 'report_download.dart';

enum ReportType { member, transaction, visit }

enum ReportFileFormat { pdf, excel }

class ReportExportService {
  ReportExportService._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _fileDate = DateFormat('yyyyMMdd');
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Future<int> export({
    required ReportType type,
    required ReportFileFormat format,
    required DateTime? startDate,
    required DateTime? endDate,
    required String periodLabel,
  }) async {
    final report = await _buildReport(type, startDate, endDate);
    final filePeriod = startDate == null || endDate == null
        ? 'semua_data'
        : '${_fileDate.format(startDate)}-${_fileDate.format(endDate)}';
    final baseName = '${report.fileName}_$filePeriod';

    if (format == ReportFileFormat.pdf) {
      final bytes = await _buildPdf(report, periodLabel);
      await Printing.sharePdf(bytes: bytes, filename: '$baseName.pdf');
    } else {
      final bytes = _buildExcel(report, periodLabel);
      await downloadReportFile(
        bytes: bytes,
        filename: '$baseName.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }

    return report.rows.length;
  }

  static String _genderLabel(String gender) {
    switch (gender.trim().toLowerCase()) {
      case 'male':
      case 'l':
      case 'laki-laki':
      case 'pria':
        return 'Laki-laki';
      case 'female':
      case 'p':
      case 'perempuan':
      case 'wanita':
        return 'Perempuan';
      default:
        return gender.trim().isEmpty ? '-' : gender;
    }
  }

  static Future<_ReportData> _buildReport(
    ReportType type,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final data = MockDataService.instance;
    final start = startDate == null
        ? null
        : DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    bool inRange(DateTime date) {
      if (start == null || end == null) return true;
      return !date.isBefore(start) && !date.isAfter(end);
    }

    switch (type) {
      case ReportType.member:
        final repository = AdminMasterDataRepository();
        final databaseMembers = await repository.listMembers();
        final packages = await repository.listGymPackages();
        final packageNames = {
          for (final package in packages) package.packageId: package.name,
        };
        final members =
            databaseMembers
                .where((item) => inRange(item.registrationDate))
                .toList()
              ..sort(
                (a, b) => b.registrationDate.compareTo(a.registrationDate),
              );
        return _ReportData(
          title: 'Laporan Member',
          fileName: 'laporan_member',
          headers: const [
            'ID Member',
            'Nama',
            'Email',
            'Telepon',
            'Alamat',
            'Gender',
            'Tgl Lahir',
            'Paket',
            'Tgl Daftar',
            'Masa Berlaku',
            'Total Kunjungan',
            'Status',
            'Perpanjangan',
            'Follow-up',
            'Voucher (pakai/dapat)',
          ],
          rows: members.map((item) {
            final earnedVoucher = item.totalVisits ~/ kVisitsPerVoucher;
            final usedVoucher = item.voucherRedemptions.length;
            return [
              item.memberId,
              item.name,
              item.email.isEmpty ? '-' : item.email,
              item.phoneNumber.isEmpty ? '-' : item.phoneNumber,
              item.address.isEmpty ? '-' : item.address,
              _genderLabel(item.gender),
              _date.format(item.dateOfBirth),
              packageNames[item.gymPackageId] ?? item.gymPackageId,
              _date.format(item.registrationDate),
              _date.format(item.membershipExpiryDate),
              item.totalVisits.toString(),
              item.isActive && !item.isExpired ? 'Aktif' : 'Kedaluwarsa',
              '${item.renewals.length}x',
              '${item.followUps.length}x',
              '$usedVoucher/$earnedVoucher',
            ];
          }).toList(),
        );

      case ReportType.transaction:
        final rows = <_DatedRow>[
          ...data.gymTransactions
              .where((item) => inRange(item.transactionDate))
              .map(
                (item) => _DatedRow(item.transactionDate, [
                  item.transactionId,
                  _date.format(item.transactionDate),
                  'Gym',
                  item.memberName ?? 'Pelanggan Gym',
                  item.packageName ?? '-',
                  item.paymentMethod,
                  _currency.format(item.amount),
                  item.status,
                ]),
              ),
          ...data.foodBeverageTransactions
              .where((item) => inRange(item.transactionDate))
              .map(
                (item) => _DatedRow(item.transactionDate, [
                  item.transactionId,
                  _date.format(item.transactionDate),
                  'Food & Beverage',
                  item.memberName ?? 'Non-member',
                  item.items.map((entry) => entry.itemName).join(', '),
                  item.paymentMethod,
                  _currency.format(item.finalAmount),
                  item.status,
                ]),
              ),
        ]..sort((a, b) => b.date.compareTo(a.date));
        return _ReportData(
          title: 'Laporan Transaksi',
          fileName: 'laporan_transaksi',
          headers: const [
            'ID Transaksi',
            'Tanggal',
            'Jenis',
            'Pelanggan',
            'Detail',
            'Pembayaran',
            'Total',
            'Status',
          ],
          rows: rows.map((item) => item.values).toList(),
        );

      case ReportType.visit:
        final visits =
            data.attendanceRecords
                .where((item) => inRange(item.attendanceDate))
                .toList()
              ..sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
        return _ReportData(
          title: 'Laporan Kunjungan',
          fileName: 'laporan_kunjungan',
          headers: const [
            'Tanggal',
            'ID Member',
            'Nama Member',
            'Check-in',
            'Check-out',
            'Akses',
          ],
          rows: visits
              .map(
                (item) => [
                  _date.format(item.attendanceDate),
                  item.memberId.toString(),
                  item.memberName ?? '-',
                  item.checkInTime ?? '-',
                  item.checkOutTime ?? '-',
                  item.rfidCardNumber == null ? 'Manual' : 'RFID',
                ],
              )
              .toList(),
        );
    }
  }

  static Future<Uint8List> _buildPdf(
    _ReportData report,
    String periodLabel,
  ) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'X-FIT DIGITAL INDONESIA',
              style: pw.TextStyle(
                color: PdfColors.blue900,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              report.title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Periode $periodLabel'
              '  |  ${report.rows.length} data',
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
            pw.SizedBox(height: 14),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
          ),
        ),
        build: (context) => [
          if (report.rows.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text('Tidak ada data pada periode ini.'),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: report.headers,
              data: report.rows,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
        ],
      ),
    );
    return document.save();
  }

  static Uint8List _buildExcel(_ReportData report, String periodLabel) {
    final workbook = Excel.createExcel();
    final defaultSheet = workbook.getDefaultSheet();
    final sheet = workbook[report.title];
    if (defaultSheet != null && defaultSheet != report.title) {
      workbook.delete(defaultSheet);
    }

    sheet.appendRow([TextCellValue(report.title)]);
    sheet.appendRow([TextCellValue('Periode $periodLabel')]);
    sheet.appendRow([TextCellValue('Jumlah data: ${report.rows.length}')]);
    sheet.appendRow([]);
    sheet.appendRow(
      report.headers.map((value) => TextCellValue(value)).toList(),
    );
    for (final row in report.rows) {
      sheet.appendRow(
        row.map((value) => TextCellValue(value.toString())).toList(),
      );
    }

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.fromHexString('#071A3D'),
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;

    final headerRow = 4;
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#155E9F'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    for (var column = 0; column < report.headers.length; column++) {
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: column,
                  rowIndex: headerRow,
                ),
              )
              .cellStyle =
          headerStyle;
      sheet.setColumnWidth(column, 20);
    }

    final encoded = workbook.encode();
    if (encoded == null) {
      throw StateError('Gagal membuat file Excel.');
    }
    return Uint8List.fromList(encoded);
  }
}

class _ReportData {
  const _ReportData({
    required this.title,
    required this.fileName,
    required this.headers,
    required this.rows,
  });

  final String title;
  final String fileName;
  final List<String> headers;
  final List<List<dynamic>> rows;
}

class _DatedRow {
  const _DatedRow(this.date, this.values);

  final DateTime date;
  final List<dynamic> values;
}
