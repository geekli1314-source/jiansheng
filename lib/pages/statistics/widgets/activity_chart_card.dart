import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../statistics_controller.dart';

class ActivityChartCard extends GetView<StatisticsController> {
  final Color iconBgColor;
  final String iconAsset;
  final String title;
  final Color barColor;
  final String activityKey;

  const ActivityChartCard({
    super.key,
    required this.iconBgColor,
    required this.iconAsset,
    required this.title,
    required this.barColor,
    required this.activityKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x0E000000),
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon + title
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        iconAsset,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bar chart – reactive to period selection
              Obx(() {
                final data = controller.getChartData(activityKey);
                final labels = controller.getXLabels();
                final summaryText = controller.getSummaryText(activityKey);
                final maxY = data.isEmpty
                    ? 10.0
                    : (data.reduce((a, b) => a > b ? a : b) * 1.3)
                        .ceilToDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) =>
                                  barColor.withValues(alpha: 0.85),
                              tooltipRoundedRadius: 6,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  rod.toY.toInt().toString(),
                                  GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      labels[idx],
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 4,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: const Color(0xFFF3F4F6),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: data.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: barColor,
                                  width: _barWidth(data.length),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Summary text
                    Text(
                      summaryText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 4) return 28;
    if (count <= 7) return 20;
    return 12;
  }
}
