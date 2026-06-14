import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class GymTransactionRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert GymTransaction
  Future<int> insertGymTransaction(GymTransaction transaction) async {
    final db = await _db;
    return await db.insert('gym_transactions', transaction.toMap());
  }

  // Get all gym transactions
  Future<List<GymTransaction>> getAllGymTransactions() async {
    final db = await _db;
    final result = await db.query(
      'gym_transactions',
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => GymTransaction.fromMap(map)).toList();
  }

  // Get gym transactions by member ID
  Future<List<GymTransaction>> getGymTransactionsByMemberId(
    int memberId,
  ) async {
    final db = await _db;
    final result = await db.query(
      'gym_transactions',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => GymTransaction.fromMap(map)).toList();
  }

  // Get gym transaction by ID
  Future<GymTransaction?> getGymTransactionById(int id) async {
    final db = await _db;
    final result = await db.query(
      'gym_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return GymTransaction.fromMap(result.first);
  }

  // Get gym transaction by transaction ID
  Future<GymTransaction?> getGymTransactionByTransactionId(
    String transactionId,
  ) async {
    final db = await _db;
    final result = await db.query(
      'gym_transactions',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    if (result.isEmpty) return null;
    return GymTransaction.fromMap(result.first);
  }

  // Get gym transactions within date range
  Future<List<GymTransaction>> getGymTransactionsWithinDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.query(
      'gym_transactions',
      where: 'transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => GymTransaction.fromMap(map)).toList();
  }

  // Update gym transaction
  Future<int> updateGymTransaction(GymTransaction transaction) async {
    final db = await _db;
    return await db.update(
      'gym_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete gym transaction
  Future<int> deleteGymTransaction(int id) async {
    final db = await _db;
    return await db.delete(
      'gym_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total revenue from gym transactions
  Future<double> getTotalGymRevenue() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM gym_transactions WHERE status = "completed"',
    );
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Get total gym revenue within date range
  Future<double> getTotalGymRevenueWithinDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM gym_transactions WHERE status = "completed" AND transactionDate >= ? AND transactionDate <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Get transaction count
  Future<int> getTransactionCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM gym_transactions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
