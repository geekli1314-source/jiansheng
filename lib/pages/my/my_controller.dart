import 'package:get/get.dart';

class MyController extends GetxController {
  final switchValue = true.obs;

  void toggleSwitch(bool value) {
    switchValue.value = value;
  }
}
