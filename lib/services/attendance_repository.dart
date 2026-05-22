import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class AttendanceRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert Attendance
  Future<int> insertAttendance(Attendance attendance) async {
    final db = await _db;
    return await db.insert('attendance', attendance.toMap());
  }

  // Get all attendance records
  Future<List<Attendance>> getAllAttendance() async {
    final db = await _db;
    final result = await db.query('attendance', orderBy: 'attendanceDate DESC');
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  // Get attendance by member ID
  Future<List<Attendance>> getAttendanceByMemberId(int memberId) async {
    final db = await _db;
    final result = await db.query(
      'attendance',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'attendanceDate DESC',
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  // Get attendance by member ID within date range
  Future<List<Attendance>> getAttendanceByMemberIdWithinDateRange(int memberId, DateTime startDate, DateTime endDate) async {
    final db = await _db;
    final result = await db.query(
      'attendance',
      where: 'memberId = ? AND attendanceDate >= ? AND attendanceDate <= ?',
      whereArgs: [memberId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'attendanceDate DESC',
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  // Get attendance record by ID
  Future<Attendance?> getAttendanceById(int id) async {
    final db = await _db;
    final result = await db.query(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Attendance.fromMap(result.first);
  }

  // Get attendance within date range
  Future<List<Attendance>> getAttendanceWithinDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _db;
    final result = await db.query(
      'attendance',
      where: 'attendanceDate >= ? AND attendanceDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'attendanceDate DESC',
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  // Get today's attendance
  Future<List<Attendance>> getTodayAttendance() async {
    final db = await _db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final result = await db.query(
      'attendance',
      where: 'attendanceDate >= ? AND attendanceDate < ?',
      whereArgs: [today.toIso8601String(), tomorrow.toIso8601String()],
      orderBy: 'attendanceDate DESC',
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  // Update attendance
  Future<int> updateAttendance(Attendance attendance) async {
    final db = await _db;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  // Delete attendance
  Future<int> deleteAttendance(int id) async {
    final db = await _db;
    return await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get attendance count
  Future<int> getAttendanceCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM attendance');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get attendance count by date
  Future<int> getAttendanceCountByDate(DateTime date) async {
    final db = await _db;
    final today = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE attendanceDate >= ? AND attendanceDate < ?',
      [today.toIso8601String(), tomorrow.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
