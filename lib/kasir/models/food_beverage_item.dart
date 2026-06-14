class FoodBeverageItem {
  final int? id;
  final String itemId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodBeverageItem({
    this.id,
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FoodBeverageItem.fromMap(Map<String, dynamic> map) {
    return FoodBeverageItem(
      id: map['id'],
      itemId: map['itemId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'].toDouble(),
      stock: map['stock'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
