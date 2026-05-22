class FoodBeverageTransaction {
  final int? id;
  final String transactionId;
  final int? memberId;
  final String? memberName;
  final List<CartItem> items;
  final double totalAmount;
  final double? discountAmount;
  final double? taxAmount;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final DateTime transactionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodBeverageTransaction({
    this.id,
    required this.transactionId,
    this.memberId,
    this.memberName,
    required this.items,
    required this.totalAmount,
    this.discountAmount,
    this.taxAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    required this.transactionDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'memberId': memberId,
      'memberName': memberName,
      'items': items.map((e) => e.toMap()).toList().toString(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FoodBeverageTransaction.fromMap(Map<String, dynamic> map) {
    return FoodBeverageTransaction(
      id: map['id'],
      transactionId: map['transactionId'],
      memberId: map['memberId'],
      memberName: map['memberName'],
      items: [],
      totalAmount: map['totalAmount'].toDouble(),
      discountAmount: map['discountAmount']?.toDouble(),
      taxAmount: map['taxAmount']?.toDouble(),
      finalAmount: map['finalAmount'].toDouble(),
      paymentMethod: map['paymentMethod'],
      status: map['status'],
      transactionDate: DateTime.parse(map['transactionDate']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class CartItem {
  final int itemId;
  final String itemName;
  final double price;
  int quantity;
  final double subtotal;

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
