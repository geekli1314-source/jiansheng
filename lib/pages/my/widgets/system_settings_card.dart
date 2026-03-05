import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../my_controller.dart';
import '../../../services/database_service.dart';

class SystemSettingsCard extends GetView<MyController> {
  const SystemSettingsCard({super.key});

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
              color: Color(0x0C000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                children: [
                  Text(
                    'System Settings',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bluetooth auto connect
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Automatic connection',
                      style: GoogleFonts.inter(letterSpacing: 0.0),
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.autoConnectBluetooth.value,
                      onChanged: controller.toggleAutoConnect,
                      thumbColor: WidgetStateProperty.all(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF3B82F6);
                        }
                        return const Color(0xFFE5E7EB);
                      }),
                      trackOutlineColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Language setting
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.language,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chinese language',
                      style: GoogleFonts.inter(letterSpacing: 0.0),
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.useChineseLanguage.value,
                      onChanged: controller.toggleLanguage,
                      thumbColor: WidgetStateProperty.all(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF8B5CF6);
                        }
                        return const Color(0xFFE5E7EB);
                      }),
                      trackOutlineColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data storage location
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storage,
                      color: Color(0xFF22C55E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data storage location',
                      style: GoogleFonts.inter(letterSpacing: 0.0),
                    ),
                  ),
                  Obx(() => Text(
                    controller.dataStorageLocation.value,
                    style: GoogleFonts.inter(
                      letterSpacing: 0.0,
                      color: const Color(0xFF6B7280),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              // Clear data
              InkWell(
                onTap: () => _showClearDataDialog(context),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Clear data',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9CA3AF),
                      size: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // About app
              InkWell(
                onTap: () => _showAboutDialog(context),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFFA855F7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'About the application',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9CA3AF),
                      size: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Help & feedback
              InkWell(
                onTap: () => _showHelpDialog(context),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Help and Feedback',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9CA3AF),
                      size: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Generate test data
              InkWell(
                onTap: () => _showGenerateTestDataDialog(context),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.data_array,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generate test data',
                        style: GoogleFonts.inter(letterSpacing: 0.0),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9CA3AF),
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Data'),
        content: const Text('Are you sure you want to clear all exercise data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllData();
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'All data has been cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fitness Movement Detection'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A smart fitness tracking app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For help and support:'),
            SizedBox(height: 8),
            Text('Email: support@fitness.app'),
            SizedBox(height: 8),
            Text('Website: www.fitness.app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGenerateTestDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Test Data'),
        content: const Text(
          'This will generate test data for the past 6 months.\n\n'
          'Existing data will be overwritten.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateTestData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  /// Generate test data
  Future<void> _generateTestData() async {
    Get.snackbar(
      'Generating',
      'Please wait...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    final random = Random();
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));

    // Read current language setting
    final settings = await DatabaseService.to.getUserSettings();
    final useChinese = settings['use_chinese_language'] != 'false';

    int generatedCount = 0;

    // Iterate through each day of the past 6 months
    for (int day = 0; day < 180; day++) {
      final date = sixMonthsAgo.add(Duration(days: day));

      // Randomly decide if there is exercise on this day (70% probability)
      if (random.nextDouble() > 0.3) {
        // Generate data for each exercise type
        for (int exerciseType = 1; exerciseType <= 3; exerciseType++) {
          // Randomly decide if this exercise was done (60% probability)
          if (random.nextDouble() > 0.4) {
            // Generate 1-5 groups of data
            final groups = random.nextInt(5) + 1;

            for (int g = 0; g < groups; g++) {
              // 8-15 reps per group
              final count = random.nextInt(8) + 8;

              // Random time (any time of the day)
              final hour = random.nextInt(14) + 8; // 8-21 o'clock
              final minute = random.nextInt(60);
              final timestamp = DateTime(
                date.year,
                date.month,
                date.day,
                hour,
                minute,
              );

              // Save to database
              final record = ActionRecord(
                timestamp: timestamp,
                count: count,
                actionType: ExerciseType.getName(exerciseType),
                actionName: ExerciseType.getNameByLocale(exerciseType, isChinese: useChinese),
              );

              await DatabaseService.to.insertRecord(record);
              generatedCount++;
            }
          }
        }
      }
    }

    // Refresh data
    await controller.loadUserStats();

    Get.snackbar(
      'Success',
      'Generated $generatedCount records for past 6 months',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
