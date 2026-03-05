import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/main_shell/main_shell.dart';
import 'pages/main_shell/main_shell_controller.dart';
import 'pages/home/home_controller.dart';
import 'pages/statistics/statistics_controller.dart';
import 'pages/history/history_controller.dart';
import 'pages/my/my_controller.dart';
import 'services/bluetooth_service.dart';
import 'services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Auto connect to default device after app launch
    Future.delayed(const Duration(seconds: 2), () {
      _autoConnectDevice();
    });
  }

  /// Auto connect to default device
  void _autoConnectDevice() async {
    // Check if auto connect is enabled
    final settings = await DatabaseService.to.getUserSettings();
    final autoConnect = settings['auto_connect_bluetooth'];

    // Default enabled, auto connect if setting not exists or set to true
    if (autoConnect == null || autoConnect == 'true') {
      final bluetoothService = Get.find<BluetoothService>();
      await bluetoothService.autoConnectDefaultDevice();
    } else {
      print('[App] Auto connect is disabled, skipping auto connect');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fitness Movement Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(DatabaseService());
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
