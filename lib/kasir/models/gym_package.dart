class GymPackage {
  final int? id;
  final String packageId;
  final String name;
  final String description;
  final double price;
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
    required this.durationInDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageId': packageId,
      'name': name,
      'description': description,
      'price': price,
      'durationInDays': durationInDays,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GymPackage.fromMap(Map<String, dynamic> map) {
    return GymPackage(
      id: map['id'],
      packageId: map['packageId'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      durationInDays: map['durationInDays'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
