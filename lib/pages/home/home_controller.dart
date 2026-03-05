import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/bluetooth_service.dart';
import '../../services/database_service.dart';

/// Today's activity item
class TodayActivity {
  final String actionType;
  final String actionName;
  final IconData icon;
  final Color iconColor;
  final int count;
  final DateTime lastTime;

  TodayActivity({
    required this.actionType,
    required this.actionName,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.lastTime,
  });
}

class HomeController extends GetxController {
  final currentAction = 'IDLE'.obs;
  final currentExerciseType = 1.obs; // Current exercise type: 1=Bicep Curl, 2=Lat Pulldown, 3=Pec Fly
  final todayActivities = <TodayActivity>[].obs;

  bool get isConnected => BluetoothService.to.connectedDevice.value != null;
  int get repCount => BluetoothService.to.repCount.value;
  bool get isExercising => BluetoothService.to.isExercising.value;

  @override
  void onInit() {
    super.onInit();
    ever(BluetoothService.to.connectedDevice, (_) => update());
    ever(BluetoothService.to.repCount, (_) => update());
    ever(BluetoothService.to.isExercising, (_) => update());
    loadTodayActivities();
  }

  /// Load today's exercise data
  Future<void> loadTodayActivities() async {
    final records = await DatabaseService.to.getTodayRecords();

    // Group and count by action type
    final Map<String, List<ActionRecord>> grouped = {};
    for (final record in records) {
      grouped.putIfAbsent(record.actionType, () => []);
      grouped[record.actionType]!.add(record);
    }

    final activities = grouped.entries.map((entry) {
      final type = entry.key;
      final list = entry.value;
      final totalCount = list.fold(0, (sum, r) => sum + r.count);
      final lastRecord = list.first;
      final iconData = _getIconForType(type);

      return TodayActivity(
        actionType: type,
        actionName: lastRecord.actionName,
        icon: iconData['icon'] as IconData,
        iconColor: iconData['color'] as Color,
        count: totalCount,
        lastTime: DateTime.parse(lastRecord.timestamp.toIso8601String()),
      );
    }).toList();

    todayActivities.value = activities;
  }

  /// Update current exercise type (called when receiving BLE callback)
  void updateCurrentExerciseType(int type) {
    currentExerciseType.value = type;
    currentAction.value = ExerciseType.getName(type);
    loadTodayActivities(); // Refresh today's data
  }

  /// Get icon data for action type
  Map<String, dynamic> _getIconForType(String type) {
    switch (type) {
      case 'bicep_curl':
        return {'icon': Icons.fitness_center, 'color': Colors.blue};
      case 'lat_pulldown':
        return {'icon': Icons.sports_gymnastics, 'color': Colors.green};
      case 'pec_fly':
        return {'icon': Icons.sports_handball, 'color': Colors.orange};
      default:
        return {'icon': Icons.fitness_center, 'color': Colors.blue};
    }
  }

  Future<void> startDetection() async {
    await BluetoothService.to.sendStart();
  }

  Future<void> stopDetection() async {
    await BluetoothService.to.sendStop();
  }

  Future<void> recountDetection() async {
    await BluetoothService.to.sendStop();
  }
}
