class GymTransaction {
  final int? id;
  final String transactionId;
  final int memberId;
  final String? memberName;
  final int gymPackageId;
  final String? packageName;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime transactionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymTransaction({
    this.id,
    required this.transactionId,
    required this.memberId,
    this.memberName,
    required this.gymPackageId,
    this.packageName,
    required this.amount,
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
      'gymPackageId': gymPackageId,
      'packageName': packageName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GymTransaction.fromMap(Map<String, dynamic> map) {
    return GymTransaction(
      id: map['id'],
      transactionId: map['transactionId'],
      memberId: map['memberId'],
      memberName: map['memberName'],
      gymPackageId: map['gymPackageId'],
      packageName: map['packageName'],
      amount: map['amount'].toDouble(),
      paymentMethod: map['paymentMethod'],
      status: map['status'],
      transactionDate: DateTime.parse(map['transactionDate']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
