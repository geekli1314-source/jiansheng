import 'package:get/get.dart';
import '../../services/bluetooth_service.dart';

class HomeController extends GetxController {
  final currentAction = 'IDLE'.obs;

  bool get isConnected => BluetoothService.to.connectedDevice.value != null;
  int get repCount => BluetoothService.to.repCount.value;
  bool get isExercising => BluetoothService.to.isExercising.value;

  @override
  void onInit() {
    super.onInit();
    ever(BluetoothService.to.connectedDevice, (_) => update());
    ever(BluetoothService.to.repCount, (_) => update());
    ever(BluetoothService.to.isExercising, (_) => update());
  }

  Future<void> startDetection() async {
    await BluetoothService.to.sendStart();
  }

  Future<void> stopDetection() async {
    await BluetoothService.to.sendStop();
  }

  Future<void> recountDetection() async {
    await BluetoothService.to.sendStop();
  }
}
