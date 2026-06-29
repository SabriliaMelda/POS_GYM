import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

/// Menampilkan [data] (teks/URL) sebagai kode QR berukuran [size].
class QrView extends StatelessWidget {
  const QrView(this.data, {super.key, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QrPainter(data)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final elements = Barcode.qrCode().make(
      data,
      width: size.width,
      height: size.height,
    );
    final paint = Paint()..color = Colors.black;
    for (final element in elements) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.data != data;
}
