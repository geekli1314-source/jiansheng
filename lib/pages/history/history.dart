import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'history_controller.dart';
import 'widgets/history_header.dart';
import 'widgets/date_selector.dart';
import 'widgets/activity_day_card.dart';
import 'widgets/more_records_card.dart';

class HistoryWidget extends GetView<HistoryController> {
  const HistoryWidget({super.key});

  static String routeName = 'history';
  static String routePath = '/history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Colors.white],
            stops: [0.5, 0.8],
            begin: Alignment(1, 1),
            end: Alignment(-1, -1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ListView(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              const HistoryHeader(),
              const DateSelector(),
              Obx(
                () => Column(
                  children: controller.records
                      .map((record) => ActivityDayCard(record: record))
                      .toList(),
                ),
              ),
              const MoreRecordsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
