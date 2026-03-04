import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';

/// 每日运动项
class DayActivityItem {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String value;

  DayActivityItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.value,
  });
}

/// 每日记录
class DayRecord {
  final String dayName;
  final String date;
  final List<DayActivityItem> activities;

  DayRecord({
    required this.dayName,
    required this.date,
    required this.activities,
  });
}

class HistoryController extends GetxController {
  final selectedDate = ''.obs;

  /// 记录列表
  final records = <DayRecord>[].obs;

  /// 当前页码
  int _currentPage = 0;

  /// 每页显示天数
  static const int _pageSize = 10;

  /// 是否正在加载
  final isLoading = false.obs;

  /// 是否还有更多数据
  final hasMore = true.obs;

  /// 总记录天数
  int _totalDays = 0;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// 加载初始数据
  Future<void> loadInitialData() async {
    _currentPage = 0;
    records.clear();
    hasMore.value = true;
    await _loadData();
  }

  /// 加载更多数据（上拉加载）
  Future<void> loadMoreData() async {
    if (isLoading.value || !hasMore.value) return;
    _currentPage++;
    await _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      // 获取总天数（首次加载时）
      if (_currentPage == 0) {
        _totalDays = await DatabaseService.to.getTotalRecordDays();
      }

      // 分页查询
      final summaries = await DatabaseService.to.getDaySummariesByPage(
        _currentPage,
        _pageSize,
      );

      // 转换为 DayRecord
      final newRecords = summaries.map((summary) {
        final activities = summary.actionCounts.entries.map((entry) {
          return DayActivityItem(
            icon: _getIconForType(entry.key),
            iconColor: _getColorForType(entry.key),
            name: _getActionName(entry.key),
            value: '${entry.value}reps',
          );
        }).toList();

        return DayRecord(
          dayName: summary.dayName,
          date: summary.date.toIso8601String().split('T')[0],
          activities: activities,
        );
      }).toList();

      // 添加到列表
      if (_currentPage == 0) {
        records.value = newRecords;
      } else {
        records.addAll(newRecords);
      }

      // 检查是否还有更多
      final loadedDays = (_currentPage + 1) * _pageSize;
      hasMore.value = loadedDays < _totalDays && newRecords.length == _pageSize;
    } catch (e) {
      print('[History] 加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 选择日期
  void selectDate(String date) {
    selectedDate.value = date;
  }

  /// 获取动作类型对应的图标
  IconData _getIconForType(String type) {
    switch (type) {
      case 'bicep_curl':
        return Icons.fitness_center;
      case 'lat_pulldown':
        return Icons.sports_gymnastics;
      case 'pec_fly':
        return Icons.sports_handball;
      default:
        return Icons.fitness_center;
    }
  }

  /// 获取动作类型对应的颜色
  Color _getColorForType(String type) {
    switch (type) {
      case 'bicep_curl':
        return Colors.blue;
      case 'lat_pulldown':
        return Colors.green;
      case 'pec_fly':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// 获取动作类型对应的中文名称
  String _getActionName(String type) {
    switch (type) {
      case 'bicep_curl':
        return '二头弯举';
      case 'lat_pulldown':
        return '高位下拉';
      case 'pec_fly':
        return '蝴蝶机夹胸';
      default:
        return type;
    }
  }
}
