import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutriv.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        consumed_at TEXT NOT NULL,
        date TEXT NOT NULL,
        input_method TEXT DEFAULT 'manual',
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_meals_date ON meals(date)',
    );
    await db.execute(
      'CREATE INDEX idx_meals_sync ON meals(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_meals_user ON meals(user_id)',
    );

    await db.execute('''
      CREATE TABLE meal_foods (
        id TEXT PRIMARY KEY,
        meal_id TEXT NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
        food_id TEXT,
        food_name TEXT NOT NULL,
        food_calories REAL NOT NULL DEFAULT 0,
        food_protein REAL NOT NULL DEFAULT 0,
        food_carbs REAL NOT NULL DEFAULT 0,
        food_fat REAL NOT NULL DEFAULT 0,
        food_fiber REAL NOT NULL DEFAULT 0,
        food_sugar REAL NOT NULL DEFAULT 0,
        food_sodium REAL NOT NULL DEFAULT 0,
        food_portion REAL NOT NULL DEFAULT 100,
        food_portion_unit TEXT DEFAULT 'g',
        food_image_url TEXT,
        food_barcode TEXT,
        quantity REAL NOT NULL,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_meal_foods_meal ON meal_foods(meal_id)',
    );

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        payload TEXT NOT NULL,
        operation TEXT NOT NULL DEFAULT 'upsert',
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sync_queue_type ON sync_queue(entity_type)',
    );

    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        photo_url TEXT,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        age INTEGER NOT NULL,
        is_male INTEGER NOT NULL,
        activity_level INTEGER NOT NULL,
        goal TEXT NOT NULL,
        calorie_goal REAL NOT NULL,
        protein_goal REAL NOT NULL,
        carbs_goal REAL NOT NULL,
        fat_goal REAL NOT NULL,
        water_goal REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        total_calories REAL NOT NULL,
        total_protein REAL NOT NULL,
        total_carbs REAL NOT NULL,
        total_fat REAL NOT NULL,
        water_intake REAL NOT NULL,
        calorie_goal REAL NOT NULL,
        protein_goal REAL NOT NULL,
        carbs_goal REAL NOT NULL,
        fat_goal REAL NOT NULL,
        water_goal REAL NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_daily_logs_date ON daily_logs(date)',
    );

    await db.execute('''
      CREATE TABLE water_intake_local (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        amount_ml REAL NOT NULL,
        consumed_at TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_water_intake_date ON water_intake_local(date)',
    );

    await db.execute('''
      CREATE TABLE step_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL DEFAULT 0,
        goal INTEGER NOT NULL DEFAULT 10000,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_step_entries_date ON step_entries(date)',
    );

    await db.execute('''
      CREATE TABLE food_cache (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        calories REAL NOT NULL DEFAULT 0,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fat REAL NOT NULL DEFAULT 0,
        fiber REAL NOT NULL DEFAULT 0,
        sugar REAL NOT NULL DEFAULT 0,
        sodium REAL NOT NULL DEFAULT 0,
        portion REAL NOT NULL DEFAULT 100,
        portion_unit TEXT DEFAULT 'g',
        image_url TEXT,
        barcode TEXT,
        source TEXT DEFAULT 'usda',
        search_key TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_food_cache_search ON food_cache(search_key)',
    );
    await db.execute(
      'CREATE INDEX idx_food_cache_name ON food_cache(name)',
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS step_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          steps INTEGER NOT NULL DEFAULT 0,
          goal INTEGER NOT NULL DEFAULT 10000,
          created_at TEXT DEFAULT (datetime('now')),
          updated_at TEXT DEFAULT (datetime('now'))
        )
      ''');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_step_entries_date ON step_entries(date)',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ==================== MEALS ====================

  Future<List<Map<String, dynamic>>> getMealsByDate(
    String date, {
    String? userId,
  }) async {
    final db = await database;
    final whereClauses = <String>['date = ?'];
    final whereArgs = <dynamic>[date];

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    return db.query(
      'meals',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'consumed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllMeals({String? userId}) async {
    final db = await database;
    if (userId != null) {
      return db.query(
        'meals',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'consumed_at DESC',
      );
    }
    return db.query('meals', orderBy: 'consumed_at DESC');
  }

  Future<List<Map<String, dynamic>>> getMealFoods(String mealId) async {
    final db = await database;
    return db.query(
      'meal_foods',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );
  }

  Future<int> insertMeal(Map<String, dynamic> meal) async {
    final db = await database;
    return db.insert(
      'meals',
      meal,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertMealFood(Map<String, dynamic> mealFood) async {
    final db = await database;
    return db.insert(
      'meal_foods',
      mealFood,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMealWithFoods({
    required Map<String, dynamic> meal,
    required List<Map<String, dynamic>> foods,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'meals',
        meal,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final food in foods) {
        await txn.insert(
          'meal_foods',
          food,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<int> deleteMeal(String mealId) async {
    final db = await database;
    return db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
  }

  Future<int> deleteMealFoods(String mealId) async {
    final db = await database;
    return db.delete('meal_foods', where: 'meal_id = ?', whereArgs: [mealId]);
  }

  Future<int> updateMeal(String id, Map<String, dynamic> meal) async {
    final db = await database;
    return db.update(
      'meals',
      meal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncMeals() async {
    final db = await database;
    return db.query(
      'meals',
      where: "sync_status = 'pending'",
      orderBy: 'created_at ASC',
    );
  }

  Future<int> markMealSynced(String mealId) async {
    final db = await database;
    return db.update(
      'meals',
      {'sync_status': 'synced', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [mealId],
    );
  }

  // ==================== SYNC QUEUE ====================

  Future<int> enqueueSync({
    required String entityType,
    String? entityId,
    required String payload,
    String operation = 'upsert',
  }) async {
    final db = await database;
    return db.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
      'operation': operation,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    final db = await database;
    return db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
    );
  }

  Future<int> removeFromSyncQueue(int queueId) async {
    final db = await database;
    return db.delete('sync_queue', where: 'id = ?', whereArgs: [queueId]);
  }

  Future<int> incrementSyncQueueRetry(int queueId, String error) async {
    final db = await database;
    return db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_error = ? WHERE id = ?',
      [error, queueId],
    );
  }

  Future<int> clearSyncQueue() async {
    final db = await database;
    return db.delete('sync_queue');
  }

  // ==================== USER PROFILE ====================

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> saveUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    profile['updated_at'] = DateTime.now().toIso8601String();
    return db.insert(
      'user_profile',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteUserProfile() async {
    final db = await database;
    return db.delete('user_profile');
  }

  // ==================== DAILY LOGS ====================

  Future<List<Map<String, dynamic>>> getDailyLogs() async {
    final db = await database;
    return db.query('daily_logs', orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getDailyLogByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_logs',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> saveDailyLog(Map<String, dynamic> log) async {
    final db = await database;
    log['updated_at'] = DateTime.now().toIso8601String();
    return db.insert(
      'daily_logs',
      log,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteDailyLog(String id) async {
    final db = await database;
    return db.delete('daily_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== WATER INTAKE ====================

  Future<double> getWaterIntakeForDate(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount_ml), 0) as total FROM water_intake_local WHERE date = ?',
      [date],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getWaterIntakeHistory({
    int days = 30,
  }) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT date, SUM(amount_ml) as total
      FROM water_intake_local
      WHERE date >= date('now', '-$days days')
      GROUP BY date
      ORDER BY date DESC
    ''',
    );
  }

  Future<int> addWaterIntake(Map<String, dynamic> entry) async {
    final db = await database;
    return db.insert('water_intake_local', entry);
  }

  Future<int> removeWaterIntake(String id) async {
    final db = await database;
    return db.delete('water_intake_local', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getWaterGoal() async {
    final profile = await getUserProfile();
    return profile != null
        ? (profile['water_goal'] as num).toDouble()
        : 2000.0;
  }

  // ==================== STEP ENTRIES ====================

  Future<int> getStepsForDate(String date) async {
    final db = await database;
    final result = await db.query(
      'step_entries',
      columns: ['steps'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (result.isEmpty) return 0;
    return (result.first['steps'] as num).toInt();
  }

  Future<int> getStepGoalForDate(String date) async {
    final db = await database;
    final result = await db.query(
      'step_entries',
      columns: ['goal'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (result.isEmpty) return 10000;
    return (result.first['goal'] as num).toInt();
  }

  Future<int> saveSteps({
    required String date,
    required int steps,
    int goal = 10000,
  }) async {
    final db = await database;
    return db.insert(
      'step_entries',
      {
        'date': date,
        'steps': steps,
        'goal': goal,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWeeklySteps() async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT date, steps, goal
      FROM step_entries
      WHERE date >= date('now', '-6 days')
      ORDER BY date ASC
    ''',
    );
  }

  Future<int> setStepGoal(int goal) async {
    final db = await database;
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return db.rawUpdate(
      'UPDATE step_entries SET goal = ? WHERE date = ?',
      [goal, dateStr],
    );
  }

  // ==================== FOOD CACHE ====================

  Future<List<Map<String, dynamic>>> getCachedFoods(
    String searchKey,
  ) async {
    final db = await database;
    return db.query(
      'food_cache',
      where: 'search_key = ?',
      whereArgs: [searchKey.toLowerCase()],
      orderBy: 'cached_at DESC',
      limit: 20,
    );
  }

  Future<int> cacheFood(Map<String, dynamic> food) async {
    final db = await database;
    return db.insert(
      'food_cache',
      food,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> cacheFoods(List<Map<String, dynamic>> foods) async {
    final db = await database;
    int count = 0;
    for (final food in foods) {
      await db.insert(
        'food_cache',
        food,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }
    return count;
  }

  Future<Map<String, dynamic>?> getCachedFoodById(String id) async {
    final db = await database;
    final result = await db.query(
      'food_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> clearOldCache({int daysOld = 30}) async {
    final db = await database;
    return db.rawDelete(
      'DELETE FROM food_cache WHERE cached_at < date(\'now\', \'-$daysOld days\')',
    );
  }
}
