import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';
import '../../services/bluetooth_service.dart';

class MyController extends GetxController {
  // 系统设置
  final autoConnectBluetooth = true.obs;
  final dataStorageLocation = 'this machine'.obs;

  // 用户信息
  final userName = 'Fitness User'.obs;
  final userGender = 'man'.obs;
  final userWeight = '75'.obs;
  final userAvatar = 'assets/images/avatar.jpg'.obs;

  // 训练目标
  final dailyTarget = 100.obs;
  final reminderTime = '08:00'.obs;
  final todayCompleted = 0.obs;
  final todayTarget = 15.obs;

  // 统计数据
  final totalReps = 0.obs;
  final consecutiveDays = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadUserStats();
  }

  /// 加载设置
  Future<void> loadSettings() async {
    final settings = await DatabaseService.to.getUserSettings();

    // 加载蓝牙自动连接设置
    final autoConnect = settings['auto_connect_bluetooth'];
    if (autoConnect != null) {
      autoConnectBluetooth.value = autoConnect == 'true';
    }

    // 加载用户信息
    if (settings['user_name'] != null) {
      userName.value = settings['user_name']!;
    }
    if (settings['user_gender'] != null) {
      userGender.value = settings['user_gender']!;
    }
    if (settings['user_weight'] != null) {
      userWeight.value = settings['user_weight']!;
    }

    // 加载训练目标
    if (settings['daily_target'] != null) {
      dailyTarget.value = int.tryParse(settings['daily_target']!) ?? 100;
    }
    if (settings['reminder_time'] != null) {
      reminderTime.value = settings['reminder_time']!;
    }
  }

  /// 加载用户统计数据
  Future<void> loadUserStats() async {
    // 获取今日完成次数
    todayCompleted.value = await DatabaseService.to.getTodayTotalCount();

    // 获取总运动次数
    totalReps.value = await DatabaseService.to.getUserTotalReps();

    // 获取连续运动天数
    consecutiveDays.value = await DatabaseService.to.getConsecutiveDays();
  }

  /// 切换蓝牙自动连接
  Future<void> toggleAutoConnect(bool value) async {
    autoConnectBluetooth.value = value;
    await DatabaseService.to.setSetting('auto_connect_bluetooth', value.toString());

    // 如果关闭自动连接，清除默认设备
    if (!value) {
      await DatabaseService.to.clearDefaultDevice();
    }
  }

  /// 更新用户名
  Future<void> updateUserName(String name) async {
    userName.value = name;
    await DatabaseService.to.setSetting('user_name', name);
  }

  /// 更新用户体重
  Future<void> updateUserWeight(String weight) async {
    userWeight.value = weight;
    await DatabaseService.to.setSetting('user_weight', weight);
  }

  /// 更新每日目标
  Future<void> updateDailyTarget(int target) async {
    dailyTarget.value = target;
    await DatabaseService.to.setSetting('daily_target', target.toString());
  }

  /// 更新提醒时间
  Future<void> updateReminderTime(String time) async {
    reminderTime.value = time;
    await DatabaseService.to.setSetting('reminder_time', time);
  }

  /// 获取今日完成进度（0.0 - 1.0）
  double get todayProgress {
    if (todayTarget.value == 0) return 0.0;
    return (todayCompleted.value / todayTarget.value).clamp(0.0, 1.0);
  }

  /// 获取今日完成显示文本
  String get todayProgressText {
    return '$todayCompleted / $todayTarget';
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    await DatabaseService.to.clearAllRecords();
    await loadUserStats();
  }
}
