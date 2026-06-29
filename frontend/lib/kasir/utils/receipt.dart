import 'dart:convert';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'company_logo.dart';
import 'utils.dart';

/// Satu baris pada struk (item atau paket).
class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.qty,
    required this.price,
  });

  final String name;
  final int qty;
  final double price;
}

// Identitas toko pada struk. Ubah di sini bila perlu.
const _shopName = 'X-FIT DIGITAL INDONESIA';
const _shopAddress =
    'Jl. Kemang I No.11, RT.10/RW.1, Bangka, Kec. Mampang Prpt., '
    'Kota Jakarta Selatan, DKI Jakarta 12730';
const _shopPhone = '0819-1400-0541';

/// Membuat & mencetak struk PDF (80mm) yang seragam untuk gym & F&B.
Future<void> printReceipt({
  required String txCode,
  required DateTime date,
  required String customer,
  required String paymentMethod,
  required List<ReceiptLine> lines,
  required double total,
}) async {
  final rupiah = CurrencyUtils.formatCurrencySimple;
  final totalQty = lines.fold<int>(0, (sum, l) => sum + l.qty);

  // Logo perusahaan (X-FIT.ID) dari base64 yang ditanam di kode — tidak
  // bergantung pemuatan aset (assets di web sering 404). Di-decode lalu
  // encode ulang ke PNG bersih agar pasti bisa ditanam pdf. Opsional.
  pw.MemoryImage? logo;
  try {
    final decoded = img.decodeImage(base64Decode(kCompanyLogoBase64));
    if (decoded != null) {
      logo = pw.MemoryImage(img.encodePng(decoded));
    }
  } catch (_) {
    // logo opsional
  }

  pw.Widget dashed() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(
      '- ' * 26,
      maxLines: 1,
      overflow: pw.TextOverflow.clip,
      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
    ),
  );

  pw.Widget money(String label, String value, {bool bold = false}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: bold ? 10 : 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: bold ? 10 : 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    ],
  );

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.fromLTRB(10, 12, 10, 12),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (logo != null)
            pw.Center(child: pw.Image(logo, width: 56, height: 56)),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              _shopName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text(
              _shopAddress,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text(
              'Telp $_shopPhone',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Center(
            child: pw.Text(txCode, style: const pw.TextStyle(fontSize: 8)),
          ),
          dashed(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                DateTimeUtils.formatDateTime(date),
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(customer, style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
          dashed(),
          for (var i = 0; i < lines.length; i++) ...[
            pw.Text(
              '${i + 1}. ${lines[i].name}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '   ${lines[i].qty} x ${rupiah(lines[i].price)}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  rupiah(lines[i].price * lines[i].qty),
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ],
          dashed(),
          pw.Text('Total QTY : $totalQty', style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 4),
          money('Sub Total', rupiah(total)),
          money('Total', rupiah(total), bold: true),
          money('Bayar ($paymentMethod)', rupiah(total)),
          money('Kembali', rupiah(0)),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Terima kasih telah berbelanja',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}
