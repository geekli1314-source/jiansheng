import 'package:get/get.dart';
import '../../services/bluetooth_service.dart';

class HomeController extends GetxController {
  final currentAction = 'push-up'.obs;

  bool get isConnected => BluetoothService.to.connectedDevice.value != null;

  @override
  void onInit() {
    super.onInit();
    ever(BluetoothService.to.connectedDevice, (_) {
      update();
    });
  }

  void startDetection() {
    // TODO: implement start logic
  }

  void stopDetection() {
    // TODO: implement stop logic
  }

  void recountDetection() {
    // TODO: implement recount logic
  }
}
