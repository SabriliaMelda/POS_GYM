/// Util pembuatan QRIS dinamis sesuai standar EMVCo/QRIS.
///
/// Mengambil QRIS *statis* milik merchant (dari penyedia QRIS gym), lalu
/// menyuntikkan nominal transaksi (tag 54) dan menghitung ulang CRC (tag 63),
/// sehingga saat pelanggan memindai, nominalnya langsung muncul di aplikasi
/// pembayaran mereka.
class QrisGenerator {
  const QrisGenerator._();

  /// Mengubah [staticPayload] (string QRIS statis) menjadi QRIS dinamis
  /// dengan nominal [amount] dalam Rupiah (tanpa desimal).
  static String buildDynamic(String staticPayload, num amount) {
    // Bersihkan baris baru/tab dari hasil copy-paste, tetapi pertahankan spasi
    // (mis. pada nama merchant).
    var payload = staticPayload.replaceAll(RegExp(r'[\r\n\t]'), '').trim();

    // Point of Initiation Method: "11" (statis/dipakai berulang) menjadi
    // "12" (dinamis/sekali pakai).
    payload = payload.replaceFirst('010211', '010212');

    // Buang CRC lama (tag 63) bila masih menempel di akhir ("6304" + 4 hex).
    final crcStart = payload.lastIndexOf('6304');
    if (crcStart != -1 && crcStart == payload.length - 8) {
      payload = payload.substring(0, crcStart);
    }

    // Field nominal (tag 54): "54" + panjang(2 digit) + nilai.
    final amountValue = amount.round().toString();
    final amountField =
        '54${amountValue.length.toString().padLeft(2, '0')}$amountValue';

    // Sisipkan tepat sebelum tag 58 (kode negara) agar tag tetap urut menaik.
    final countryIndex = payload.indexOf('5802');
    if (countryIndex != -1) {
      payload =
          payload.substring(0, countryIndex) +
          amountField +
          payload.substring(countryIndex);
    } else {
      payload += amountField;
    }

    // Hitung ulang CRC atas seluruh payload + penanda "6304".
    final base = '${payload}6304';
    return '$base${_crc16(base)}';
  }

  /// CRC-16/CCITT-FALSE (polinomial 0x1021, init 0xFFFF) → 4 hex huruf besar.
  static String _crc16(String data) {
    var crc = 0xFFFF;
    for (final code in data.codeUnits) {
      crc ^= code << 8;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
        crc &= 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
