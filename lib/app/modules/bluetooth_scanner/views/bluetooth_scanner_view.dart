import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/bluetooth_scanner_controller.dart';

class BluetoothScannerView extends GetView<BluetoothScannerController> {
  const BluetoothScannerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BluetoothScannerView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BluetoothScannerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
