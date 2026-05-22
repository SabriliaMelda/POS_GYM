import 'package:sqflite/sqflite.dart';
import '../models/index.dart';
import '../database/database_service.dart';

class FoodBeverageItemRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _db async => await _databaseService.database;

  // Create or Insert FoodBeverageItem
  Future<int> insertFoodBeverageItem(FoodBeverageItem item) async {
    final db = await _db;
    return await db.insert('food_beverage_items', item.toMap());
  }

  // Get all food and beverage items
  Future<List<FoodBeverageItem>> getAllFoodBeverageItems() async {
    final db = await _db;
    final result = await db.query('food_beverage_items');
    return result.map((map) => FoodBeverageItem.fromMap(map)).toList();
  }

  // Get active food and beverage items
  Future<List<FoodBeverageItem>> getActiveFoodBeverageItems() async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return result.map((map) => FoodBeverageItem.fromMap(map)).toList();
  }

  // Get food and beverage items by category
  Future<List<FoodBeverageItem>> getFoodBeverageItemsByCategory(String category) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'category = ? AND isActive = ?',
      whereArgs: [category, 1],
    );
    return result.map((map) => FoodBeverageItem.fromMap(map)).toList();
  }

  // Get food and beverage item by ID
  Future<FoodBeverageItem?> getFoodBeverageItemById(int id) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return FoodBeverageItem.fromMap(result.first);
  }

  // Get food and beverage item by item ID
  Future<FoodBeverageItem?> getFoodBeverageItemByItemId(String itemId) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    if (result.isEmpty) return null;
    return FoodBeverageItem.fromMap(result.first);
  }

  // Search food and beverage items by name
  Future<List<FoodBeverageItem>> searchFoodBeverageItemsByName(String name) async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'name LIKE ? AND isActive = ?',
      whereArgs: ['%$name%', 1],
    );
    return result.map((map) => FoodBeverageItem.fromMap(map)).toList();
  }

  // Update food and beverage item
  Future<int> updateFoodBeverageItem(FoodBeverageItem item) async {
    final db = await _db;
    return await db.update(
      'food_beverage_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete food and beverage item
  Future<int> deleteFoodBeverageItem(int id) async {
    final db = await _db;
    return await db.delete(
      'food_beverage_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get low stock items (stock less than 10)
  Future<List<FoodBeverageItem>> getLowStockItems() async {
    final db = await _db;
    final result = await db.query(
      'food_beverage_items',
      where: 'stock < ? AND isActive = ?',
      whereArgs: [10, 1],
    );
    return result.map((map) => FoodBeverageItem.fromMap(map)).toList();
  }

  // Get distinct categories
  Future<List<String>> getCategories() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT DISTINCT category FROM food_beverage_items WHERE isActive = 1');
    return result.map((map) => map['category'] as String).toList();
  }
}
