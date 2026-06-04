import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class FoodBeverageTransactionController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var transactions = <FoodBeverageTransaction>[].obs;
  var items = <FoodBeverageItem>[].obs;
  var cartItems = <CartItem>[].obs;
  var selectedMember = Rx<Member?>(null);
  var isLoading = false.obs;
  var totalAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var taxAmount = 0.0.obs;
  var finalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadTransactions();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final loadedItems = _mockData.getActiveFoodBeverageItems();
      items.value = loadedItems;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat item: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final loadedTransactions = List<FoodBeverageTransaction>.from(_mockData.foodBeverageTransactions);
      transactions.value = loadedTransactions;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(FoodBeverageItem item) {
    final existingItem = cartItems.firstWhere(
      (cartItem) => cartItem.itemId == item.id,
      orElse: () => CartItem(
        itemId: item.id ?? 0,
        itemName: item.name,
        price: item.price,
        quantity: 0,
        subtotal: 0,
      ),
    );

    if (cartItems.contains(existingItem)) {
      existingItem.quantity++;
    } else {
      cartItems.add(CartItem(
        itemId: item.id ?? 0,
        itemName: item.name,
        price: item.price,
        quantity: 1,
        subtotal: item.price,
      ));
    }
    calculateTotal();
  }

  void removeFromCart(int itemId) {
    cartItems.removeWhere((item) => item.itemId == itemId);
    calculateTotal();
  }

  void updateCartItemQuantity(int itemId, int quantity) {
    final item = cartItems.firstWhere((cartItem) => cartItem.itemId == itemId);
    if (quantity > 0) {
      item.quantity = quantity;
    }
    calculateTotal();
  }

  void calculateTotal() {
    totalAmount.value = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    finalAmount.value = totalAmount.value - discountAmount.value + taxAmount.value;
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

  Future<void> createTransaction(FoodBeverageTransaction transaction) async {
    try {
      isLoading.value = true;
      _mockData.addFoodBeverageTransaction(transaction);
      clearCart();
      await loadTransactions();
      Get.snackbar('Berhasil', 'Transaksi berhasil dibuat');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal membuat transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearCart() {
    cartItems.clear();
    selectedMember.value = null;
    totalAmount.value = 0;
    discountAmount.value = 0;
    taxAmount.value = 0;
    finalAmount.value = 0;
  }

  void selectMember(Member member) {
    selectedMember.value = member;
  }

  Future<List<Member>> searchMembers(String query) async {
    try {
      return _mockData.searchMembers(query);
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      return _mockData.totalFoodBeverageRevenue;
    } catch (e) {
      return 0;
    }
  }

  Future<List<FoodBeverageItem>> getItemsByCategory(String category) async {
    try {
      return _mockData.getFoodBeverageItemsByCategory(category);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return _mockData.getFoodBeverageCategories();
    } catch (e) {
      return [];
    }
  }
}
