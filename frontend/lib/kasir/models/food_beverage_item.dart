class FoodBeverageItem {
  final int? id;
  final String itemId;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? memberPrice;
  final int stock;
  final String? imagePath;
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
    this.memberPrice,
    required this.stock,
    this.imagePath,
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

  factory FoodBeverageItem.fromApiJson(Map<String, dynamic> json) {
    double numberValue(String key) => (json[key] as num?)?.toDouble() ?? 0;
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? '');

    return FoodBeverageItem(
      id: (json['id'] as num?)?.toInt(),
      itemId: json['item_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      memberPrice: numberValue('member_price'),
      price: numberValue('price'),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imagePath: json['image_path']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
