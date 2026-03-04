import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends GetxService {
  static BluetoothService get to => Get.find();

  final RxBool isScanning = false.obs;
  final RxList<BluetoothDevice> scannedDevices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isConnecting = false.obs;
  final RxString connectionStatus = 'Not Connected'.obs;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
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

    try {
      await device.connect(autoConnect: false, mtu: null);

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          connectedDevice.value = device;
          connectionStatus.value = 'Connected: ${device.platformName}';
          isConnecting.value = false;
        } else if (state == BluetoothConnectionState.disconnected) {
          connectedDevice.value = null;
          connectionStatus.value = 'Not Connected';
          isConnecting.value = false;
        }
      });

      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );

      return true;
    } catch (e) {
      connectionStatus.value = 'Connection failed: $e';
      isConnecting.value = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice.value != null) {
      await connectedDevice.value!.disconnect();
      connectedDevice.value = null;
      connectionStatus.value = 'Not Connected';
    }
  }

  String getDeviceName(BluetoothDevice device) {
    return device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device (${device.remoteId.str.substring(device.remoteId.str.length - 5)})';
  }
}
