import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/main_shell/main_shell.dart';
import 'pages/main_shell/main_shell_controller.dart';
import 'pages/home/home_controller.dart';
import 'pages/statistics/statistics_controller.dart';
import 'pages/history/history_controller.dart';
import 'pages/my/my_controller.dart';
import 'services/bluetooth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fitness Movement Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(BluetoothService());
        Get.put(MainShellController());
        Get.put(HomeController());
        Get.put(StatisticsController());
        Get.put(HistoryController());
        Get.put(MyController());
      }),
      home: const MainShell(),
    );
  }
}
