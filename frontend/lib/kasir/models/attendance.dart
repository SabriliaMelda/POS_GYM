class Attendance {
  final int? id;
  final int memberId;
  final String? memberName;
  final DateTime attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? rfidCardNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    this.id,
    required this.memberId,
    this.memberName,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.rfidCardNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'attendanceDate': attendanceDate.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'rfidCardNumber': rfidCardNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Attendance.fromApiJson(Map<String, dynamic> json) {
    final date =
        DateTime.tryParse(json['attendance_date']?.toString() ?? '') ??
        DateTime.tryParse(
          json['check_in_at']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();
    return Attendance(
      id: (json['id'] as num?)?.toInt(),
      memberId: 0,
      memberName: json['member_name']?.toString(),
      attendanceDate: date,
      checkInTime: json['check_in_time']?.toString(),
      rfidCardNumber: 'BARCODE:${json['member_code'] ?? ''}',
      createdAt: date,
      updatedAt: date,
    );
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      memberId: map['memberId'],
      memberName: map['memberName'],
      attendanceDate: DateTime.parse(map['attendanceDate']),
      checkInTime: map['checkInTime'],
      checkOutTime: map['checkOutTime'],
      rfidCardNumber: map['rfidCardNumber'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
