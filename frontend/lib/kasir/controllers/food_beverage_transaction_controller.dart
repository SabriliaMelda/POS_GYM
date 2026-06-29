import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';
import 'member_management_controller.dart';

/// Controller transaksi F&B untuk kasir.
/// Sumber data menu & member = backend (lewat [AdminMasterDataRepository]),
/// mengikuti pola [GymTransactionController].
class FoodBeverageTransactionController extends GetxController {
  FoodBeverageTransactionController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  final items = <FoodBeverageItem>[].obs;
  final cartItems = <CartItem>[].obs;
  final members = <Member>[].obs;
  final selectedMember = Rx<Member?>(null);
  final isMemberCustomer = false.obs;
  final isLoading = false.obs;
  final totalAmount = 0.0.obs;
  final discountAmount = 0.0.obs;
  final taxAmount = 0.0.obs;
  final finalAmount = 0.0.obs;

  // Voucher F&B yang sedang ditukar (dari tombol "Pakai" di detail member).
  // Bila ada, transaksi diarahkan ke member ini + diskon sebesar persen voucher,
  // dan voucher ditandai DIPAKAI setelah pembayaran berhasil.
  final voucherMember = Rx<Member?>(null);
  final voucherMilestone = 0.obs;
  final voucherPercent = 0.obs;

  /// Riwayat transaksi F&B (dari backend).
  final transactions = <FoodBeverageTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadMembers();
    loadTransactions();
  }

  /// Memuat riwayat transaksi F&B terbaru dari backend.
  Future<void> loadTransactions() async {
    try {
      final loaded = await _repository.listFnbTransactions();
      loaded.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      transactions.value = loaded;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat riwayat F&B: ${_msg(e)}');
    }
  }

  /// Memuat daftar menu F&B aktif dari backend.
  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final loaded = await _repository.listFnbItems();
      items.value = loaded.where((item) => item.isActive).toList();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat menu: ${_msg(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Memuat daftar member untuk opsi harga member.
  Future<void> loadMembers() async {
    try {
      members.value = await _repository.listMembers();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: ${_msg(e)}');
    }
  }

  void addToCart(FoodBeverageItem item) {
    final price = priceFor(item);
    final index = cartItems.indexWhere(
      (cartItem) => cartItem.itemId == item.id,
    );
    final currentQty = index == -1 ? 0 : cartItems[index].quantity;

    // Cegah penjualan melebihi stok yang tersedia.
    if (currentQty >= item.stock) {
      Get.snackbar(
        'Stok Tidak Cukup',
        item.stock <= 0
            ? '${item.name} sedang habis.'
            : 'Stok ${item.name} hanya tersisa ${item.stock}.',
      );
      return;
    }

    if (index == -1) {
      cartItems.add(
        CartItem(
          itemId: item.id ?? 0,
          itemName: item.name,
          price: price,
          quantity: 1,
          subtotal: price,
        ),
      );
    } else {
      cartItems[index].quantity++;
    }
    cartItems.refresh();
    calculateTotal();
  }

  void removeFromCart(int itemId) {
    cartItems.removeWhere((item) => item.itemId == itemId);
    calculateTotal();
  }

  void updateCartItemQuantity(int itemId, int quantity) {
    final item = cartItems.firstWhere((cartItem) => cartItem.itemId == itemId);
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }
    item.quantity = quantity;
    cartItems.refresh();
    calculateTotal();
  }

  void calculateTotal() {
    totalAmount.value = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    // Diskon mengikuti persen voucher bila ada voucher yang sedang dipakai.
    if (voucherPercent.value > 0) {
      discountAmount.value = (totalAmount.value * voucherPercent.value) / 100;
    }
    finalAmount.value =
        totalAmount.value - discountAmount.value + taxAmount.value;
    update();
  }

  /// Memakai voucher F&B member (dipanggil dari "Pakai" di detail member):
  /// mengarahkan transaksi F&B ke member ini dengan diskon sebesar [percent].
  void applyVoucher(Member member, int milestone, int percent) {
    voucherMember.value = member;
    voucherMilestone.value = milestone;
    voucherPercent.value = percent;
    selectedMember.value = member;
    calculateTotal();
  }

  void clearVoucher() {
    voucherMember.value = null;
    voucherMilestone.value = 0;
    voucherPercent.value = 0;
    discountAmount.value = 0;
    calculateTotal();
  }

  void setDiscount(double discount) {
    discountAmount.value = discount;
    calculateTotal();
  }

  void setTax(double tax) {
    taxAmount.value = tax;
    calculateTotal();
  }

  void clearCart() {
    cartItems.clear();
    selectedMember.value = null;
    isMemberCustomer.value = false;
    totalAmount.value = 0;
    discountAmount.value = 0;
    taxAmount.value = 0;
    finalAmount.value = 0;
    voucherMember.value = null;
    voucherMilestone.value = 0;
    voucherPercent.value = 0;
  }

  void selectMember(Member member) {
    // Voucher yang sedang dipakai harus cocok dengan member terpilih.
    if (voucherMember.value != null && voucherMember.value?.id != member.id) {
      clearVoucher();
    }
    selectedMember.value = member;
  }

  void setMemberCustomer(bool value) {
    isMemberCustomer.value = value;
    if (!value) {
      selectedMember.value = null;
      clearVoucher();
    }

    cartItems.value = cartItems.map((cartItem) {
      final item = items.firstWhere((item) => item.id == cartItem.itemId);
      final price = priceFor(item);
      return CartItem(
        itemId: cartItem.itemId,
        itemName: cartItem.itemName,
        price: price,
        quantity: cartItem.quantity,
        subtotal: price * cartItem.quantity,
      );
    }).toList();
    calculateTotal();
  }

  double priceFor(FoodBeverageItem item) {
    if (!isMemberCustomer.value) return item.price;
    return (item.price * 0.9 / 1000).round() * 1000;
  }

  /// Menyimpan transaksi F&B (isi keranjang saat ini) ke database lewat
  /// backend; stok ikut dikurangi di server. Mengembalikan null bila berhasil,
  /// atau pesan error bila gagal (keranjang tidak dikosongkan agar bisa ulangi).
  Future<String?> checkout({String paymentMethod = 'QRIS'}) async {
    if (cartItems.isEmpty) return 'Keranjang masih kosong.';
    if (isLoading.value) return 'Transaksi sedang diproses.';
    try {
      isLoading.value = true;
      final voucher = voucherMember.value;
      final voucherMs = voucherMilestone.value;
      final voucherPct = voucherPercent.value;
      final memberId =
          voucher?.id ??
          (isMemberCustomer.value ? selectedMember.value?.id : null);
      final notes = voucher != null
          ? 'Voucher F&B $voucherPct% - ${voucher.name}'
          : (isMemberCustomer.value
                ? 'Pembeli member: ${selectedMember.value?.name ?? '-'}'
                : 'Pembeli non-member');
      await _repository.createFnbTransaction(
        memberId: memberId,
        paymentMethod: paymentMethod,
        notes: notes,
        discountAmount: voucherPct > 0 ? discountAmount.value : 0,
        items: cartItems
            .map(
              (c) => {
                'item_id': c.itemId,
                'name': c.itemName,
                'price': c.price,
                'quantity': c.quantity,
              },
            )
            .toList(),
      );
      // Tandai voucher DIPAKAI setelah transaksi tersimpan (best-effort), lalu
      // segarkan data member agar status voucher di layar member ikut terbarui.
      if (voucher?.id != null && voucherMs > 0) {
        try {
          await _repository.redeemVoucher(voucher!.id!, voucherMs);
          if (Get.isRegistered<MemberManagementController>()) {
            await Get.find<MemberManagementController>().loadMembers();
          }
        } catch (_) {}
      }
      clearCart();
      await loadItems(); // segarkan stok terbaru dari backend
      await loadTransactions(); // perbarui riwayat F&B
      return null;
    } catch (e) {
      return _msg(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// URL penuh gambar menu dari backend (kosong bila item tanpa foto).
  String imageUrlFor(FoodBeverageItem item) =>
      _repository.resolveImageUrl(item.imagePath);

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
