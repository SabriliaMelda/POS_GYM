import 'package:get/get.dart';

/// Mengontrol tab navbar bawah kasir agar bisa dipindah dari mana saja
/// (mis. setelah "Pakai voucher" di detail member langsung pindah ke tab F&B
/// tanpa kehilangan navbar bawah).
class KasirShellController extends GetxController {
  final tabIndex = 0.obs;

  void goTo(int index) => tabIndex.value = index;
}

/// Indeks tab navbar bawah kasir (urut sesuai daftar layar di HomeScreen).
class KasirTab {
  static const int beranda = 0;
  static const int member = 1;
  static const int gym = 2;
  static const int fnb = 3;
  static const int absensi = 4;
  static const int riwayat = 5;
}
