import 'package:get/get.dart';

class ActivityItem {
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String name;
  final String value;

  const ActivityItem({
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.name,
    required this.value,
  });
}

class DayRecord {
  final String dayName;
  final String date;
  final List<ActivityItem> activities;

  const DayRecord({
    required this.dayName,
    required this.date,
    required this.activities,
  });
}

class HistoryController extends GetxController {
  final selectedDate = ''.obs;

  final records = <DayRecord>[
    DayRecord(
      dayName: 'Tuesday',
      date: '2026-02-24',
      activities: [
        ActivityItem(
          iconAsset: 'assets/images/push.png',
          iconWidth: 20,
          iconHeight: 15,
          name: 'push-up',
          value: '32reps',
        ),
        ActivityItem(
          iconAsset: 'assets/images/running.png',
          iconWidth: 20,
          iconHeight: 20,
          name: 'running',
          value: '5kilometer',
        ),
        ActivityItem(
          iconAsset: 'assets/images/walk.png',
          iconWidth: 20,
          iconHeight: 20,
          name: 'walk',
          value: '8000step',
        ),
      ],
    ),
    DayRecord(
      dayName: 'Monday',
      date: '2026-02-23',
      activities: [
        ActivityItem(
          iconAsset: 'assets/images/push.png',
          iconWidth: 20,
          iconHeight: 15,
          name: 'push-up',
          value: '32reps',
        ),
        ActivityItem(
          iconAsset: 'assets/images/running.png',
          iconWidth: 20,
          iconHeight: 20,
          name: 'running',
          value: '5kilometer',
        ),
        ActivityItem(
          iconAsset: 'assets/images/walk.png',
          iconWidth: 20,
          iconHeight: 20,
          name: 'walk',
          value: '8000step',
        ),
      ],
    ),
  ].obs;

  void selectDate(String date) {
    selectedDate.value = date;
  }
}
