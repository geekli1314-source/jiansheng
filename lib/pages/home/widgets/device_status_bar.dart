import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_controller.dart';
import '../../bluetooth/device_scan_page.dart';

class DeviceStatusBar extends GetView<HomeController> {
  const DeviceStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: GestureDetector(
        onTap: () {
          if (!controller.isConnected) {
            Get.to(() => const DeviceScanPage());
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                GetBuilder<HomeController>(
                  builder: (_) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: controller.isConnected
                          ? const Color(0xFF22C55E)
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: GetBuilder<HomeController>(
                    builder: (_) => Text(
                      controller.isConnected
                          ? 'Device connected'
                          : 'Tap to connect',
                      style: GoogleFonts.inter(letterSpacing: 0.0),
                    ),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.asset(
                    'assets/images/bluetooth.png',
                    width: 10,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Bluetooth',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2563EB),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
