import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHeader extends StatelessWidget {
  const MyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Personal Profile',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
