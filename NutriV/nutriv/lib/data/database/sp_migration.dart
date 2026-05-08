import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../../core/services/logging_service.dart';

class SharedPreferencesMigration {
  static const String _migrationKey = 'sqlite_migration_completed';
  static const String _oldMealsKey = 'meals';
  static const String _oldPendingKey = 'pending_sync';
  static const String _oldUserKey = 'user';
  static const String _oldDailyLogsKey = 'daily_logs';

  static Future<bool> isMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  static Future<void> runMigration() async {
    if (await isMigrationComplete()) {
      LoggingService.info('Migration', 'Already completed, skipping');
      return;
    }

    LoggingService.info('Migration', 'Starting SharedPreferences → SQLite migration');
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseHelper.instance;

    try {
      await _migrateMeals(prefs, db);
      await _migratePendingSync(prefs, db);
      await _migrateUserProfile(prefs, db);
      await _migrateDailyLogs(prefs, db);

      await prefs.setBool(_migrationKey, true);
      LoggingService.info('Migration', 'Completed successfully');
    } catch (e) {
      LoggingService.error('Migration', 'runMigration', e);
      await prefs.setBool(_migrationKey, false);
      rethrow;
    }
  }

  static Future<void> _migrateMeals(
    SharedPreferences prefs,
    DatabaseHelper db,
  ) async {
    final mealsData = prefs.getString(_oldMealsKey);
    if (mealsData == null) {
      LoggingService.info('Migration', 'No meals data to migrate');
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(mealsData);
      int migratedCount = 0;

      for (final mealJson in decoded) {
        final meal = mealJson as Map<String, dynamic>;
        final mealId = meal['id'] as String;
        final dateTime = DateTime.parse(meal['dateTime'] as String);
        final dateStr =
            '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

        await db.insertMealWithFoods(
          meal: {
            'id': mealId,
            'name': meal['name'],
            'meal_type': meal['mealType'],
            'consumed_at': meal['dateTime'],
            'date': dateStr,
            'input_method': 'manual',
            'notes': meal['notes'],
            'sync_status': 'synced',
            'created_at': dateTime.toIso8601String(),
          },
          foods: (meal['foods'] as List<dynamic>).map((f) {
            final foodData = f['food'] as Map<String, dynamic>;
            return {
              'id': f['id'],
              'meal_id': mealId,
              'food_id': foodData['id'],
              'food_name': foodData['name'],
              'food_calories': (foodData['calories'] as num).toDouble(),
              'food_protein': (foodData['protein'] as num).toDouble(),
              'food_carbs': (foodData['carbs'] as num).toDouble(),
              'food_fat': (foodData['fat'] as num).toDouble(),
              'food_fiber':
                  (foodData['fiber'] as num?)?.toDouble() ?? 0.0,
              'food_sugar':
                  (foodData['sugar'] as num?)?.toDouble() ?? 0.0,
              'food_sodium':
                  (foodData['sodium'] as num?)?.toDouble() ?? 0.0,
              'food_portion':
                  (foodData['portion'] as num).toDouble(),
              'food_portion_unit':
                  foodData['portionUnit'] as String? ?? 'g',
              'food_image_url': foodData['imageUrl'],
              'food_barcode': foodData['barcode'],
              'quantity': (f['quantity'] as num).toDouble(),
            };
          }).toList(),
        );
        migratedCount++;
      }

      LoggingService.info('Migration', 'Migrated $migratedCount meals');
    } catch (e) {
      LoggingService.error('Migration', 'migrateMeals', e);
    }
  }

  static Future<void> _migratePendingSync(
    SharedPreferences prefs,
    DatabaseHelper db,
  ) async {
    final pendingList = prefs.getStringList(_oldPendingKey);
    if (pendingList == null || pendingList.isEmpty) {
      LoggingService.info('Migration', 'No pending sync items to migrate');
      return;
    }

    int migratedCount = 0;
    for (final item in pendingList) {
      await db.enqueueSync(
        entityType: 'meal',
        payload: item,
        operation: 'upsert',
      );
      migratedCount++;
    }

    await prefs.remove(_oldPendingKey);
    LoggingService.info('Migration', 'Migrated $migratedCount pending sync items');
  }

  static Future<void> _migrateUserProfile(
    SharedPreferences prefs,
    DatabaseHelper db,
  ) async {
    final userData = prefs.getString(_oldUserKey);
    if (userData == null) {
      LoggingService.info('Migration', 'No user profile data to migrate');
      return;
    }

    try {
      final user = jsonDecode(userData) as Map<String, dynamic>;
      await db.saveUserProfile({
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'photo_url': user['photoUrl'],
        'weight': (user['weight'] as num).toDouble(),
        'height': (user['height'] as num).toDouble(),
        'age': user['age'],
        'is_male': user['isMale'] ? 1 : 0,
        'activity_level': user['activityLevel'],
        'goal': user['goal'],
        'calorie_goal': (user['calorieGoal'] as num).toDouble(),
        'protein_goal': (user['proteinGoal'] as num).toDouble(),
        'carbs_goal': (user['carbsGoal'] as num).toDouble(),
        'fat_goal': (user['fatGoal'] as num).toDouble(),
        'water_goal': (user['waterGoal'] as num).toDouble(),
        'created_at': user['createdAt'],
      });

      LoggingService.info('Migration', 'Migrated user profile');
    } catch (e) {
      LoggingService.error('Migration', 'migrateUserProfile', e);
    }
  }

  static Future<void> _migrateDailyLogs(
    SharedPreferences prefs,
    DatabaseHelper db,
  ) async {
    final logsData = prefs.getString(_oldDailyLogsKey);
    if (logsData == null) {
      LoggingService.info('Migration', 'No daily logs data to migrate');
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(logsData);
      int migratedCount = 0;

      for (final logJson in decoded) {
        final log = logJson as Map<String, dynamic>;
        await db.saveDailyLog({
          'id': log['id'],
          'date': log['date'],
          'total_calories': (log['totalCalories'] as num).toDouble(),
          'total_protein': (log['totalProtein'] as num).toDouble(),
          'total_carbs': (log['totalCarbs'] as num).toDouble(),
          'total_fat': (log['totalFat'] as num).toDouble(),
          'water_intake': (log['waterIntake'] as num).toDouble(),
          'calorie_goal': (log['calorieGoal'] as num).toDouble(),
          'protein_goal': (log['proteinGoal'] as num).toDouble(),
          'carbs_goal': (log['carbsGoal'] as num).toDouble(),
          'fat_goal': (log['fatGoal'] as num).toDouble(),
          'water_goal': (log['waterGoal'] as num).toDouble(),
        });
        migratedCount++;
      }

      LoggingService.info('Migration', 'Migrated $migratedCount daily logs');
    } catch (e) {
      LoggingService.error('Migration', 'migrateDailyLogs', e);
    }
  }
}
