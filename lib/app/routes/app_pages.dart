import 'package:get/get.dart';

import '../modules/bluetooth_scanner/bindings/bluetooth_scanner_binding.dart';
import '../modules/bluetooth_scanner/views/bluetooth_scanner_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/print_tester/bindings/print_tester_binding.dart';
import '../modules/print_tester/views/print_tester_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.BLUETOOTH_SCANNER,
      page: () => const BluetoothScannerView(),
      binding: BluetoothScannerBinding(),
    ),
    GetPage(
      name: _Paths.PRINT_TESTER,
      page: () => const PrintTesterView(),
      binding: PrintTesterBinding(),
    ),
  ];
}
