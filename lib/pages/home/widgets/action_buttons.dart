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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.startDetection,
            child: Container(
              width: 110,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xCD22C55E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.caretRight,
                      color: Colors.white,
                      size: 24,
                    ),
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
          GestureDetector(
            onTap: controller.stopDetection,
            child: Container(
              width: 110,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xCBEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.stop_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
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
          GestureDetector(
            onTap: controller.recountDetection,
            child: Container(
              width: 110,
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
        ],
      ),
    );
  }
}
