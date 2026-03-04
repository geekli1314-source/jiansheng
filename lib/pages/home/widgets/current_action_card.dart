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
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/push.png',
                  width: 40,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Current action',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    controller.currentAction.value,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1D4ED8),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
