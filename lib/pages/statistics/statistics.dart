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
                title: 'Bicep Curl',
                activityKey: 'bicep_curl',
              ),
              const ActivityChartCard(
                title: 'Lat Pulldown',
                activityKey: 'lat_pulldown',
              ),
              const ActivityChartCard(
                title: 'Pec Fly',
                activityKey: 'pec_fly',
              ),
              Obx(() => TotalMovementsCard(total: controller.totalMovements.value)),
            ],
          ),
        ),
      ),
    );
  }
}
