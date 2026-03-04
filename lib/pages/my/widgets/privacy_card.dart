import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyCard extends StatelessWidget {
  const PrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 100),
      child: Container(
        width: double.infinity,
        height: 70,
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
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  'assets/images/anquan.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Protection',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Text(
                          'Your health data has been encrypted and stored',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4B5563),
                            fontSize: 12,
                            letterSpacing: 0.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
