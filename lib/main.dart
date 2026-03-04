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
    // App 启动后延迟自动连接默认设备
    Future.delayed(const Duration(seconds: 2), () {
      _autoConnectDevice();
    });
  }

  /// 自动连接默认设备
  void _autoConnectDevice() async {
    // 检查是否开启了自动连接
    final settings = await DatabaseService.to.getUserSettings();
    final autoConnect = settings['auto_connect_bluetooth'];

    // 默认开启，如果设置不存在或设置为true则自动连接
    if (autoConnect == null || autoConnect == 'true') {
      final bluetoothService = Get.find<BluetoothService>();
      await bluetoothService.autoConnectDefaultDevice();
    } else {
      print('[App] 自动连接已关闭，跳过自动连接');
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
