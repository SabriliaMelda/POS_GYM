import 'dart:async';

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../utils/utils.dart';

/// Menampilkan dialog pembayaran Midtrans (Snap) untuk [amount] rupiah.
///
/// Membuat transaksi Snap di backend, menampilkan QR berisi link halaman bayar
/// Midtrans (pelanggan scan -> pilih QRIS/e-wallet -> bayar), lalu memantau
/// status secara berkala. Mengembalikan `true` bila pembayaran lunas, `false`
/// bila dibatalkan/gagal.
Future<bool> showMidtransPayment({
  required int amount,
  required String label,
  AdminMasterDataRepository? repository,
}) async {
  final result = await Get.dialog<bool>(
    _MidtransPaymentDialog(
      amount: amount,
      label: label,
      repository: repository ?? AdminMasterDataRepository(),
    ),
    barrierDismissible: false,
  );
  return result ?? false;
}

class _MidtransPaymentDialog extends StatefulWidget {
  const _MidtransPaymentDialog({
    required this.amount,
    required this.label,
    required this.repository,
  });

  final int amount;
  final String label;
  final AdminMasterDataRepository repository;

  @override
  State<_MidtransPaymentDialog> createState() => _MidtransPaymentDialogState();
}

class _MidtransPaymentDialogState extends State<_MidtransPaymentDialog> {
  static const _navy = Color(0xFF071A3D);

  bool _loading = true;
  bool _checking = false;
  String? _error;
  SnapPayment? _payment;
  Timer? _timer;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final payment = await widget.repository.createSnapPayment(
        amount: widget.amount,
        label: widget.label,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _payment = payment;
      });
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _poll() async {
    final payment = _payment;
    if (payment == null || _closed) return;
    try {
      final paid = await widget.repository.checkPaymentStatus(payment.orderId);
      if (paid && mounted && !_closed) {
        _closed = true;
        _timer?.cancel();
        Get.back<bool>(result: true);
      }
    } catch (_) {
      // Abaikan error sementara; polling berikutnya mencoba lagi.
    }
  }

  /// Pengecekan manual (kalau pelanggan sudah bayar tapi polling belum sempat).
  Future<void> _manualCheck() async {
    final payment = _payment;
    if (payment == null || _closed) return;
    setState(() => _checking = true);
    try {
      final paid = await widget.repository.checkPaymentStatus(payment.orderId);
      if (!mounted) return;
      if (paid) {
        _closed = true;
        _timer?.cancel();
        Get.back<bool>(result: true);
        return;
      }
      Get.snackbar(
        'Belum Lunas',
        'Pembayaran belum terdeteksi. Selesaikan dulu pembayarannya, lalu cek lagi.',
      );
    } catch (e) {
      Get.snackbar('Gagal Cek', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cancel() {
    if (_closed) return;
    _closed = true;
    _timer?.cancel();
    Get.back<bool>(result: false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, Color(0xFF155E9F)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 30),
                    SizedBox(height: 6),
                    Text(
                      'Pembayaran QRIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Diproses aman melalui Midtrans',
                      style: TextStyle(
                        color: Color(0xFFE8F4FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: _loading
                    ? _buildLoading()
                    : _error != null
                    ? _buildError(_error!)
                    : _buildContent(_payment!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text(
            'Menyiapkan pembayaran...',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFB91C1C),
          size: 52,
        ),
        const SizedBox(height: 12),
        const Text(
          'Gagal Memuat Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancel,
            child: const Text('Tutup'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(SnapPayment payment) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SizedBox(
            width: 210,
            height: 210,
            child: CustomPaint(painter: _PayQrPainter(payment.redirectUrl)),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Total Pembayaran',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          CurrencyUtils.formatCurrencySimple(widget.amount.toDouble()),
          style: const TextStyle(
            color: _navy,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Scan QR dengan HP → pilih QRIS / e-wallet → bayar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: payment.redirectUrl));
            Get.snackbar('Link disalin', 'Buka link untuk membayar di browser.');
          },
          icon: const Icon(Icons.link_rounded, size: 16),
          label: const Text('Salin link bayar'),
        ),
        const SizedBox(height: 12),
        Text(
          'Order: ${payment.orderId}',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Menunggu pembayaran... (cek otomatis tiap 3 detik)',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _checking ? null : _manualCheck,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: _checking
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text(
              'Saya Sudah Bayar — Cek',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: const Color(0xFF475569),
            ),
            child: const Text(
              'Batalkan',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

/// Menggambar string (URL pembayaran) sebagai kode QR.
class _PayQrPainter extends CustomPainter {
  _PayQrPainter(this.data);

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
  bool shouldRepaint(covariant _PayQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
