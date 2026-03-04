import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityItemWidget extends StatelessWidget {
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String name;
  final String value;

  const ActivityItemWidget({
    super.key,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.name,
    required this.value,
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
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                iconAsset,
                width: iconWidth,
                height: iconHeight,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
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
