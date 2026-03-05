import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';

/// Exercise type constants
class ExerciseType {
  static const int bicepCurl = 1;      // Bicep Curl
  static const int latPulldown = 2;    // Lat Pulldown
  static const int pecFly = 3;         // Pec Fly

  /// Get exercise type name
  static String getName(int type) {
    switch (type) {
      case bicepCurl:
        return 'bicep_curl';
      case latPulldown:
        return 'lat_pulldown';
      case pecFly:
        return 'pec_fly';
      default:
        return 'unknown';
    }
  }

  /// Get Chinese name
  static String getChineseName(int type) {
    switch (type) {
      case bicepCurl:
        return '二头弯举';
      case latPulldown:
        return '高位下拉';
      case pecFly:
        return '蝴蝶机夹胸';
      default:
        return '未知动作';
    }
  }

  /// Get English name
  static String getEnglishName(int type) {
    switch (type) {
      case bicepCurl:
        return 'Bicep Curl';
      case latPulldown:
        return 'Lat Pulldown';
      case pecFly:
        return 'Pec Fly';
      default:
        return 'Unknown';
    }
  }

  /// Get name by locale setting
  static String getNameByLocale(int type, {bool isChinese = true}) {
    return isChinese ? getChineseName(type) : getEnglishName(type);
  }

  /// Get icon asset path
  static String getIconAsset(int type) {
    // Temporarily use generic icon, can be replaced with action-specific icons later
    switch (type) {
      case bicepCurl:
      case latPulldown:
      case pecFly:
      default:
        return 'assets/images/push.png';
    }
  }
}

/// Action record model
class ActionRecord {
  final int? id;
  final DateTime timestamp;
  final int count;
  final String actionType;
  final String actionName;

  ActionRecord({
    this.id,
    required this.timestamp,
    required this.count,
    required this.actionType,
    required this.actionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'count': count,
      'actionType': actionType,
      'actionName': actionName,
    };
  }

  factory ActionRecord.fromMap(Map<String, dynamic> map) {
    return ActionRecord(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      count: map['count'] as int,
      actionType: map['actionType'] as String,
      actionName: map['actionName'] as String,
    );
  }
}

/// Exercise data grouped by date - for history page display
class DayExerciseSummary {
  final DateTime date;
  final String dayName;
  final Map<String, int> actionCounts; // actionType -> count

  DayExerciseSummary({
    required this.date,
    required this.dayName,
    required this.actionCounts,
  });

  /// Get total count for the day
  int get totalCount => actionCounts.values.fold(0, (sum, c) => sum + c);
}

/// SQLite database service
class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

  Database? _db;

  static const String _tableName = 'action_records';
  static const String _dbName = 'fitness.db';

  @override
  void onInit() {
    super.onInit();
    initDatabase();
  }

  /// Initialize database
  Future<Database> initDatabase() async {
    if (_db != null) return _db!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            count INTEGER NOT NULL,
            actionType TEXT NOT NULL,
            actionName TEXT NOT NULL
          )
        ''');
        // Create settings table for storing default device and other configurations
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Insert action record
  Future<int> insertRecord(ActionRecord record) async {
    final db = await initDatabase();
    return await db.insert(_tableName, record.toMap());
  }

  /// Save count received from BLE
  /// [exerciseType] Exercise type: 1=Bicep Curl, 2=Lat Pulldown, 3=Pec Fly
  Future<int> saveRepCount(int count, {int exerciseType = 1, bool useChinese = true}) async {
    final record = ActionRecord(
      timestamp: DateTime.now(),
      count: count,
      actionType: ExerciseType.getName(exerciseType),
      actionName: ExerciseType.getNameByLocale(exerciseType, isChinese: useChinese),
    );
    return await insertRecord(record);
  }

  /// Get all records
  Future<List<ActionRecord>> getAllRecords() async {
    final db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(_tableName, orderBy: 'timestamp DESC');
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// Get today's records
  Future<List<ActionRecord>> getTodayRecords() async {
    final db = await initDatabase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [today.toIso8601String(), tomorrow.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// Get today's total count
  Future<int> getTodayTotalCount() async {
    final db = await initDatabase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM $_tableName WHERE timestamp >= ? AND timestamp < ?',
      [today.toIso8601String(), tomorrow.toIso8601String()],
    );
    return result.first['total'] as int? ?? 0;
  }

  /// Get records by date
  Future<List<ActionRecord>> getRecordsByDate(DateTime date) async {
    final db = await initDatabase();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// Get action counts by date
  Future<Map<String, int>> getActionCountsByDate(DateTime date) async {
    final db = await initDatabase();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT actionType, SUM(count) as total FROM $_tableName WHERE timestamp >= ? AND timestamp < ? GROUP BY actionType',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['actionType'] as String] = row['total'] as int;
    }
    return counts;
  }

  /// Get total count for specified date
  Future<int> getDateTotalCount(DateTime date) async {
    final db = await initDatabase();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM $_tableName WHERE timestamp >= ? AND timestamp < ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['total'] as int? ?? 0;
  }

  /// Get daily summaries for recent N days (for history page)
  Future<List<DayExerciseSummary>> getRecentDaySummaries(int days) async {
    final db = await initDatabase();
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as date,
        actionType,
        SUM(count) as total
      FROM $_tableName
      WHERE timestamp >= ?
      GROUP BY date(timestamp), actionType
      ORDER BY date(timestamp) DESC
    ''', [startDate.toIso8601String()]);

    final Map<String, Map<String, int>> grouped = {};
    for (final row in result) {
      final date = row['date'] as String;
      final actionType = row['actionType'] as String;
      final total = row['total'] as int;

      grouped.putIfAbsent(date, () => {});
      grouped[date]![actionType] = total;
    }

    return grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return DayExerciseSummary(
        date: date,
        dayName: _getDayName(date),
        actionCounts: entry.value,
      );
    }).toList();
  }

  /// Get paginated history records (for pull-up loading on history page)
  /// [page] Page number, starting from 0
  /// [pageSize] Days per page
  Future<List<DayExerciseSummary>> getDaySummariesByPage(int page, int pageSize) async {
    final db = await initDatabase();
    final offset = page * pageSize;

    // First get all dates with records (distinct)
    final dateResult = await db.rawQuery('''
      SELECT DISTINCT date(timestamp) as date
      FROM $_tableName
      ORDER BY date(timestamp) DESC
      LIMIT ? OFFSET ?
    ''', [pageSize, offset]);

    if (dateResult.isEmpty) return [];

    final dates = dateResult.map((r) => r['date'] as String).toList();

    // Get all action statistics for these dates
    final placeholders = List.filled(dates.length, '?').join(',');
    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as date,
        actionType,
        SUM(count) as total
      FROM $_tableName
      WHERE date(timestamp) IN ($placeholders)
      GROUP BY date(timestamp), actionType
      ORDER BY date(timestamp) DESC
    ''', dates);

    final Map<String, Map<String, int>> grouped = {};
    for (final row in result) {
      final date = row['date'] as String;
      final actionType = row['actionType'] as String;
      final total = row['total'] as int;

      grouped.putIfAbsent(date, () => {});
      grouped[date]![actionType] = total;
    }

    return grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return DayExerciseSummary(
        date: date,
        dayName: _getDayName(date),
        actionCounts: entry.value,
      );
    }).toList();
  }

  /// Get exercise summary by date (for date filtering)
  Future<List<DayExerciseSummary>> getDaySummariesByDate(String dateStr) async {
    final db = await initDatabase();

    // Query all action statistics for specified date
    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as date,
        actionType,
        SUM(count) as total
      FROM $_tableName
      WHERE date(timestamp) = ?
      GROUP BY actionType
    ''', [dateStr]);

    if (result.isEmpty) return [];

    final Map<String, int> actionCounts = {};
    for (final row in result) {
      final actionType = row['actionType'] as String;
      final total = row['total'] as int;
      actionCounts[actionType] = total;
    }

    final date = DateTime.parse(dateStr);
    return [
      DayExerciseSummary(
        date: date,
        dayName: _getDayName(date),
        actionCounts: actionCounts,
      ),
    ];
  }

  /// Get total record days (for checking if there is more data)
  Future<int> getTotalRecordDays() async {
    final db = await initDatabase();
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT date(timestamp)) as count
      FROM $_tableName
    ''');
    return result.first['count'] as int? ?? 0;
  }

  // ==================== User Settings Management ====================

  static const String _userSettingsKey = 'user_settings';

  /// Save user settings
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final db = await initDatabase();
    final value = settings.entries.map((e) => '${e.key}=${e.value}').join('&');
    await db.insert(
      'settings',
      {'key': _userSettingsKey, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user settings
  Future<Map<String, String>> getUserSettings() async {
    final db = await initDatabase();
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [_userSettingsKey],
    );
    if (result.isEmpty) return {};

    final value = result.first['value'] as String;
    final Map<String, String> settings = {};
    for (final pair in value.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        settings[parts[0]] = parts[1];
      }
    }
    return settings;
  }

  /// Save single setting item
  Future<void> setSetting(String key, String value) async {
    final settings = await getUserSettings();
    settings[key] = value;
    await saveUserSettings(settings);
  }

  /// Get single setting item
  Future<String?> getSetting(String key) async {
    final settings = await getUserSettings();
    return settings[key];
  }

  /// Get user total exercise reps
  Future<int> getUserTotalReps() async {
    final db = await initDatabase();
    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM $_tableName'
    );
    return result.first['total'] as int? ?? 0;
  }

  /// Get user consecutive exercise days
  Future<int> getConsecutiveDays() async {
    final db = await initDatabase();
    final result = await db.rawQuery('''
      SELECT DISTINCT date(timestamp) as date
      FROM $_tableName
      ORDER BY date(timestamp) DESC
    ''');

    if (result.isEmpty) return 0;

    int consecutiveDays = 1;
    DateTime? lastDate;

    for (final row in result) {
      final date = DateTime.parse(row['date'] as String);
      if (lastDate != null) {
        final difference = lastDate.difference(date).inDays;
        if (difference == 1) {
          consecutiveDays++;
        } else if (difference > 1) {
          break;
        }
      }
      lastDate = date;
    }

    return consecutiveDays;
  }

  /// Get weekly statistics (for charts)
  /// Returns last 7 days, count for each action type per day
  Future<Map<String, List<double>>> getWeeklyStats() async {
    final db = await initDatabase();
    final now = DateTime.now();
    final weekAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as date,
        actionType,
        SUM(count) as total
      FROM $_tableName
      WHERE timestamp >= ?
      GROUP BY date(timestamp), actionType
    ''', [weekAgo.toIso8601String()]);

    // Initialize 7 days data to 0
    final Map<String, List<double>> stats = {
      'bicep_curl': List.filled(7, 0.0),
      'lat_pulldown': List.filled(7, 0.0),
      'pec_fly': List.filled(7, 0.0),
    };

    for (final row in result) {
      final date = DateTime.parse(row['date'] as String);
      final actionType = row['actionType'] as String;
      final total = (row['total'] as num).toDouble();

      final dayIndex = date.difference(weekAgo).inDays;
      if (dayIndex >= 0 && dayIndex < 7 && stats.containsKey(actionType)) {
        stats[actionType]![dayIndex] = total;
      }
    }

    return stats;
  }

  /// Get monthly statistics (for charts)
  /// Returns last 4 weeks, total count for each action type per week
  Future<Map<String, List<double>>> getMonthlyStats() async {
    final db = await initDatabase();
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));

    final result = await db.rawQuery('''
      SELECT 
        actionType,
        (julianday('now') - julianday(timestamp)) / 7 as week_ago,
        SUM(count) as total
      FROM $_tableName
      WHERE timestamp >= ?
      GROUP BY actionType, CAST((julianday('now') - julianday(timestamp)) / 7 AS INTEGER)
    ''', [fourWeeksAgo.toIso8601String()]);

    final Map<String, List<double>> stats = {
      'bicep_curl': List.filled(4, 0.0),
      'lat_pulldown': List.filled(4, 0.0),
      'pec_fly': List.filled(4, 0.0),
    };

    for (final row in result) {
      final actionType = row['actionType'] as String;
      final weekAgo = (row['week_ago'] as num).toInt();
      final total = (row['total'] as num).toDouble();

      if (weekAgo >= 0 && weekAgo < 4 && stats.containsKey(actionType)) {
        stats[actionType]![3 - weekAgo] = total; // Fill in reverse order
      }
    }

    return stats;
  }

  /// Get yearly statistics (for charts)
  /// Returns last 12 months, total count for each action type per month
  Future<Map<String, List<double>>> getYearlyStats() async {
    final db = await initDatabase();
    final now = DateTime.now();
    final yearAgo = DateTime(now.year - 1, now.month, 1);

    final result = await db.rawQuery('''
      SELECT 
        actionType,
        strftime('%Y-%m', timestamp) as month,
        SUM(count) as total
      FROM $_tableName
      WHERE timestamp >= ?
      GROUP BY actionType, strftime('%Y-%m', timestamp)
    ''', [yearAgo.toIso8601String()]);

    final Map<String, List<double>> stats = {
      'bicep_curl': List.filled(12, 0.0),
      'lat_pulldown': List.filled(12, 0.0),
      'pec_fly': List.filled(12, 0.0),
    };

    for (final row in result) {
      final actionType = row['actionType'] as String;
      final monthStr = row['month'] as String;
      final total = (row['total'] as num).toDouble();

      final monthDate = DateTime.parse('$monthStr-01');
      final monthIndex = (now.year - monthDate.year) * 12 + (now.month - monthDate.month);

      if (monthIndex >= 0 && monthIndex < 12 && stats.containsKey(actionType)) {
        stats[actionType]![11 - monthIndex] = total;
      }
    }

    return stats;
  }

  /// Get recent N records
  Future<List<ActionRecord>> getRecentRecords(int limit) async {
    final db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// Delete single record
  Future<int> deleteRecord(int id) async {
    final db = await initDatabase();
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all records
  Future<int> clearAllRecords() async {
    final db = await initDatabase();
    return await db.delete(_tableName);
  }

  /// Get record count
  Future<int> getRecordCount() async {
    final db = await initDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int? ?? 0;
  }

  // ==================== Default Device Management ====================

  static const String _defaultDeviceKey = 'default_device';

  /// Save default device
  Future<void> saveDefaultDevice(String deviceId, String deviceName) async {
    final db = await initDatabase();
    await db.insert(
      'settings',
      {'key': _defaultDeviceKey, 'value': '$deviceId|$deviceName'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get default device
  Future<Map<String, String>?> getDefaultDevice() async {
    final db = await initDatabase();
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [_defaultDeviceKey],
    );
    if (result.isEmpty) return null;

    final value = result.first['value'] as String;
    final parts = value.split('|');
    if (parts.length < 2) return null;

    return {'id': parts[0], 'name': parts[1]};
  }

  /// Clear default device
  Future<void> clearDefaultDevice() async {
    final db = await initDatabase();
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [_defaultDeviceKey],
    );
  }

  /// Get day of week name
  String _getDayName(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
