class TransactionHistory {
  final int? id;
  final String transactionId;
  final int? memberId;
  final String? memberName;
  final String transactionType;
  final double amount;
  final String description;
  final String status;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionHistory({
    this.id,
    required this.transactionId,
    this.memberId,
    this.memberName,
    required this.transactionType,
    required this.amount,
    required this.description,
    required this.status,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'memberId': memberId,
      'memberName': memberName,
      'transactionType': transactionType,
      'amount': amount,
      'description': description,
      'status': status,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionHistory.fromMap(Map<String, dynamic> map) {
    return TransactionHistory(
      id: map['id'],
      transactionId: map['transactionId'],
      memberId: map['memberId'],
      memberName: map['memberName'],
      transactionType: map['transactionType'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      status: map['status'],
      transactionDate: DateTime.parse(map['transactionDate']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
