import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainingObjectivesCard extends StatelessWidget {
  const TrainingObjectivesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
        height: 230,
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
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 标题行
              Row(
                children: [
                  Text(
                    'Training objectives',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
              // 日目标频次
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily target frequency',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  Text(
                    '100',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                ],
              ),
              // 提醒时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder time',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  Text(
                    '08:00',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                ],
              ),
              // 今日完成进度
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed today',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                      Text(
                        '8 / 15',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF3B82F6),
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
