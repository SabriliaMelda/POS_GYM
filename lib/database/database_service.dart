import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initializeDatabase() async {
    final databasesPath = await sqflite.getDatabasesPath();
    final path = join(databasesPath, 'pos_gym.db');

    return sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(sqflite.Database db, int version) async {
    // Members table
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        address TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        gymPackageId TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        membershipExpiryDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        photoPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Gym packages table
    await db.execute('''
      CREATE TABLE gym_packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        durationInDays INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Gym transactions table
    await db.execute('''
      CREATE TABLE gym_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT UNIQUE NOT NULL,
        memberId INTEGER NOT NULL,
        memberName TEXT,
        gymPackageId INTEGER NOT NULL,
        packageName TEXT,
        amount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members(id)
      )
    ''');

    // Food and beverage items table
    await db.execute('''
      CREATE TABLE food_beverage_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Food and beverage transactions table
    await db.execute('''
      CREATE TABLE food_beverage_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT UNIQUE NOT NULL,
        memberId INTEGER,
        memberName TEXT,
        items TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        discountAmount REAL,
        taxAmount REAL,
        finalAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members(id)
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId INTEGER NOT NULL,
        memberName TEXT,
        attendanceDate TEXT NOT NULL,
        checkInTime TEXT,
        checkOutTime TEXT,
        rfidCardNumber TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members(id)
      )
    ''');

    // Transaction history table
    await db.execute('''
      CREATE TABLE transaction_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT UNIQUE NOT NULL,
        memberId INTEGER,
        memberName TEXT,
        transactionType TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members(id)
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_members_memberId ON members(memberId)');
    await db.execute('CREATE INDEX idx_members_isActive ON members(isActive)');
    await db.execute('CREATE INDEX idx_gym_transactions_memberId ON gym_transactions(memberId)');
    await db.execute('CREATE INDEX idx_gym_transactions_transactionDate ON gym_transactions(transactionDate)');
    await db.execute('CREATE INDEX idx_food_transactions_memberId ON food_beverage_transactions(memberId)');
    await db.execute('CREATE INDEX idx_food_transactions_transactionDate ON food_beverage_transactions(transactionDate)');
    await db.execute('CREATE INDEX idx_attendance_memberId ON attendance(memberId)');
    await db.execute('CREATE INDEX idx_attendance_attendanceDate ON attendance(attendanceDate)');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await sqflite.getDatabasesPath();
    final path = join(databasesPath, 'pos_gym.db');
    await sqflite.deleteDatabase(path);
  }
}
