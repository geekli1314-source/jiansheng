import 'package:get/get.dart';

class StatisticsController extends GetxController {
  final selectedPeriod = 'week'.obs;
  final totalMovements = '85'.obs;

  void selectPeriod(String period) {
    selectedPeriod.value = period;
  }

  // ===================== Demo chart data =====================
  // key: activity type  value: { period -> [values] }
  final Map<String, Map<String, List<double>>> _chartData = {
    'pushup': {
      'week': [3, 5, 4, 6, 7, 5, 8],
      'moon': [18, 22, 25, 20],
      'customize': [15, 20, 18, 25, 22, 30, 28, 35, 32, 40, 38, 42],
    },
    'running': {
      'week': [5, 8, 6, 9, 7, 10, 8],
      'moon': [28, 32, 35, 30],
      'customize': [20, 25, 30, 28, 35, 40, 38, 45, 42, 50, 48, 55],
    },
    'walking': {
      'week': [8, 10, 7, 12, 9, 14, 11],
      'moon': [40, 45, 50, 42],
      'customize': [30, 35, 40, 38, 45, 50, 48, 55, 52, 60, 58, 65],
    },
  };

  /// Returns chart bar values for given activity and current period
  List<double> getChartData(String activityKey) {
    return _chartData[activityKey]?[selectedPeriod.value] ?? [];
  }

  /// Returns x-axis labels for current period
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

  /// Returns the summary text for given activity and current period
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
}
