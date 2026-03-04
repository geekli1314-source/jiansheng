import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';

class StatisticsController extends GetxController {
  final selectedPeriod = 'week'.obs;
  final totalMovements = '0'.obs;

  /// 三种运动的图表数据
  final bicepCurlData = <double>[].obs;
  final latPulldownData = <double>[].obs;
  final pecFlyData = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  void selectPeriod(String period) {
    selectedPeriod.value = period;
    loadStatistics();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    switch (selectedPeriod.value) {
      case 'week':
        await _loadWeeklyStats();
        break;
      case 'moon':
        await _loadMonthlyStats();
        break;
      case 'customize':
        await _loadYearlyStats();
        break;
    }
    _updateTotalMovements();
  }

  /// 加载周统计数据
  Future<void> _loadWeeklyStats() async {
    final stats = await DatabaseService.to.getWeeklyStats();
    bicepCurlData.value = stats['bicep_curl'] ?? List.filled(7, 0.0);
    latPulldownData.value = stats['lat_pulldown'] ?? List.filled(7, 0.0);
    pecFlyData.value = stats['pec_fly'] ?? List.filled(7, 0.0);
  }

  /// 加载月统计数据
  Future<void> _loadMonthlyStats() async {
    final stats = await DatabaseService.to.getMonthlyStats();
    bicepCurlData.value = stats['bicep_curl'] ?? List.filled(4, 0.0);
    latPulldownData.value = stats['lat_pulldown'] ?? List.filled(4, 0.0);
    pecFlyData.value = stats['pec_fly'] ?? List.filled(4, 0.0);
  }

  /// 加载年统计数据
  Future<void> _loadYearlyStats() async {
    final stats = await DatabaseService.to.getYearlyStats();
    bicepCurlData.value = stats['bicep_curl'] ?? List.filled(12, 0.0);
    latPulldownData.value = stats['lat_pulldown'] ?? List.filled(12, 0.0);
    pecFlyData.value = stats['pec_fly'] ?? List.filled(12, 0.0);
  }

  /// 更新总运动次数
  void _updateTotalMovements() {
    final bicepTotal = bicepCurlData.fold(0.0, (a, b) => a + b);
    final latTotal = latPulldownData.fold(0.0, (a, b) => a + b);
    final pecTotal = pecFlyData.fold(0.0, (a, b) => a + b);
    final total = (bicepTotal + latTotal + pecTotal).toInt();
    totalMovements.value = total.toString();
  }

  /// 获取指定运动的图表数据
  List<double> getChartData(String activityKey) {
    switch (activityKey) {
      case 'bicep_curl':
        return bicepCurlData;
      case 'lat_pulldown':
        return latPulldownData;
      case 'pec_fly':
        return pecFlyData;
      default:
        return [];
    }
  }

  /// 获取X轴标签
  List<String> getXLabels() {
    switch (selectedPeriod.value) {
      case 'week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'moon':
        return ['W1', 'W2', 'W3', 'W4'];
      case 'customize':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      default:
        return [];
    }
  }

  /// 获取汇总文本
  String getSummaryText(String activityKey) {
    final data = getChartData(activityKey);
    if (data.isEmpty) return '';
    final total = data.fold(0.0, (a, b) => a + b).toInt();
    switch (selectedPeriod.value) {
      case 'week':
        return 'This week: $total';
      case 'moon':
        return 'This month: $total';
      case 'customize':
        return 'This year: $total';
      default:
        return '';
    }
  }

  /// 获取运动类型对应的图标
  IconData getIconForType(String activityKey) {
    switch (activityKey) {
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

  /// 获取运动类型对应的颜色
  Color getColorForType(String activityKey) {
    switch (activityKey) {
      case 'bicep_curl':
        return const Color(0xFF3B82F6); // 蓝色
      case 'lat_pulldown':
        return const Color(0xFF22C55E); // 绿色
      case 'pec_fly':
        return const Color(0xFFA855F7); // 紫色
      default:
        return const Color(0xFF3B82F6);
    }
  }

  /// 获取背景色
  Color getBgColorForType(String activityKey) {
    switch (activityKey) {
      case 'bicep_curl':
        return const Color(0xFFDBEAFE);
      case 'lat_pulldown':
        return const Color(0xFFDCFCE7);
      case 'pec_fly':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFDBEAFE);
    }
  }
}
