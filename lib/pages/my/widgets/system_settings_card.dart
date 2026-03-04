import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../my_controller.dart';

class SystemSettingsCard extends GetView<MyController> {
  const SystemSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Container(
        width: double.infinity,
        height: 300,
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
              // 蓝牙自动连接
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      'assets/images/bluetooth.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Bluetooth automatic connection',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  const Spacer(),
                  Obx(
                    () => Switch(
                      value: controller.switchValue.value,
                      onChanged: controller.toggleSwitch,
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
              // 数据存储位置
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      'assets/images/datastorage.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Data storage location',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  const Spacer(),
                  Text(
                    'this machine',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                ],
              ),
              // 清除数据
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      'assets/images/deta.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Clear data',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF9CA3AF),
                    size: 15,
                  ),
                ],
              ),
              // 关于应用
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      'assets/images/about.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'About the application',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF9CA3AF),
                    size: 15,
                  ),
                ],
              ),
              // 帮助与反馈
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.asset(
                      'assets/images/he.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Help and Feedback',
                    style: GoogleFonts.inter(letterSpacing: 0.0),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF9CA3AF),
                    size: 15,
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
