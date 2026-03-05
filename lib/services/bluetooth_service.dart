import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';
import '../pages/home/home_controller.dart';

/// Gesture state constants (must match model training order)
class GestureState {
  static const int none = -1; // No state
  static const int idle = 0; // Idle/Stationary
  static const int curlUp = 1; // Curl up (bicep curl)
  static const int curlDown = 2; // Curl down (bicep curl)
  static const int latUp = 3; // Lateral raise up
  static const int latDown = 4; // Lateral raise down
  static const int flyUp = 5; // Fly up (dumbbell fly)
  static const int flyDown = 6; // Fly down (dumbbell fly)

  /// Gesture name array
  static const List<String> names = [
    'IDLE', // Idle
    'CURL_UP', // Curl up
    'CURL_DOWN', // Curl down
    'LAT_UP', // Lateral raise up
    'LAT_DOWN', // Lateral raise down
    'FLY_UP', // Fly up
    'FLY_DOWN', // Fly down
  ];

  /// Get gesture name by state code
  static String getName(int state) {
    if (state >= 0 && state < names.length) {
      return names[state];
    }
    return 'UNKNOWN';
  }

  /// Get Chinese gesture name by state code
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

/// Board command enum
enum BoardCommand {
  pause, // 0 = Pause
  start, // 1 = Start
  stop, // 2 = Stop
}

class BluetoothService extends GetxService {
  static BluetoothService get to => Get.find();

  /// Global singleton instance
  static BluetoothService? _instance;

  /// Get global singleton instance
  static BluetoothService get instance {
    _instance ??= Get.find<BluetoothService>();
    return _instance!;
  }

  // ==================== Board BLE UUID ====================
  static const String _serviceUuid = '19b10000-e8f2-537e-4f6c-d104768a1214';
  static const String _repCountUuid = '19b10001-e8f2-537e-4f6c-d104768a1214'; // Notify: Board push count
  static const String _clientOrderUuid = '19b10002-e8f2-537e-4f6c-d104768a1214'; // Write: App send command

  // ==================== Observable States ====================
  final RxBool isScanning = false.obs;
  final RxList<BluetoothDevice> scannedDevices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isConnecting = false.obs;
  final RxString connectionStatus = 'Not Connected'.obs;

  /// Board push completion count
  final RxInt repCount = 0.obs;

  /// Whether currently exercising (controlled by App command)
  final RxBool isExercising = false.obs;

  // ==================== Internal Variables ====================
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _repCountSubscription;

  BluetoothCharacteristic? _repCountChar; // Receive count
  BluetoothCharacteristic? _clientOrderChar; // Send command

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

  /// Auto connect to default device
  Future<bool> autoConnectDefaultDevice() async {
    try {
      final defaultDevice = await DatabaseService.to.getDefaultDevice();
      if (defaultDevice == null) {
        print('[BLE] No saved default device');
        return false;
      }

      final deviceId = defaultDevice['id'];
      final deviceName = defaultDevice['name'];
      print('[BLE] Trying to auto connect default device: $deviceName ($deviceId)');

      // Check if Bluetooth is enabled
      if (!await isBluetoothEnabled()) {
        print('[BLE] Bluetooth is off, cannot auto connect');
        return false;
      }

      // Scan and find device
      connectionStatus.value = 'Searching for $deviceName...';

      // Start scanning
      scannedDevices.clear();
      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.remoteId.str == deviceId) {
            // Found device, stop scan and connect
            FlutterBluePlus.stopScan();
            print('[BLE] Found default device, start connecting...');
            connectToDevice(result.device);
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 5));

      return connectedDevice.value != null;
    } catch (e) {
      print('[BLE] Auto connect failed: $e');
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

      // Listen to connection state
      _connectionSubscription = device.connectionState.listen((state) {
        print('[BLE] Connection state changed: $state');
        if (state == BluetoothConnectionState.connected) {
          connectedDevice.value = device;
          connectionStatus.value = 'Connected: ${device.platformName}';
          isConnecting.value = false;
          print('[BLE] Connected: ${device.platformName}');
        } else if (state == BluetoothConnectionState.disconnected) {
          print('[BLE] Device disconnected: ${device.platformName}');
          _onDeviceDisconnected();
        }
      });

      // Wait for connection success
      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );

      // Discover services and subscribe to characteristics
      await _discoverAndSubscribe(device);

      // Save as default device
      await _saveAsDefaultDevice(device);

      return true;
    } catch (e) {
      print('[BLE] 连接失败: $e');
      connectionStatus.value = 'Connection failed: $e';
      isConnecting.value = false;
      return false;
    }
  }

  /// Discover board services, bind characteristics and subscribe to count notifications
  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    print('[BLE] Starting service discovery...');
    final services = await device.discoverServices();
    print('[BLE] Found ${services.length} services');

    bool serviceFound = false;
    for (final service in services) {
      final sUuid = service.serviceUuid.toString().toLowerCase();
      print('[BLE] Service UUID: $sUuid');

      if (sUuid == _serviceUuid) {
        serviceFound = true;
        print('[BLE] ✓ Target service found');

        for (final char in service.characteristics) {
          final uuid = char.characteristicUuid.toString().toLowerCase();
          print('[BLE] Characteristic UUID: $uuid  Properties: ${char.properties}');

          if (uuid == _repCountUuid) {
            // Subscribe to count notification
            _repCountChar = char;
            await char.setNotifyValue(true);
            print('[BLE] ✓ repCount characteristic subscribed');
            _repCountSubscription?.cancel();
            // Use onValueReceived to receive board active Notify push
            _repCountSubscription = char.onValueReceived.listen((value) {
              if (value.isNotEmpty) {
                // Board sends int (4 bytes little-endian)
                int count = _bytesToInt(value);
                print('[BLE] << Received count notification: raw=$value  parsed=$count');
                repCount.value = count;
                // Save to database
                _saveToDatabase(count);
              }
            });
          } else if (uuid == _clientOrderUuid) {
            // Record write characteristic
            _clientOrderChar = char;
            print('[BLE] ✓ clientOrder characteristic bound');
          }
        }
        break;
      }
    }

    if (!serviceFound) {
      print('[BLE] ✗ Target service UUID not found: $_serviceUuid');
    }
  }

  /// Little-endian byte array to int
  int _bytesToInt(List<int> bytes) {
    if (bytes.isEmpty) return 0;
    int result = 0;
    for (int i = 0; i < bytes.length && i < 4; i++) {
      result |= (bytes[i] & 0xFF) << (8 * i);
    }
    // Handle signed int
    if (result >= 0x80000000) result -= 0x100000000;
    return result;
  }

  /// Current exercise type (1=Bicep Curl, 2=Lat Pulldown, 3=Pec Fly)
  int _currentExerciseType = ExerciseType.bicepCurl;

  /// Last saved count, used to calculate increment
  int _lastSavedCount = 0;

  /// Set current exercise type
  void setExerciseType(int type) {
    if (type >= 1 && type <= 3) {
      _currentExerciseType = type;
      // Update home page display
      try {
        final homeController = Get.find<HomeController>();
        homeController.updateCurrentExerciseType(type);
      } catch (_) {}
      print('[BLE] Exercise type switched: ${ExerciseType.getChineseName(type)}');
    }
  }

  /// Save count to database
  void _saveToDatabase(int count) async {
    try {
      // Only save increment (current count - last saved count)
      int increment = count - _lastSavedCount;
      if (increment <= 0) {
        // If count decreased or unchanged, new set may have started, reset counter
        _lastSavedCount = 0;
        increment = count;
      }

      if (increment > 0) {
        // Read language settings
        final settings = await DatabaseService.to.getUserSettings();
        final useChinese = settings['use_chinese_language'] != 'false';

        await DatabaseService.to.saveRepCount(
          increment,
          exerciseType: _currentExerciseType,
          useChinese: useChinese,
        );
        print('[BLE] ✓ Count saved to database: +$increment (total: $count), type: ${useChinese ? ExerciseType.getChineseName(_currentExerciseType) : ExerciseType.getEnglishName(_currentExerciseType)}');

        _lastSavedCount = count;

        // Refresh home page today data
        try {
          final homeController = Get.find<HomeController>();
          homeController.loadTodayActivities();
        } catch (_) {}
      }
    } catch (e) {
      print('[BLE] ✗ Failed to save to database: $e');
    }
  }

  /// Reset count (call when starting a new set)
  void resetRepCount() {
    _lastSavedCount = 0;
    print('[BLE] Count reset');
  }

  /// Save device as default device
  Future<void> _saveAsDefaultDevice(BluetoothDevice device) async {
    try {
      final deviceName = device.platformName.isNotEmpty
          ? device.platformName
          : 'Unknown Device';
      await DatabaseService.to.saveDefaultDevice(
        device.remoteId.str,
        deviceName,
      );
      print('[BLE] ✓ Saved as default device: $deviceName');
    } catch (e) {
      print('[BLE] ✗ Failed to save default device: $e');
    }
  }

  /// Internal cleanup on disconnect
  void _onDeviceDisconnected() {
    print('[BLE] Performing disconnect cleanup, resetting all states');
    connectedDevice.value = null;
    connectionStatus.value = 'Not Connected';
    isConnecting.value = false;
    isExercising.value = false;
    _repCountChar = null;
    _clientOrderChar = null;
    _repCountSubscription?.cancel();
    _repCountSubscription = null;
  }

  // ==================== Command Methods ====================

  /// Send command to board
  Future<bool> _sendCommand(int cmd) async {
    if (_clientOrderChar == null) {
      print('[BLE] ✗ Failed to send command: clientOrder characteristic not bound');
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

  /// Start exercise (command: 1)
  Future<bool> sendStart() async {
    print('[BLE] Sending start command');
    // Reset count, prepare for new set
    resetRepCount();
    final ok = await _sendCommand(BoardCommand.start.index);
    if (ok) isExercising.value = true;
    return ok;
  }

  /// Pause exercise (command: 0)
  Future<bool> sendPause() async {
    print('[BLE] Sending pause command');
    final ok = await _sendCommand(BoardCommand.pause.index);
    if (ok) isExercising.value = false;
    return ok;
  }

  /// Stop exercise (command: 2)
  Future<bool> sendStop() async {
    print('[BLE] Sending stop command');
    final ok = await _sendCommand(BoardCommand.stop.index);
    if (ok) {
      isExercising.value = false;
      repCount.value = 0; // Local reset count
    }
    return ok;
  }

  // ==================== Utility Methods ====================

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
