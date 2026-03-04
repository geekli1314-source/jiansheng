import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../statistics_controller.dart';

class PeriodSelector extends GetView<StatisticsController> {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = ['week', 'moon', 'customize'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: periods.map((period) {
          return Obx(() {
            final isSelected = controller.selectedPeriod.value == period;
            return GestureDetector(
              onTap: () => controller.selectPeriod(period),
              child: Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontSize: 14,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}
