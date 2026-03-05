import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';
import '../../services/bluetooth_service.dart';

class MyController extends GetxController {
  // System settings
  final autoConnectBluetooth = true.obs;
  final dataStorageLocation = 'this machine'.obs;
  final useChineseLanguage = true.obs; // Language setting: true=Chinese, false=English

  // User info
  final userName = 'Fitness User'.obs;
  final userGender = 'man'.obs;
  final userWeight = '75'.obs;
  final userAvatar = 'assets/images/avatar.jpg'.obs;

  // Training goals
  final dailyTarget = 100.obs;
  final reminderTime = '08:00'.obs;
  final todayCompleted = 0.obs;
  final todayTarget = 15.obs;

  // Statistics
  final totalReps = 0.obs;
  final consecutiveDays = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadUserStats();
  }

  /// Load settings
  Future<void> loadSettings() async {
    final settings = await DatabaseService.to.getUserSettings();

    // Load Bluetooth auto connect setting
    final autoConnect = settings['auto_connect_bluetooth'];
    if (autoConnect != null) {
      autoConnectBluetooth.value = autoConnect == 'true';
    }

    // Load language setting
    final language = settings['use_chinese_language'];
    if (language != null) {
      useChineseLanguage.value = language == 'true';
    }

    // Load user info
    if (settings['user_name'] != null) {
      userName.value = settings['user_name']!;
    }
    if (settings['user_gender'] != null) {
      userGender.value = settings['user_gender']!;
    }
    if (settings['user_weight'] != null) {
      userWeight.value = settings['user_weight']!;
    }

    // Load training goals
    if (settings['daily_target'] != null) {
      dailyTarget.value = int.tryParse(settings['daily_target']!) ?? 100;
    }
    if (settings['reminder_time'] != null) {
      reminderTime.value = settings['reminder_time']!;
    }
  }

  /// Load user statistics
  Future<void> loadUserStats() async {
    // Get today's completed count
    todayCompleted.value = await DatabaseService.to.getTodayTotalCount();

    // Get total exercise reps
    totalReps.value = await DatabaseService.to.getUserTotalReps();

    // Get consecutive exercise days
    consecutiveDays.value = await DatabaseService.to.getConsecutiveDays();
  }

  /// Toggle Bluetooth auto connect
  Future<void> toggleAutoConnect(bool value) async {
    autoConnectBluetooth.value = value;
    await DatabaseService.to.setSetting('auto_connect_bluetooth', value.toString());

    // If auto connect is disabled, clear default device
    if (!value) {
      await DatabaseService.to.clearDefaultDevice();
    }
  }

  /// Update user name
  Future<void> updateUserName(String name) async {
    userName.value = name;
    await DatabaseService.to.setSetting('user_name', name);
  }

  /// Update user weight
  Future<void> updateUserWeight(String weight) async {
    userWeight.value = weight;
    await DatabaseService.to.setSetting('user_weight', weight);
  }

  /// Update daily target
  Future<void> updateDailyTarget(int target) async {
    dailyTarget.value = target;
    await DatabaseService.to.setSetting('daily_target', target.toString());
  }

  /// Update reminder time
  Future<void> updateReminderTime(String time) async {
    reminderTime.value = time;
    await DatabaseService.to.setSetting('reminder_time', time);
  }

  /// Get today's completion progress (0.0 - 1.0)
  double get todayProgress {
    if (todayTarget.value == 0) return 0.0;
    return (todayCompleted.value / todayTarget.value).clamp(0.0, 1.0);
  }

  /// Get today's completion display text
  String get todayProgressText {
    return '$todayCompleted / $todayTarget';
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await DatabaseService.to.clearAllRecords();
    await loadUserStats();
  }

  /// Toggle language setting
  Future<void> toggleLanguage(bool useChinese) async {
    useChineseLanguage.value = useChinese;
    await DatabaseService.to.setSetting('use_chinese_language', useChinese.toString());
  }
}
