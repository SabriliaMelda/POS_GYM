import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class FoodBeverageTransactionRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert FoodBeverageTransaction
  Future<int> insertFoodBeverageTransaction(
    FoodBeverageTransaction transaction,
  ) async {
    final db = await _db;
    return await db.insert('food_beverage_transactions', transaction.toMap());
  }

  // Get all food and beverage transactions
  Future<List<FoodBeverageTransaction>> getAllFoodBeverageTransactions() async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_transactions',
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => FoodBeverageTransaction.fromMap(map)).toList();
  }

  // Get food and beverage transactions by member ID
  Future<List<FoodBeverageTransaction>> getFoodBeverageTransactionsByMemberId(
    int memberId,
  ) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_transactions',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => FoodBeverageTransaction.fromMap(map)).toList();
  }

  // Get food and beverage transaction by ID
  Future<FoodBeverageTransaction?> getFoodBeverageTransactionById(
    int id,
  ) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return FoodBeverageTransaction.fromMap(result.first);
  }

  // Get food and beverage transactions within date range
  Future<List<FoodBeverageTransaction>>
  getFoodBeverageTransactionsWithinDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_transactions',
      where: 'transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => FoodBeverageTransaction.fromMap(map)).toList();
  }

  // Update food and beverage transaction
  Future<int> updateFoodBeverageTransaction(
    FoodBeverageTransaction transaction,
  ) async {
    final db = await _db;
    return await db.update(
      'food_beverage_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete food and beverage transaction
  Future<int> deleteFoodBeverageTransaction(int id) async {
    final db = await _db;
    return await db.delete(
      'food_beverage_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total revenue from food and beverage transactions
  Future<double> getTotalFoodBeverageRevenue() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(finalAmount) as total FROM food_beverage_transactions WHERE status = "completed"',
    );
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Get total food and beverage revenue within date range
  Future<double> getTotalFoodBeverageRevenueWithinDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(finalAmount) as total FROM food_beverage_transactions WHERE status = "completed" AND transactionDate >= ? AND transactionDate <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Get transaction count
  Future<int> getTransactionCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM food_beverage_transactions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
