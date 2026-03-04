import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';
import '../pages/home/home_controller.dart';

/// 动作状态常量（必须与模型训练顺序一致）
class GestureState {
  static const int none = -1; // 无状态
  static const int idle = 0; // 空闲/静止
  static const int curlUp = 1; // 弯举向上（二头肌弯举）
  static const int curlDown = 2; // 弯举向下（二头肌弯举）
  static const int latUp = 3; // 侧平举向上
  static const int latDown = 4; // 侧平举向下
  static const int flyUp = 5; // 飞鸟向上（哑铃飞鸟）
  static const int flyDown = 6; // 飞鸟向下（哑铃飞鸟）

  /// 动作名称数组
  static const List<String> names = [
    'IDLE', // 空闲
    'CURL_UP', // 弯举上
    'CURL_DOWN', // 弯举下
    'LAT_UP', // 侧平举上
    'LAT_DOWN', // 侧平举下
    'FLY_UP', // 飞鸟上
    'FLY_DOWN', // 飞鸟下
  ];

  /// 根据状态码获取动作名称
  static String getName(int state) {
    if (state >= 0 && state < names.length) {
      return names[state];
    }
    return 'UNKNOWN';
  }

  /// 根据状态码获取中文动作名称
  static String getChineseName(int state) {
    switch (state) {
      case idle:
        return '静止';
      case curlUp:
        return '弯举向上';
      case curlDown:
        return '弯举向下';
      case latUp:
        return '侧平举向上';
      case latDown:
        return '侧平举向下';
      case flyUp:
        return '飞鸟向上';
      case flyDown:
        return '飞鸟向下';
      default:
        return '未知';
    }
  }
}

/// 板子指令枚举
enum BoardCommand {
  pause, // 0 = 暂停
  start, // 1 = 开始
  stop, // 2 = 结束
}

class BluetoothService extends GetxService {
  static BluetoothService get to => Get.find();

  /// 全局单例实例
  static BluetoothService? _instance;

  /// 获取全局单例实例
  static BluetoothService get instance {
    _instance ??= Get.find<BluetoothService>();
    return _instance!;
  }

  // ==================== 板子 BLE UUID ====================
  static const String _serviceUuid = '19b10000-e8f2-537e-4f6c-d104768a1214';
  static const String _repCountUuid = '19b10001-e8f2-537e-4f6c-d104768a1214'; // Notify：板子推送次数
  static const String _clientOrderUuid = '19b10002-e8f2-537e-4f6c-d104768a1214'; // Write：App 下发指令

  // ==================== 可观察状态 ====================
  final RxBool isScanning = false.obs;
  final RxList<BluetoothDevice> scannedDevices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isConnecting = false.obs;
  final RxString connectionStatus = 'Not Connected'.obs;

  /// 板子推送的完成次数
  final RxInt repCount = 0.obs;

  /// 当前是否正在运动（由 App 指令控制）
  final RxBool isExercising = false.obs;

  // ==================== 内部变量 ====================
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _repCountSubscription;

  BluetoothCharacteristic? _repCountChar; // 接收次数
  BluetoothCharacteristic? _clientOrderChar; // 发送指令

  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _repCountSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initBluetooth() async {
    await requestPermissions();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        connectionStatus.value = 'Bluetooth is off';
      }
    });
  }

  /// 自动连接默认设备
  Future<bool> autoConnectDefaultDevice() async {
    try {
      final defaultDevice = await DatabaseService.to.getDefaultDevice();
      if (defaultDevice == null) {
        print('[BLE] 没有保存的默认设备');
        return false;
      }

      final deviceId = defaultDevice['id'];
      final deviceName = defaultDevice['name'];
      print('[BLE] 尝试自动连接默认设备: $deviceName ($deviceId)');

      // 检查蓝牙是否开启
      if (!await isBluetoothEnabled()) {
        print('[BLE] 蓝牙未开启，无法自动连接');
        return false;
      }

      // 扫描并查找设备
      connectionStatus.value = 'Searching for $deviceName...';

      // 开始扫描
      scannedDevices.clear();
      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.remoteId.str == deviceId) {
            // 找到设备，停止扫描并连接
            FlutterBluePlus.stopScan();
            print('[BLE] 找到默认设备，开始连接...');
            connectToDevice(result.device);
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      // 等待扫描完成
      await Future.delayed(const Duration(seconds: 5));

      return connectedDevice.value != null;
    } catch (e) {
      print('[BLE] 自动连接失败: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (isScanning.value) return;

    bool hasPermission = await requestPermissions();
    if (!hasPermission) {
      connectionStatus.value = 'Permission denied';
      return;
    }

    bool enabled = await isBluetoothEnabled();
    if (!enabled) {
      connectionStatus.value = 'Please turn on Bluetooth';
      return;
    }

    scannedDevices.clear();
    isScanning.value = true;
    connectionStatus.value = 'Scanning...';

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!scannedDevices.any((d) => d.remoteId == result.device.remoteId)) {
          scannedDevices.add(result.device);
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: timeout);

    await Future.delayed(timeout);
    stopScan();
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    isScanning.value = false;
    if (connectedDevice.value == null) {
      connectionStatus.value = 'Not Connected';
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (isConnecting.value) return false;

    isConnecting.value = true;
    connectionStatus.value = 'Connecting...';
    print('[BLE] 正在连接设备: ${device.platformName} (${device.remoteId})');

    try {
      await device.connect(autoConnect: false, mtu: null);

      // 监听连接状态
      _connectionSubscription = device.connectionState.listen((state) {
        print('[BLE] 连接状态变化: $state');
        if (state == BluetoothConnectionState.connected) {
          connectedDevice.value = device;
          connectionStatus.value = 'Connected: ${device.platformName}';
          isConnecting.value = false;
          print('[BLE] 已连接: ${device.platformName}');
        } else if (state == BluetoothConnectionState.disconnected) {
          print('[BLE] 设备已断开: ${device.platformName}');
          _onDeviceDisconnected();
        }
      });

      // 等待连接成功
      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );

      // 发现服务并订阅特征
      await _discoverAndSubscribe(device);

      // 保存为默认设备
      await _saveAsDefaultDevice(device);

      return true;
    } catch (e) {
      print('[BLE] 连接失败: $e');
      connectionStatus.value = 'Connection failed: $e';
      isConnecting.value = false;
      return false;
    }
  }

  /// 发现板子服务，绑定特征值并订阅次数通知
  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    print('[BLE] 开始发现服务...');
    final services = await device.discoverServices();
    print('[BLE] 发现 ${services.length} 个服务');

    bool serviceFound = false;
    for (final service in services) {
      final sUuid = service.serviceUuid.toString().toLowerCase();
      print('[BLE] 服务 UUID: $sUuid');

      if (sUuid == _serviceUuid) {
        serviceFound = true;
        print('[BLE] ✓ 目标服务已找到');

        for (final char in service.characteristics) {
          final uuid = char.characteristicUuid.toString().toLowerCase();
          print('[BLE] 特征 UUID: $uuid  属性: ${char.properties}');

          if (uuid == _repCountUuid) {
            // 订阅次数通知
            _repCountChar = char;
            await char.setNotifyValue(true);
            print('[BLE] ✓ repCount 特征订阅成功');
            _repCountSubscription?.cancel();
            // 使用 onValueReceived 接收板子主动 Notify 推送
            _repCountSubscription = char.onValueReceived.listen((value) {
              if (value.isNotEmpty) {
                // 板子发送 int（4字节小端序）
                int count = _bytesToInt(value);
                print('[BLE] << 收到次数通知: 原始=$value  解析=$count');
                repCount.value = count;
                // 保存到数据库
                _saveToDatabase(count);
              }
            });
          } else if (uuid == _clientOrderUuid) {
            // 记录写入特征
            _clientOrderChar = char;
            print('[BLE] ✓ clientOrder 特征已绑定');
          }
        }
        break;
      }
    }

    if (!serviceFound) {
      print('[BLE] ✗ 未找到目标服务 UUID: $_serviceUuid');
    }
  }

  /// 小端序字节数组转 int
  int _bytesToInt(List<int> bytes) {
    if (bytes.isEmpty) return 0;
    int result = 0;
    for (int i = 0; i < bytes.length && i < 4; i++) {
      result |= (bytes[i] & 0xFF) << (8 * i);
    }
    // 处理有符号 int
    if (result >= 0x80000000) result -= 0x100000000;
    return result;
  }

  /// 当前运动类型（1=二头弯举, 2=高位下拉, 3=蝴蝶机夹胸）
  int _currentExerciseType = ExerciseType.bicepCurl;

  /// 上次保存的次数，用于计算增量
  int _lastSavedCount = 0;

  /// 设置当前运动类型
  void setExerciseType(int type) {
    if (type >= 1 && type <= 3) {
      _currentExerciseType = type;
      // 更新主页显示
      try {
        final homeController = Get.find<HomeController>();
        homeController.updateCurrentExerciseType(type);
      } catch (_) {}
      print('[BLE] 运动类型已切换: ${ExerciseType.getChineseName(type)}');
    }
  }

  /// 保存次数到数据库
  void _saveToDatabase(int count) async {
    try {
      // 只保存增量（当前次数 - 上次保存次数）
      int increment = count - _lastSavedCount;
      if (increment <= 0) {
        // 如果次数减少或不变，可能是新的一组开始了，重置计数
        _lastSavedCount = 0;
        increment = count;
      }

      if (increment > 0) {
        await DatabaseService.to.saveRepCount(increment, exerciseType: _currentExerciseType);
        print('[BLE] ✓ 次数已保存到数据库: +$increment (总次数: $count), 类型: ${ExerciseType.getChineseName(_currentExerciseType)}');

        _lastSavedCount = count;

        // 刷新主页今日数据
        try {
          final homeController = Get.find<HomeController>();
          homeController.loadTodayActivities();
        } catch (_) {}
      }
    } catch (e) {
      print('[BLE] ✗ 保存到数据库失败: $e');
    }
  }

  /// 重置计数（在开始新一组时调用）
  void resetRepCount() {
    _lastSavedCount = 0;
    print('[BLE] 计数已重置');
  }

  /// 保存设备为默认设备
  Future<void> _saveAsDefaultDevice(BluetoothDevice device) async {
    try {
      final deviceName = device.platformName.isNotEmpty
          ? device.platformName
          : 'Unknown Device';
      await DatabaseService.to.saveDefaultDevice(
        device.remoteId.str,
        deviceName,
      );
      print('[BLE] ✓ 已保存为默认设备: $deviceName');
    } catch (e) {
      print('[BLE] ✗ 保存默认设备失败: $e');
    }
  }

  /// 断开时内部清理
  void _onDeviceDisconnected() {
    print('[BLE] 执行断开清理，重置所有状态');
    connectedDevice.value = null;
    connectionStatus.value = 'Not Connected';
    isConnecting.value = false;
    isExercising.value = false;
    _repCountChar = null;
    _clientOrderChar = null;
    _repCountSubscription?.cancel();
    _repCountSubscription = null;
  }

  // ==================== 指令方法 ====================

  /// 向板子发送指令
  Future<bool> _sendCommand(int cmd) async {
    if (_clientOrderChar == null) {
      print('[BLE] ✗ 发送指令失败: clientOrder 特征未绑定');
      return false;
    }
    try {
      print('[BLE] >> 发送指令: $cmd');
      await _clientOrderChar!.write([cmd], withoutResponse: false);
      print('[BLE] ✓ 指令发送成功: $cmd');
      return true;
    } catch (e) {
      print('[BLE] ✗ 指令发送失败: $e');
      return false;
    }
  }

  /// 开始运动（指令: 1）
  Future<bool> sendStart() async {
    print('[BLE] 发送开始指令');
    // 重置计数，准备新一组运动
    resetRepCount();
    final ok = await _sendCommand(BoardCommand.start.index);
    if (ok) isExercising.value = true;
    return ok;
  }

  /// 暂停运动（指令: 0）
  Future<bool> sendPause() async {
    print('[BLE] 发送暂停指令');
    final ok = await _sendCommand(BoardCommand.pause.index);
    if (ok) isExercising.value = false;
    return ok;
  }

  /// 结束运动（指令: 2）
  Future<bool> sendStop() async {
    print('[BLE] 发送结束指令');
    final ok = await _sendCommand(BoardCommand.stop.index);
    if (ok) {
      isExercising.value = false;
      repCount.value = 0; // 本地重置计数
    }
    return ok;
  }

  // ==================== 工具方法 ====================

  Future<void> disconnect() async {
    if (connectedDevice.value != null) {
      await connectedDevice.value!.disconnect();
      _onDeviceDisconnected();
    }
  }

  String getDeviceName(BluetoothDevice device) {
    return device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device (${device.remoteId.str.substring(device.remoteId.str.length - 5)})';
  }
}
