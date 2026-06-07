import 'package:get/get.dart';

import '../controllers/print_tester_controller.dart';

class PrintTesterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrintTesterController>(
      () => PrintTesterController(),
    );
  }
}
