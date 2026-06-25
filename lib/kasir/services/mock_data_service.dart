import '../models/index.dart';

class MockDataService {
  MockDataService._();

  static final MockDataService instance = MockDataService._();

  final DateTime _now = DateTime.now();

  late final List<GymPackage> gymPackages = [
    GymPackage(
      id: 6,
      packageId: 'PKG-DAILY',
      name: 'Daily Pass',
      description: 'Akses gym untuk satu kali kunjungan',
      price: 60000,
      durationInDays: 1,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
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
      memberId: 'MBR-58310427',
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
      memberId: 'MBR-29174685',
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
      memberId: 'MBR-86420931',
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
      memberId: 'MBR-43751862',
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
      memberId: 'MBR-70539418',
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
      memberId: 'MBR-12684379',
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
      memberId: 'MBR-94826153',
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
      memberId: 'MBR-37290546',
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
      memberId: 'MBR-61943720',
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
      memberId: 'MBR-85317264',
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
      name: 'Chocolate Protein Shake',
      description: 'Whey protein cokelat dengan susu rendah lemak',
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
      name: 'Air Mineral Dingin',
      description: 'Air mineral botol dingin untuk hidrasi',
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
      name: 'Chicken Rice Meal Box',
      description: 'Ayam panggang, nasi, dan sayuran tinggi protein',
      category: 'Meals',
      price: 55000,
      stock: 12,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 4,
      itemId: 'FNB-004',
      name: 'Vanilla Protein Shake',
      description: 'Whey protein vanilla lembut tanpa gula tambahan',
      category: 'Drinks',
      price: 35000,
      stock: 18,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 5,
      itemId: 'FNB-005',
      name: 'Iced Black Coffee',
      description: 'Kopi hitam dingin tanpa gula untuk pre-workout',
      category: 'Drinks',
      price: 18000,
      stock: 30,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 6,
      itemId: 'FNB-006',
      name: 'Orange Electrolyte',
      description: 'Minuman elektrolit jeruk untuk recovery',
      category: 'Drinks',
      price: 22000,
      stock: 26,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 7,
      itemId: 'FNB-007',
      name: 'Beef Teriyaki Meal',
      description: 'Daging sapi, nasi, dan tumis sayuran',
      category: 'Meals',
      price: 62000,
      stock: 10,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 8,
      itemId: 'FNB-008',
      name: 'Tuna Pasta Salad',
      description: 'Pasta tuna dengan sayuran segar dan dressing ringan',
      category: 'Meals',
      price: 48000,
      stock: 9,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 9,
      itemId: 'FNB-009',
      name: 'Egg & Chicken Wrap',
      description: 'Wrap gandum isi ayam, telur, dan sayuran',
      category: 'Meals',
      price: 42000,
      stock: 15,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 10,
      itemId: 'FNB-010',
      name: 'Chocolate Protein Bar',
      description: 'Protein bar cokelat praktis setelah latihan',
      category: 'Snacks',
      price: 28000,
      stock: 35,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 11,
      itemId: 'FNB-011',
      name: 'Roasted Mixed Nuts',
      description: 'Campuran almond, mete, dan kenari panggang',
      category: 'Snacks',
      price: 25000,
      stock: 22,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageItem(
      id: 12,
      itemId: 'FNB-012',
      name: 'Banana Energy Pack',
      description: 'Pisang segar sebagai sumber energi cepat',
      category: 'Snacks',
      price: 15000,
      stock: 40,
      isActive: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  late final List<GymTransaction> gymTransactions = [
    GymTransaction(
      id: 4,
      transactionId: 'GYM-0004',
      memberId: 0,
      memberName: 'Non-member Harian',
      gymPackageId: 6,
      packageName: 'Daily Pass',
      amount: 60000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(hours: 2)),
      notes: 'Kunjungan harian non-member',
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 3,
      transactionId: 'GYM-0003',
      memberId: 0,
      memberName: 'Pendaftaran Member Baru',
      gymPackageId: 1,
      packageName: 'Paket 1 Bulan',
      amount: 299000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(hours: 5)),
      notes: 'Pembayaran member baru | Data diri melalui QR registrasi kasir',
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 1,
      transactionId: 'GYM-0001',
      memberId: 1,
      memberName: 'Andi Pratama',
      gymPackageId: 1,
      packageName: 'Paket 1 Bulan',
      amount: 199000,
      paymentMethod: 'Debit (EDC)',
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
    // ===== Bulan lalu (perbandingan grafik) =====
    GymTransaction(
      id: 5,
      transactionId: 'GYM-0005',
      memberId: 1,
      memberName: 'Andi Pratama',
      gymPackageId: 1,
      packageName: 'Paket 1 Bulan',
      amount: 199000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 1, 14),
      notes: 'Perpanjangan membership',
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 6,
      transactionId: 'GYM-0006',
      memberId: 0,
      memberName: 'Pendaftaran Member Baru',
      gymPackageId: 3,
      packageName: 'Paket 3 Bulan',
      amount: 549000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 1, 6),
      notes: 'Pembayaran member baru',
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 7,
      transactionId: 'GYM-0007',
      memberId: 0,
      memberName: 'Non-member Harian',
      gymPackageId: 6,
      packageName: 'Daily Pass',
      amount: 60000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 1, 20),
      notes: 'Kunjungan harian',
      createdAt: _now,
      updatedAt: _now,
    ),
    // ===== 2 bulan lalu =====
    GymTransaction(
      id: 8,
      transactionId: 'GYM-0008',
      memberId: 2,
      memberName: 'Sinta Lestari',
      gymPackageId: 2,
      packageName: 'Paket 2 Bulan',
      amount: 379000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 2, 12),
      notes: 'Perpanjangan membership',
      createdAt: _now,
      updatedAt: _now,
    ),
    GymTransaction(
      id: 9,
      transactionId: 'GYM-0009',
      memberId: 0,
      memberName: 'Non-member Harian',
      gymPackageId: 6,
      packageName: 'Daily Pass',
      amount: 60000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 2, 18),
      notes: 'Kunjungan harian',
      createdAt: _now,
      updatedAt: _now,
    ),
    // ===== 3 bulan lalu =====
    GymTransaction(
      id: 10,
      transactionId: 'GYM-0010',
      memberId: 0,
      memberName: 'Pendaftaran Member Baru',
      gymPackageId: 1,
      packageName: 'Paket 1 Bulan',
      amount: 299000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 3, 8),
      notes: 'Pembayaran member baru',
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
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: _now.subtract(const Duration(days: 1)),
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageTransaction(
      id: 2,
      transactionId: 'FNB-0002',
      memberId: 2,
      memberName: 'Sinta Lestari',
      items: [
        CartItem(
          itemId: 1,
          itemName: 'Protein Shake',
          price: 35000,
          quantity: 2,
          subtotal: 70000,
        ),
      ],
      totalAmount: 70000,
      discountAmount: 0,
      taxAmount: 0,
      finalAmount: 70000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 1, 10),
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageTransaction(
      id: 3,
      transactionId: 'FNB-0003',
      memberId: 1,
      memberName: 'Andi Pratama',
      items: [
        CartItem(
          itemId: 2,
          itemName: 'Mineral Water',
          price: 8000,
          quantity: 3,
          subtotal: 24000,
        ),
        CartItem(
          itemId: 3,
          itemName: 'Energy Bar',
          price: 15000,
          quantity: 1,
          subtotal: 15000,
        ),
      ],
      totalAmount: 39000,
      discountAmount: 0,
      taxAmount: 0,
      finalAmount: 39000,
      paymentMethod: 'Debit (EDC)',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 2, 9),
      createdAt: _now,
      updatedAt: _now,
    ),
    FoodBeverageTransaction(
      id: 4,
      transactionId: 'FNB-0004',
      memberId: 2,
      memberName: 'Sinta Lestari',
      items: [
        CartItem(
          itemId: 1,
          itemName: 'Protein Shake',
          price: 35000,
          quantity: 1,
          subtotal: 35000,
        ),
      ],
      totalAmount: 35000,
      discountAmount: 0,
      taxAmount: 0,
      finalAmount: 35000,
      paymentMethod: 'QRIS',
      status: 'completed',
      transactionDate: DateTime(_now.year, _now.month - 3, 15),
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
  int get _nextGymTransactionId =>
      _nextId(gymTransactions.map((trx) => trx.id));
  int get _nextFBTransactionId =>
      _nextId(foodBeverageTransactions.map((trx) => trx.id));
  int get _nextAttendanceId =>
      _nextId(attendanceRecords.map((record) => record.id));

  int _nextId(Iterable<int?> ids) {
    final existingIds = ids.whereType<int>();
    if (existingIds.isEmpty) return 1;
    return existingIds.reduce(
          (value, element) => value > element ? value : element,
        ) +
        1;
  }

  List<Member> getActiveMembers() {
    return members
        .where((member) => member.isActive && !member.isExpired)
        .toList();
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
    final index = gymTransactions.indexWhere(
      (existing) => existing.id == transaction.id,
    );
    if (index != -1) {
      gymTransactions[index] = transaction;
    }
  }

  List<GymTransaction> getGymTransactionsInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return gymTransactions.where((transaction) {
      final date = transaction.transactionDate;
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();
  }

  List<GymTransaction> getGymTransactionsByMemberId(int memberId) {
    return gymTransactions
        .where((transaction) => transaction.memberId == memberId)
        .toList();
  }

  double get totalGymRevenue {
    return gymTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  List<FoodBeverageItem> getActiveFoodBeverageItems() {
    return foodBeverageItems.where((item) => item.isActive).toList();
  }

  List<FoodBeverageItem> getFoodBeverageItemsByCategory(String category) {
    return foodBeverageItems
        .where((item) => item.category == category)
        .toList();
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

  List<FoodBeverageTransaction> getFoodBeverageTransactionsByMemberId(
    int memberId,
  ) {
    return foodBeverageTransactions
        .where((transaction) => transaction.memberId == memberId)
        .toList();
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
    final index = attendanceRecords.indexWhere(
      (record) => record.id == attendance.id,
    );
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
    return attendanceRecords
        .where((record) => record.memberId == memberId)
        .toList();
  }
}
