import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_controller.dart';

class ActionButtons extends GetView<HomeController> {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: GetBuilder<HomeController>(
        builder: (_) => Row(
          children: [
            // Start 按钮
            Expanded(
              child: GestureDetector(
                onTap: controller.isExercising ? null : controller.startDetection,
                child: Opacity(
                  opacity: controller.isExercising ? 0.4 : 1.0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xCD22C55E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.caretRight,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Start',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Stop 按钮
            Expanded(
              child: GestureDetector(
                onTap: controller.stopDetection,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xCBEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Stop',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Recount 按钮
            Expanded(
              child: GestureDetector(
                onTap: controller.recountDetection,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xCBEAB308),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Recount',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
