import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class MemberRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert Member
  Future<int> insertMember(Member member) async {
    final db = await _db;
    return await db.insert('members', member.toMap());
  }

  // Get all members
  Future<List<Member>> getAllMembers() async {
    final db = await _db;
    final result = await db.query('members');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Get active members
  Future<List<Member>> getActiveMembers() async {
    final db = await _db;
    final result = await db.query(
      'members',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Get member by ID
  Future<Member?> getMemberById(int id) async {
    final db = await _db;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Member.fromMap(result.first);
  }

  // Get member by member ID
  Future<Member?> getMemberByMemberId(String memberId) async {
    final db = await _db;
    final result = await db.query(
      'members',
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
    if (result.isEmpty) return null;
    return Member.fromMap(result.first);
  }

  // Search members by name
  Future<List<Member>> searchMembersByName(String name) async {
    final db = await _db;
    final result = await db.query(
      'members',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Update member
  Future<int> updateMember(Member member) async {
    final db = await _db;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // Delete member
  Future<int> deleteMember(int id) async {
    final db = await _db;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // Get expired members
  Future<List<Member>> getExpiredMembers() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'members',
      where: 'membershipExpiryDate < ?',
      whereArgs: [now],
    );
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Get members expiring soon (within 7 days)
  Future<List<Member>> getMembersExpiringWithin7Days() async {
    final db = await _db;
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7)).toIso8601String();
    final result = await db.query(
      'members',
      where:
          'membershipExpiryDate <= ? AND membershipExpiryDate >= ? AND isActive = ?',
      whereArgs: [sevenDaysLater, now.toIso8601String(), 1],
    );
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Get member count
  Future<int> getMemberCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM members');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get active member count
  Future<int> getActiveMemberCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM members WHERE isActive = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
