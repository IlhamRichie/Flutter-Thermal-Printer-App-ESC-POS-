import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bluetooth_scanner_controller.dart';

class BluetoothScannerView extends GetView<BluetoothScannerController> {
  const BluetoothScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Thermal Printer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        // Nampilin pesan kalau belum ada device yang di-pair di HP
        if (controller.devices.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada perangkat Bluetooth yang ter-pair.\nCek setting Bluetooth HP lo ya bro.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Nampilin list device kalau ada
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.devices.length,
          itemBuilder: (context, index) {
            final device = controller.devices[index];
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.print, color: Colors.white),
                ),
                title: Text(
                  device.name ?? 'Unknown Device',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(device.address ?? 'No MAC Address'),
                trailing: ElevatedButton(
                  onPressed: () {
                    controller.connectToDevice(device);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Connect'),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}