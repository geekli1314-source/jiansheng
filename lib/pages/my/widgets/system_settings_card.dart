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
              // 标题
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
              // 蓝牙自动连接
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
              // 数据存储位置
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
              // 清除数据
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
              // 关于应用
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
              // 帮助与反馈
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
              // 生成测试数据
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

  /// 生成测试数据
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

    int generatedCount = 0;

    // 遍历过去6个月的每一天
    for (int day = 0; day < 180; day++) {
      final date = sixMonthsAgo.add(Duration(days: day));

      // 随机决定这一天是否有运动 (70%概率)
      if (random.nextDouble() > 0.3) {
        // 为每种运动类型生成数据
        for (int exerciseType = 1; exerciseType <= 3; exerciseType++) {
          // 随机决定这种运动是否做了 (60%概率)
          if (random.nextDouble() > 0.4) {
            // 生成1-5组数据
            final groups = random.nextInt(5) + 1;

            for (int g = 0; g < groups; g++) {
              // 每组8-15次
              final count = random.nextInt(8) + 8;

              // 随机时间（当天任意时间）
              final hour = random.nextInt(14) + 8; // 8-21点
              final minute = random.nextInt(60);
              final timestamp = DateTime(
                date.year,
                date.month,
                date.day,
                hour,
                minute,
              );

              // 保存到数据库
              final record = ActionRecord(
                timestamp: timestamp,
                count: count,
                actionType: ExerciseType.getName(exerciseType),
                actionName: ExerciseType.getChineseName(exerciseType),
              );

              await DatabaseService.to.insertRecord(record);
              generatedCount++;
            }
          }
        }
      }
    }

    // 刷新数据
    await controller.loadUserStats();

    Get.snackbar(
      'Success',
      'Generated $generatedCount records for past 6 months',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
