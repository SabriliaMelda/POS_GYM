class GymPackage {
  final int? id;
  final String packageId;
  final String name;
  final String description;
  final double price;
  final String packageType;
  final int durationInDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymPackage({
    this.id,
    required this.packageId,
    required this.name,
    required this.description,
    required this.price,
    String? packageType,
    required this.durationInDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : packageType = packageType ??
            (packageId == 'PKG-DAILY' ? 'daily' : 'membership');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageId': packageId,
      'name': name,
      'description': description,
      'price': price,
      'packageType': packageType,
      'durationInDays': durationInDays,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GymPackage.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.tryParse(
      (map['createdAt'] ?? map['created_at'])?.toString() ?? '',
    );
    final updatedAt = DateTime.tryParse(
      (map['updatedAt'] ?? map['updated_at'])?.toString() ?? '',
    );
    final active = map['isActive'] ?? map['is_active'];
    return GymPackage(
      id: (map['id'] as num?)?.toInt(),
      packageId:
          (map['packageId'] ?? map['package_code'])?.toString() ?? '',
      name: (map['name'] ?? map['package_name'])?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      packageType:
          (map['packageType'] ?? map['package_type'])?.toString(),
      durationInDays:
          ((map['durationInDays'] ?? map['duration_days']) as num?)?.toInt() ??
          1,
      isActive: active == true || active == 1,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
