import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'statistics_controller.dart';
import 'widgets/period_selector.dart';
import 'widgets/activity_chart_card.dart';
import 'widgets/total_movements_card.dart';

class StatisticsWidget extends GetView<StatisticsController> {
  const StatisticsWidget({super.key});

  static String routeName = 'statistics';
  static String routePath = '/statistics';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Statistics',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 24,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              const PeriodSelector(),
              const ActivityChartCard(
                iconBgColor: Color(0xFFDBEAFE),
                iconAsset: 'assets/images/push.png',
                title: 'Push-up',
                barColor: Color(0xFF3B82F6),
                activityKey: 'pushup',
              ),
              const ActivityChartCard(
                iconBgColor: Color(0xFFDCFCE7),
                iconAsset: 'assets/images/running.png',
                title: 'Running',
                barColor: Color(0xFF22C55E),
                activityKey: 'running',
              ),
              const ActivityChartCard(
                iconBgColor: Color(0xFFF3E8FF),
                iconAsset: 'assets/images/walk.png',
                title: 'Walking',
                barColor: Color(0xFFA855F7),
                activityKey: 'walking',
              ),
              Obx(() => TotalMovementsCard(total: controller.totalMovements.value)),
            ],
          ),
        ),
      ),
    );
  }
}
