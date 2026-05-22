import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class TransactionHistoryRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert TransactionHistory
  Future<int> insertTransactionHistory(TransactionHistory transactionHistory) async {
    final db = await _db;
    return await db.insert('transaction_history', transactionHistory.toMap());
  }

  // Get all transaction history
  Future<List<TransactionHistory>> getAllTransactionHistory() async {
    final db = await _db;
    final result = await db.query('transaction_history', orderBy: 'transactionDate DESC');
    return result.map((map) => TransactionHistory.fromMap(map)).toList();
  }

  // Get transaction history by member ID
  Future<List<TransactionHistory>> getTransactionHistoryByMemberId(int memberId) async {
    final db = await _db;
    final result = await db.query(
      'transaction_history',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => TransactionHistory.fromMap(map)).toList();
  }

  // Get transaction history by transaction ID
  Future<TransactionHistory?> getTransactionHistoryByTransactionId(String transactionId) async {
    final db = await _db;
    final result = await db.query(
      'transaction_history',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    if (result.isEmpty) return null;
    return TransactionHistory.fromMap(result.first);
  }

  // Get transaction history within date range
  Future<List<TransactionHistory>> getTransactionHistoryWithinDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _db;
    final result = await db.query(
      'transaction_history',
      where: 'transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => TransactionHistory.fromMap(map)).toList();
  }

  // Get transaction history by type
  Future<List<TransactionHistory>> getTransactionHistoryByType(String transactionType) async {
    final db = await _db;
    final result = await db.query(
      'transaction_history',
      where: 'transactionType = ?',
      whereArgs: [transactionType],
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => TransactionHistory.fromMap(map)).toList();
  }

  // Update transaction history
  Future<int> updateTransactionHistory(TransactionHistory transactionHistory) async {
    final db = await _db;
    return await db.update(
      'transaction_history',
      transactionHistory.toMap(),
      where: 'id = ?',
      whereArgs: [transactionHistory.id],
    );
  }

  // Delete transaction history
  Future<int> deleteTransactionHistory(int id) async {
    final db = await _db;
    return await db.delete(
      'transaction_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total amount by type
  Future<double> getTotalAmountByType(String transactionType) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transaction_history WHERE transactionType = ?',
      [transactionType],
    );
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
