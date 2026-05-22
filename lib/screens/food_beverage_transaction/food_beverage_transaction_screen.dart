import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/food_beverage_transaction_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../utils/utils.dart';

class FoodBeverageTransactionScreen extends StatelessWidget {
  const FoodBeverageTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FoodBeverageTransactionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Beverage'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Cart Summary
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cart Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Items:'),
                          Text(
                            controller.cartItems.length.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:'),
                          Text(
                            CurrencyUtils.formatCurrency(controller.totalAmount.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'New Transaction',
                              onPressed: () => controller.clearCart(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Checkout',
                              onPressed: () {
                                if (controller.cartItems.isEmpty) {
                                  Get.snackbar('Error', 'Cart is empty');
                                } else {
                                  Get.snackbar('UI Preview', 'Checkout belum diaktifkan.');
                                }
                              },
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Items List
          Expanded(
            child: Obx(
              () => controller.items.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No Items Available',
                      subtitle: 'Add items to get started',
                      icon: Icons.shopping_cart_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        return _buildItemCard(item, controller);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    FoodBeverageItem item,
    FoodBeverageTransactionController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatCurrency(item.price),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${item.stock}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Add to Cart Button
            FloatingActionButton.small(
              onPressed: () => controller.addToCart(item),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
