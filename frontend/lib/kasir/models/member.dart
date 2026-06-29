/// Voucher F&B milik member dengan status lifecycle dari backend.
/// status: 'active' (aktif, bisa dipakai) | 'used' (dipakai) | 'expired' (hangus).
class MemberVoucher {
  const MemberVoucher({
    required this.percent,
    required this.visitMilestone,
    required this.activatedAt,
    required this.expiresAt,
    required this.usedAt,
    required this.status,
  });

  final int percent;
  final int visitMilestone;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String status;

  bool get used => status == 'used';
  bool get expired => status == 'expired';
  bool get active => status == 'active';

  factory MemberVoucher.fromApiJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime.now();
    DateTime? parseNullableDate(dynamic value) {
      final text = value?.toString() ?? '';
      if (text.isEmpty) return null;
      return DateTime.tryParse(text)?.toLocal();
    }

    return MemberVoucher(
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      visitMilestone: (json['visit_milestone'] as num?)?.toInt() ?? 0,
      activatedAt: parseDate(json['activated_at']),
      expiresAt: parseDate(json['expires_at']),
      usedAt: parseNullableDate(json['used_at']),
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class MemberRenewal {
  const MemberRenewal({
    required this.packageCode,
    required this.packageName,
    required this.previousExpiryDate,
    required this.newExpiryDate,
    required this.amount,
    required this.renewedAt,
  });

  final String packageCode;
  final String packageName;
  final DateTime? previousExpiryDate;
  final DateTime newExpiryDate;
  final double amount;
  final DateTime renewedAt;

  factory MemberRenewal.fromApiJson(Map<String, dynamic> json) {
    DateTime? parseNullableDate(dynamic value) {
      final text = value?.toString() ?? '';
      if (text.isEmpty) return null;
      return DateTime.tryParse(text)?.toLocal();
    }

    return MemberRenewal(
      packageCode: json['package_code']?.toString() ?? '',
      packageName: json['package_name']?.toString() ?? '',
      previousExpiryDate: parseNullableDate(json['previous_expiry_date']),
      newExpiryDate: parseNullableDate(json['new_expiry_date']) ?? DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      renewedAt: parseNullableDate(json['renewed_at']) ?? DateTime.now(),
    );
  }
}

class MemberFollowUp {
  const MemberFollowUp({
    required this.recipientEmail,
    required this.subject,
    required this.type,
    required this.sentAt,
  });

  final String recipientEmail;
  final String subject;
  final String type;
  final DateTime sentAt;

  factory MemberFollowUp.fromApiJson(Map<String, dynamic> json) {
    return MemberFollowUp(
      recipientEmail: json['recipient_email']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sentAt:
          DateTime.tryParse(json['sent_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

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

  /// Paket saat pertama kali daftar. Tidak berubah walau diperpanjang dengan
  /// paket lain. Dipakai untuk menampilkan "paket pendaftaran awal".
  final String initialPackageId;
  final DateTime registrationDate;
  final DateTime membershipExpiryDate;
  final bool isActive;
  final String? photoPath;
  final int totalVisits;
  final List<MemberVoucher> vouchers;
  final List<MemberRenewal> renewals;
  final List<MemberFollowUp> followUps;
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
    this.initialPackageId = '',
    required this.registrationDate,
    required this.membershipExpiryDate,
    required this.isActive,
    this.photoPath,
    this.totalVisits = 0,
    this.vouchers = const [],
    this.renewals = const [],
    this.followUps = const [],
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

  factory Member.fromApiJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      return (parsed ?? DateTime.now()).toLocal();
    }

    final active = json['is_active'];
    final vouchers =
        (json['vouchers'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MemberVoucher.fromApiJson)
            .toList() ??
        const <MemberVoucher>[];
    final renewals =
        (json['renewals'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MemberRenewal.fromApiJson)
            .toList() ??
        const <MemberRenewal>[];
    final followUps =
        (json['follow_ups'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MemberFollowUp.fromApiJson)
            .toList() ??
        const <MemberFollowUp>[];
    return Member(
      id: (json['id'] as num?)?.toInt(),
      memberId: json['member_code']?.toString() ?? '',
      name: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: parseDate(json['date_of_birth']),
      gymPackageId: json['package_code']?.toString() ?? '',
      initialPackageId:
          json['initial_package_code']?.toString() ??
          json['package_code']?.toString() ??
          '',
      registrationDate: parseDate(json['registration_date']),
      membershipExpiryDate: parseDate(json['membership_expiry_date']),
      isActive: active == true || active == 1,
      photoPath: json['photo_path']?.toString(),
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 0,
      vouchers: vouchers,
      renewals: renewals,
      followUps: followUps,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  bool get isExpired {
    return DateTime.now().isAfter(membershipExpiryDate);
  }

  int get daysUntilExpiry {
    return membershipExpiryDate.difference(DateTime.now()).inDays;
  }
}
