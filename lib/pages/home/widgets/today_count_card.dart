import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayCountCard extends StatelessWidget {
  const TodayCountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
        height: 260,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Today's Count",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const _ActivityRow(
                imagePath: 'assets/images/push.png',
                imageWidth: 20,
                imageHeight: 15,
                name: 'push-up',
                time: '14:30',
                value: '32reps',
                duration: '15 minutes',
              ),
              const _ActivityRow(
                imagePath: 'assets/images/running.png',
                imageWidth: 20,
                imageHeight: 20,
                name: 'running',
                time: '08:15',
                value: '5kilometer',
                duration: '30 minutes ',
              ),
              const _ActivityRow(
                imagePath: 'assets/images/walk.png',
                imageWidth: 20,
                imageHeight: 20,
                name: 'walk',
                time: '19:45',
                value: '8000step',
                duration: '1 hour',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final String name;
  final String time;
  final String value;
  final String duration;

  const _ActivityRow({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.name,
    required this.time,
    required this.value,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                imagePath,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      time,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    duration,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
