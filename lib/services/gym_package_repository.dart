import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class GymPackageRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert GymPackage
  Future<int> insertGymPackage(GymPackage package) async {
    final db = await _db;
    return await db.insert('gym_packages', package.toMap());
  }

  // Get all gym packages
  Future<List<GymPackage>> getAllGymPackages() async {
    final db = await _db;
    final result = await db.query('gym_packages');
    return result.map((map) => GymPackage.fromMap(map)).toList();
  }

  // Get active gym packages
  Future<List<GymPackage>> getActiveGymPackages() async {
    final db = await _db;
    final result = await db.query(
      'gym_packages',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return result.map((map) => GymPackage.fromMap(map)).toList();
  }

  // Get gym package by ID
  Future<GymPackage?> getGymPackageById(int id) async {
    final db = await _db;
    final result = await db.query(
      'gym_packages',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return GymPackage.fromMap(result.first);
  }

  // Get gym package by package ID
  Future<GymPackage?> getGymPackageByPackageId(String packageId) async {
    final db = await _db;
    final result = await db.query(
      'gym_packages',
      where: 'packageId = ?',
      whereArgs: [packageId],
    );
    if (result.isEmpty) return null;
    return GymPackage.fromMap(result.first);
  }

  // Update gym package
  Future<int> updateGymPackage(GymPackage package) async {
    final db = await _db;
    return await db.update(
      'gym_packages',
      package.toMap(),
      where: 'id = ?',
      whereArgs: [package.id],
    );
  }

  // Delete gym package
  Future<int> deleteGymPackage(int id) async {
    final db = await _db;
    return await db.delete(
      'gym_packages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
