import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';

/// Daily activity item
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

/// Daily record
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

  /// Record list
  final records = <DayRecord>[].obs;

  /// Current page number
  int _currentPage = 0;

  /// Days per page
  static const int _pageSize = 10;

  /// Whether loading
  final isLoading = false.obs;

  /// Whether has more data
  final hasMore = true.obs;

  /// Total record days
  int _totalDays = 0;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    _currentPage = 0;
    records.clear();
    hasMore.value = true;
    await _loadData();
  }

  /// Load more data (pull up to load)
  Future<void> loadMoreData() async {
    if (isLoading.value || !hasMore.value) return;
    _currentPage++;
    await _loadData();
  }

  /// Load data
  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      // Get total days (on first load)
      if (_currentPage == 0) {
        _totalDays = await DatabaseService.to.getTotalRecordDays();
      }

      // Paginated query
      final summaries = await DatabaseService.to.getDaySummariesByPage(
        _currentPage,
        _pageSize,
      );

      // Convert to DayRecord
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

      // Add to list
      if (_currentPage == 0) {
        records.value = newRecords;
      } else {
        records.addAll(newRecords);
      }

      // Check if there is more data
      final loadedDays = (_currentPage + 1) * _pageSize;
      hasMore.value = loadedDays < _totalDays && newRecords.length == _pageSize;
    } catch (e) {
      print('[History] Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select date
  Future<void> selectDate(String date) async {
    selectedDate.value = date;
    await _loadDataByDate(date);
  }

  /// Clear date filter
  Future<void> clearDateFilter() async {
    selectedDate.value = '';
    await loadInitialData();
  }

  /// Load data by date
  Future<void> _loadDataByDate(String date) async {
    isLoading.value = true;
    try {
      // Query data for specified date
      final summaries = await DatabaseService.to.getDaySummariesByDate(date);

      // Convert to DayRecord
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

      records.value = newRecords;
      hasMore.value = false; // Date filter does not support pagination
    } catch (e) {
      print('[History] Failed to load data by date: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get icon for action type
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

  /// Get color for action type
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

  /// Get Chinese name for action type
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
