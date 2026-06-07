import 'package:get/get.dart';

import '../controllers/bluetooth_scanner_controller.dart';

class BluetoothScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BluetoothScannerController>(
      () => BluetoothScannerController(),
    );
  }
}
