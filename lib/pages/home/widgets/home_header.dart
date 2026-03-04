import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 60, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fitness Movement Detection',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 24,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Real time monitoring of your exercise status',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4B5563),
                  fontSize: 14,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
