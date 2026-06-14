class Member {
  final int? id;
  final String memberId;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime dateOfBirth;
  final String gymPackageId;
  final DateTime registrationDate;
  final DateTime membershipExpiryDate;
  final bool isActive;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    this.id,
    required this.memberId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.gymPackageId,
    required this.registrationDate,
    required this.membershipExpiryDate,
    required this.isActive,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gymPackageId': gymPackageId,
      'registrationDate': registrationDate.toIso8601String(),
      'membershipExpiryDate': membershipExpiryDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      memberId: map['memberId'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      gender: map['gender'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      gymPackageId: map['gymPackageId'],
      registrationDate: DateTime.parse(map['registrationDate']),
      membershipExpiryDate: DateTime.parse(map['membershipExpiryDate']),
      isActive: map['isActive'] == 1,
      photoPath: map['photoPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  bool get isExpired {
    return DateTime.now().isAfter(membershipExpiryDate);
  }

  int get daysUntilExpiry {
    return membershipExpiryDate.difference(DateTime.now()).inDays;
  }
}
