import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadMembers();
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
    finalAmount.value =
        totalAmount.value - discountAmount.value + taxAmount.value;
    update();
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
  }

  void selectMember(Member member) {
    selectedMember.value = member;
  }

  void setMemberCustomer(bool value) {
    isMemberCustomer.value = value;
    if (!value) selectedMember.value = null;

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
      await _repository.createFnbTransaction(
        memberId: isMemberCustomer.value ? selectedMember.value?.id : null,
        paymentMethod: paymentMethod,
        notes: isMemberCustomer.value
            ? 'Pembeli member: ${selectedMember.value?.name ?? '-'}'
            : 'Pembeli non-member',
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
      clearCart();
      await loadItems(); // segarkan stok terbaru dari backend
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
