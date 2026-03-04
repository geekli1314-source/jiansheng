import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../history_controller.dart';
import 'activity_item.dart';

class ActivityDayCard extends StatelessWidget {
  final DayRecord record;

  const ActivityDayCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
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
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.dayName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                      record.date,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 12,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...record.activities.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActivityItemWidget(
                    icon: item.icon,
                    iconColor: item.iconColor,
                    name: item.name,
                    value: item.value,
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
