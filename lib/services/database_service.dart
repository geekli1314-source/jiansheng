import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';

/// 运动类型常量
class ExerciseType {
  static const int bicepCurl = 1;      // 二头弯举
  static const int latPulldown = 2;    // 高位下拉
  static const int pecFly = 3;         // 蝴蝶机夹胸

  /// 获取运动类型名称
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

  /// 获取中文名称
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

  /// 获取图标资源路径
  static String getIconAsset(int type) {
    // 暂时使用通用图标，后续可替换为对应动作图标
    switch (type) {
      case bicepCurl:
      case latPulldown:
      case pecFly:
      default:
        return 'assets/images/push.png';
    }
  }
}

/// 动作记录模型
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

/// 按日期分组的运动数据 - 用于记录页面展示
class DayExerciseSummary {
  final DateTime date;
  final String dayName;
  final Map<String, int> actionCounts; // actionType -> count

  DayExerciseSummary({
    required this.date,
    required this.dayName,
    required this.actionCounts,
  });

  /// 获取该日总次数
  int get totalCount => actionCounts.values.fold(0, (sum, c) => sum + c);
}

/// SQLite 数据库服务
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

  /// 初始化数据库
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
        // 创建设置表用于存储默认设备等配置
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

  /// 插入动作记录
  Future<int> insertRecord(ActionRecord record) async {
    final db = await initDatabase();
    return await db.insert(_tableName, record.toMap());
  }

  /// 保存 BLE 接收到的次数
  /// [exerciseType] 运动类型: 1=二头弯举, 2=高位下拉, 3=蝴蝶机夹胸
  Future<int> saveRepCount(int count, {int exerciseType = 1}) async {
    final record = ActionRecord(
      timestamp: DateTime.now(),
      count: count,
      actionType: ExerciseType.getName(exerciseType),
      actionName: ExerciseType.getChineseName(exerciseType),
    );
    return await insertRecord(record);
  }

  /// 获取所有记录
  Future<List<ActionRecord>> getAllRecords() async {
    final db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(_tableName, orderBy: 'timestamp DESC');
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// 获取今日记录
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

  /// 获取今日总次数
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

  /// 获取指定日期记录
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

  /// 获取指定日期各动作类型的统计
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

  /// 获取指定日期总次数
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

  /// 获取最近 N 天的每日汇总（用于记录页面）
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

  /// 分页获取历史记录（用于记录页面上拉加载）
  /// [page] 页码，从0开始
  /// [pageSize] 每页天数
  Future<List<DayExerciseSummary>> getDaySummariesByPage(int page, int pageSize) async {
    final db = await initDatabase();
    final offset = page * pageSize;

    // 先获取有记录的所有日期（去重）
    final dateResult = await db.rawQuery('''
      SELECT DISTINCT date(timestamp) as date
      FROM $_tableName
      ORDER BY date(timestamp) DESC
      LIMIT ? OFFSET ?
    ''', [pageSize, offset]);

    if (dateResult.isEmpty) return [];

    final dates = dateResult.map((r) => r['date'] as String).toList();

    // 获取这些日期的所有动作统计
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

  /// 获取总记录天数（用于判断是否还有更多数据）
  Future<int> getTotalRecordDays() async {
    final db = await initDatabase();
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT date(timestamp)) as count
      FROM $_tableName
    ''');
    return result.first['count'] as int? ?? 0;
  }

  // ==================== 用户设置管理 ====================

  static const String _userSettingsKey = 'user_settings';

  /// 保存用户设置
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final db = await initDatabase();
    final value = settings.entries.map((e) => '${e.key}=${e.value}').join('&');
    await db.insert(
      'settings',
      {'key': _userSettingsKey, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取用户设置
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

  /// 保存单个设置项
  Future<void> setSetting(String key, String value) async {
    final settings = await getUserSettings();
    settings[key] = value;
    await saveUserSettings(settings);
  }

  /// 获取单个设置项
  Future<String?> getSetting(String key) async {
    final settings = await getUserSettings();
    return settings[key];
  }

  /// 获取用户总运动次数
  Future<int> getUserTotalReps() async {
    final db = await initDatabase();
    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM $_tableName'
    );
    return result.first['total'] as int? ?? 0;
  }

  /// 获取用户连续运动天数
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

  /// 获取周统计数据（用于图表）
  /// 返回最近7天，每天各动作类型的次数
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

    // 初始化7天数据为0
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

  /// 获取月统计数据（用于图表）
  /// 返回最近4周，每周各动作类型的次数总和
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
        stats[actionType]![3 - weekAgo] = total; // 倒序填充
      }
    }

    return stats;
  }

  /// 获取年统计数据（用于图表）
  /// 返回最近12个月，每月各动作类型的次数总和
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

  /// 获取最近 N 条记录
  Future<List<ActionRecord>> getRecentRecords(int limit) async {
    final db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => ActionRecord.fromMap(map)).toList();
  }

  /// 删除单条记录
  Future<int> deleteRecord(int id) async {
    final db = await initDatabase();
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// 清空所有记录
  Future<int> clearAllRecords() async {
    final db = await initDatabase();
    return await db.delete(_tableName);
  }

  /// 获取记录总数
  Future<int> getRecordCount() async {
    final db = await initDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int? ?? 0;
  }

  // ==================== 默认设备管理 ====================

  static const String _defaultDeviceKey = 'default_device';

  /// 保存默认设备
  Future<void> saveDefaultDevice(String deviceId, String deviceName) async {
    final db = await initDatabase();
    await db.insert(
      'settings',
      {'key': _defaultDeviceKey, 'value': '$deviceId|$deviceName'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取默认设备
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

  /// 清除默认设备
  Future<void> clearDefaultDevice() async {
    final db = await initDatabase();
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [_defaultDeviceKey],
    );
  }

  /// 获取星期名称
  String _getDayName(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
