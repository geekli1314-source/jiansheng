import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../my_controller.dart';

class TrainingObjectivesCard extends GetView<MyController> {
  const TrainingObjectivesCard({super.key});

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
              color: Color(0x0C000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row
              Row(
                children: [
                  Text(
                    'Training objectives',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Daily target frequency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily target frequency',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  Obx(() => Text(
                    controller.dailyTarget.value.toString(),
                    style: GoogleFonts.inter(
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              // Reminder time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder time',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  Obx(() => Text(
                    controller.reminderTime.value,
                    style: GoogleFonts.inter(
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              // Today's completion progress
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed today',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                      Obx(() => Text(
                        controller.todayProgressText,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF3B82F6),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Obx(() => Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: controller.todayProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              // Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total Reps',
                    controller.totalReps,
                    Icons.fitness_center,
                    const Color(0xFF3B82F6),
                  ),
                  _buildStatItem(
                    'Consecutive Days',
                    controller.consecutiveDays,
                    Icons.local_fire_department,
                    const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    RxInt value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          value.value.toString(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        )),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
