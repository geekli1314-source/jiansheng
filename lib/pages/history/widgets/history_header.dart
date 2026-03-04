import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'History',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 24,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
