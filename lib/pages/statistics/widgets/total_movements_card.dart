import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalMovementsCard extends StatelessWidget {
  final String total;

  const TotalMovementsCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 100),
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
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total number of movements',
                style: GoogleFonts.inter(
                  letterSpacing: 0.0,
                ),
              ),
              Text(
                total,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                  fontSize: 24,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
