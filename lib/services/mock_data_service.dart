import '../models/index.dart';

class MockDataService {
  MockDataService._();

  static final MockDataService instance = MockDataService._();

  final DateTime _now = DateTime.now();

  late final List<GymPackage> gymPackages = [
    GymPackage(
      id: 1,
      packageId: 'PKG-001',
      name: 'Paket 1 Bulan',
      description: 'Akses gym penuh selama 30 hari',
      price: 199000,
      durationInDays: 30,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    GymPackage(
      id: 2,
      packageId: 'PKG-002',
      name: 'Paket 2 Bulan',
      description: 'Akses gym penuh selama 60 hari',
      price: 379000,
      durationInDays: 60,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    GymPackage(
      id: 3,
      packageId: 'PKG-003',
      name: 'Paket 4 Bulan',
      description: 'Akses gym penuh selama 120 hari',
      price: 699000,
      durationInDays: 120,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    GymPackage(
      id: 4,
      packageId: 'PKG-004',
      name: 'Paket 6 Bulan',
      description: 'Akses gym penuh selama 180 hari',
      price: 999000,
      durationInDays: 180,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    GymPackage(
      id: 5,
      packageId: 'PKG-005',
      name: 'Paket 1 Tahun',
      description: 'Akses gym penuh selama 365 hari',
      price: 1799000,
      durationInDays: 365,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<Member> members = [
    Member(
      id: 1,
      memberId: 'MBR-001',
      name: 'Andi Pratama',
      email: 'andi@example.com',
      phoneNumber: '081234567890',
      address: 'Jakarta Selatan',
      gender: 'Male',
      dateOfBirth: DateTime(1996, 4, 12),
      gymPackageId: 'PKG-001',
      registrationDate: _now.subtract(const Duration(days: 12)),
      membershipExpiryDate: _now.add(const Duration(days: 18)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 2,
      memberId: 'MBR-002',
      name: 'Sinta Lestari',
      email: 'sinta@example.com',
      phoneNumber: '082112223333',
      address: 'Tangerang',
      gender: 'Female',
      dateOfBirth: DateTime(1999, 9, 21),
      gymPackageId: 'PKG-002',
      registrationDate: _now.subtract(const Duration(days: 35)),
      membershipExpiryDate: _now.add(const Duration(days: 55)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 3,
      memberId: 'MBR-003',
      name: 'Budi Santoso',
      email: 'budi@example.com',
      phoneNumber: '085677778888',
      address: 'Bekasi',
      gender: 'Male',
      dateOfBirth: DateTime(1992, 1, 7),
      gymPackageId: 'PKG-001',
      registrationDate: _now.subtract(const Duration(days: 50)),
      membershipExpiryDate: _now.subtract(const Duration(days: 3)),
      isActive: false,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 4,
      memberId: 'MBR-004',
      name: 'Rina Maharani',
      email: 'rina@example.com',
      phoneNumber: '087700001111',
      address: 'Jakarta Barat',
      gender: 'Female',
      dateOfBirth: DateTime(1998, 6, 18),
      gymPackageId: 'PKG-001',
      registrationDate: _now.subtract(const Duration(days: 28)),
      membershipExpiryDate: _now.add(const Duration(days: 2)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 5,
      memberId: 'MBR-005',
      name: 'Dimas Putra',
      email: 'dimas@example.com',
      phoneNumber: '087700002222',
      address: 'Depok',
      gender: 'Male',
      dateOfBirth: DateTime(1995, 11, 9),
      gymPackageId: 'PKG-002',
      registrationDate: _now.subtract(const Duration(days: 21)),
      membershipExpiryDate: _now.add(const Duration(days: 69)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 6,
      memberId: 'MBR-006',
      name: 'Maya Kartika',
      email: 'maya@example.com',
      phoneNumber: '087700003333',
      address: 'Tangerang Selatan',
      gender: 'Female',
      dateOfBirth: DateTime(2000, 2, 14),
      gymPackageId: 'PKG-001',
      registrationDate: _now.subtract(const Duration(days: 20)),
      membershipExpiryDate: _now.add(const Duration(days: 10)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 7,
      memberId: 'MBR-007',
      name: 'Fajar Nugroho',
      email: 'fajar@example.com',
      phoneNumber: '087700004444',
      address: 'Jakarta Timur',
      gender: 'Male',
      dateOfBirth: DateTime(1994, 8, 3),
      gymPackageId: 'PKG-003',
      registrationDate: _now.subtract(const Duration(days: 13)),
      membershipExpiryDate: _now.add(const Duration(days: 1)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 8,
      memberId: 'MBR-008',
      name: 'Laras Wulandari',
      email: 'laras@example.com',
      phoneNumber: '087700005555',
      address: 'Bekasi',
      gender: 'Female',
      dateOfBirth: DateTime(1997, 12, 27),
      gymPackageId: 'PKG-001',
      registrationDate: _now.subtract(const Duration(days: 2)),
      membershipExpiryDate: _now.add(const Duration(days: 24)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 9,
      memberId: 'MBR-009',
      name: 'Yoga Saputra',
      email: 'yoga@example.com',
      phoneNumber: '087700006666',
      address: 'Jakarta Utara',
      gender: 'Male',
      dateOfBirth: DateTime(1993, 5, 5),
      gymPackageId: 'PKG-002',
      registrationDate: _now.subtract(const Duration(days: 1)),
      membershipExpiryDate: _now.add(const Duration(days: 85)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    Member(
      id: 10,
      memberId: 'MBR-010',
      name: 'Nadia Prameswari',
      email: 'nadia@example.com',
      phoneNumber: '087700007777',
      address: 'Jakarta Pusat',
      gender: 'Female',
      dateOfBirth: DateTime(1999, 7, 30),
      gymPackageId: 'PKG-001',
      registrationDate: _now,
      membershipExpiryDate: _now.add(const Duration(days: 26)),
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<FoodBeverageItem> foodBeverageItems = [
    FoodBeverageItem(
      id: 1,
      itemId: 'FNB-001',
      name: 'Protein Shake',
      description: 'Chocolate whey protein',
      category: 'Drinks',
      price: 35000,
      stock: 24,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 2,
      itemId: 'FNB-002',
      name: 'Mineral Water',
      description: 'Cold bottled water',
      category: 'Drinks',
      price: 8000,
      stock: 60,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 3,
      itemId: 'FNB-003',
      name: 'Chicken Meal Box',
      description: 'High protein meal',
      category: 'Meals',
      price: 55000,
      stock: 12,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<GymTransaction> gymTransactions = [
    GymTransaction(
      id: 1,
      transactionId: 'GYM-0001',
      memberId: 1,
      memberName: 'Andi Pratama',
      gymPackageId: 1,
      packageName: 'Paket 1 Bulan',
      amount: 199000,
      paymentMethod: 'Cash',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(days: 2)),
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 2,
      transactionId: 'GYM-0002',
      memberId: 2,
      memberName: 'Sinta Lestari',
      gymPackageId: 2,
      packageName: 'Paket 2 Bulan',
      amount: 379000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(days: 5)),
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<FoodBeverageTransaction> foodBeverageTransactions = [
    FoodBeverageTransaction(
      id: 1,
      transactionId: 'FNB-0001',
      memberId: 1,
      memberName: 'Andi Pratama',
      items: [
        CartItem(
          itemId: 1,
          itemName: 'Protein Shake',
          price: 35000,
          quantity: 1,
          subtotal: 35000,
        ),
        CartItem(
          itemId: 2,
          itemName: 'Mineral Water',
          price: 8000,
          quantity: 2,
          subtotal: 16000,
        ),
      ],
      totalAmount: 51000,
      discountAmount: 0,
      taxAmount: 0,
      finalAmount: 51000,
      paymentMethod: 'Cash',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(days: 1)),
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<Attendance> attendanceRecords = [
    Attendance(
      id: 1,
      memberId: 1,
      memberName: 'Andi Pratama',
      attendanceDate: _now,
      checkInTime: '08:15',
      rfidCardNumber: 'RFID-001',
      createdAt: _now,
      updatedAt: _now,
    ),
    Attendance(
      id: 2,
      memberId: 2,
      memberName: 'Sinta Lestari',
      attendanceDate: _now,
      checkInTime: '10:30',
      rfidCardNumber: 'RFID-002',
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  int get _nextMemberId => _nextId(members.map((member) => member.id));
  int get _nextGymTransactionId => _nextId(gymTransactions.map((trx) => trx.id));
  int get _nextFBTransactionId => _nextId(foodBeverageTransactions.map((trx) => trx.id));
  int get _nextAttendanceId => _nextId(attendanceRecords.map((record) => record.id));

  int _nextId(Iterable<int?> ids) {
    final existingIds = ids.whereType<int>();
    if (existingIds.isEmpty) return 1;
    return existingIds.reduce((value, element) => value > element ? value : element) + 1;
  }

  List<Member> getActiveMembers() {
    return members.where((member) => member.isActive && !member.isExpired).toList();
  }

  List<Member> getExpiredMembers() {
    return members.where((member) => member.isExpired).toList();
  }

  Member? getMemberById(int memberId) {
    return members.cast<Member?>().firstWhere(
          (member) => member?.id == memberId,
          orElse: () => null,
        );
  }

  List<Member> searchMembers(String query) {
    final normalizedQuery = query.toLowerCase();
    return members
        .where(
          (member) =>
              member.name.toLowerCase().contains(normalizedQuery) ||
              member.memberId.toLowerCase().contains(normalizedQuery) ||
              member.phoneNumber.contains(query),
        )
        .toList();
  }

  void addMember(Member member) {
    members.add(
      Member(
        id: member.id ?? _nextMemberId,
        memberId: member.memberId,
        name: member.name,
        email: member.email,
        phoneNumber: member.phoneNumber,
        address: member.address,
        gender: member.gender,
        dateOfBirth: member.dateOfBirth,
        gymPackageId: member.gymPackageId,
        registrationDate: member.registrationDate,
        membershipExpiryDate: member.membershipExpiryDate,
        isActive: member.isActive,
        photoPath: member.photoPath,
        createdAt: member.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void updateMember(Member member) {
    final index = members.indexWhere((existing) => existing.id == member.id);
    if (index != -1) {
      members[index] = member;
    }
  }

  void deleteMember(int memberId) {
    members.removeWhere((member) => member.id == memberId);
  }

  List<GymPackage> getActiveGymPackages() {
    return gymPackages.where((package) => package.isActive).toList();
  }

  void addGymTransaction(GymTransaction transaction) {
    gymTransactions.insert(
      0,
      GymTransaction(
        id: transaction.id ?? _nextGymTransactionId,
        transactionId: transaction.transactionId,
        memberId: transaction.memberId,
        memberName: transaction.memberName,
        gymPackageId: transaction.gymPackageId,
        packageName: transaction.packageName,
        amount: transaction.amount,
        paymentMethod: transaction.paymentMethod,
        status: transaction.status,
        transactionDate: transaction.transactionDate,
        notes: transaction.notes,
        createdAt: transaction.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void updateGymTransaction(GymTransaction transaction) {
    final index = gymTransactions.indexWhere((existing) => existing.id == transaction.id);
    if (index != -1) {
      gymTransactions[index] = transaction;
    }
  }

  List<GymTransaction> getGymTransactionsInRange(DateTime startDate, DateTime endDate) {
    return gymTransactions.where((transaction) {
      final date = transaction.transactionDate;
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();
  }

  List<GymTransaction> getGymTransactionsByMemberId(int memberId) {
    return gymTransactions.where((transaction) => transaction.memberId == memberId).toList();
  }

  double get totalGymRevenue {
    return gymTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<FoodBeverageItem> getActiveFoodBeverageItems() {
    return foodBeverageItems.where((item) => item.isActive).toList();
  }

  List<FoodBeverageItem> getFoodBeverageItemsByCategory(String category) {
    return foodBeverageItems.where((item) => item.category == category).toList();
  }

  List<String> getFoodBeverageCategories() {
    return foodBeverageItems.map((item) => item.category).toSet().toList();
  }

  void addFoodBeverageTransaction(FoodBeverageTransaction transaction) {
    foodBeverageTransactions.insert(
      0,
      FoodBeverageTransaction(
        id: transaction.id ?? _nextFBTransactionId,
        transactionId: transaction.transactionId,
        memberId: transaction.memberId,
        memberName: transaction.memberName,
        items: List<CartItem>.from(transaction.items),
        totalAmount: transaction.totalAmount,
        discountAmount: transaction.discountAmount,
        taxAmount: transaction.taxAmount,
        finalAmount: transaction.finalAmount,
        paymentMethod: transaction.paymentMethod,
        status: transaction.status,
        transactionDate: transaction.transactionDate,
        notes: transaction.notes,
        createdAt: transaction.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<FoodBeverageTransaction> getFoodBeverageTransactionsInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return foodBeverageTransactions.where((transaction) {
      final date = transaction.transactionDate;
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();
  }

  List<FoodBeverageTransaction> getFoodBeverageTransactionsByMemberId(int memberId) {
    return foodBeverageTransactions.where((transaction) => transaction.memberId == memberId).toList();
  }

  double get totalFoodBeverageRevenue {
    return foodBeverageTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.finalAmount,
    );
  }

  List<Attendance> getTodayAttendance() {
    final now = DateTime.now();
    return attendanceRecords.where((record) {
      return record.attendanceDate.year == now.year &&
          record.attendanceDate.month == now.month &&
          record.attendanceDate.day == now.day;
    }).toList();
  }

  void addAttendance(Attendance attendance) {
    attendanceRecords.insert(
      0,
      Attendance(
        id: attendance.id ?? _nextAttendanceId,
        memberId: attendance.memberId,
        memberName: attendance.memberName,
        attendanceDate: attendance.attendanceDate,
        checkInTime: attendance.checkInTime,
        checkOutTime: attendance.checkOutTime,
        rfidCardNumber: attendance.rfidCardNumber,
        createdAt: attendance.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Attendance? getAttendanceById(int attendanceId) {
    return attendanceRecords.cast<Attendance?>().firstWhere(
          (record) => record?.id == attendanceId,
          orElse: () => null,
        );
  }

  void updateAttendance(Attendance attendance) {
    final index = attendanceRecords.indexWhere((record) => record.id == attendance.id);
    if (index != -1) {
      attendanceRecords[index] = attendance;
    }
  }

  int getAttendanceCountByDate(DateTime date) {
    return attendanceRecords.where((record) {
      return record.attendanceDate.year == date.year &&
          record.attendanceDate.month == date.month &&
          record.attendanceDate.day == date.day;
    }).length;
  }

  List<Attendance> getAttendanceByMemberId(int memberId) {
    return attendanceRecords.where((record) => record.memberId == memberId).toList();
  }
}
