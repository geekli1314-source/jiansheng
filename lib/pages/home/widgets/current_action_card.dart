import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_controller.dart';

class CurrentActionCard extends GetView<HomeController> {
  const CurrentActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x0D000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GetBuilder<HomeController>(
            builder: (_) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: large rep count
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reps',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.repCount}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1D4ED8),
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: status + current action name
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Exercise status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: controller.isExercising
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.isExercising
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            controller.isExercising ? 'Running' : 'Ready',
                            style: GoogleFonts.inter(
                              color: controller.isExercising
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Current action name
                    Text(
                      'Action',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.currentAction.value,
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
