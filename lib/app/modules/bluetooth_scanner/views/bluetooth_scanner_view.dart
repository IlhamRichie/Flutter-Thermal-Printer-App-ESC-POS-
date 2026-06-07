import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_scanner_controller.dart';

class BluetoothScannerView extends GetView<BluetoothScannerController> {
  const BluetoothScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pilih Printer MINA',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            tooltip: 'Refresh Device',
            onPressed: () {
              controller.initBluetooth();
              Get.snackbar(
                "Scanning...", 
                "Mencari perangkat Bluetooth ulang...",
                snackPosition: SnackPosition.TOP, // Taruh atas biar ga numpuk sama error
                duration: const Duration(seconds: 1),
              );
            },
          )
        ],
      ),
      body: Obx(() {
        // --- UX: EMPTY STATE ---
        if (controller.devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bluetooth_disabled_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada printer yang ter-pair.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastiin bluetooth nyala dan printer\nudah disandingkan di setting HP lo bro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.initBluetooth(),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Cari Printer Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          );
        }

        // --- UX: LIST DEVICE & DYNAMIC BUTTON ---
        return RefreshIndicator(
          color: Colors.blueAccent,
          backgroundColor: Colors.white,
          onRefresh: () async {
            controller.initBluetooth();
            await Future.delayed(const Duration(seconds: 1)); 
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(), 
            itemCount: controller.devices.length,
            itemBuilder: (context, index) {
              final device = controller.devices[index];
              
              // Cek state spesifik buat device ini
              final isConnecting = controller.connectingDeviceId.value == device.address;
              final isThisDeviceConnected = controller.isConnected.value && 
                                            controller.selectedDevice.value?.address == device.address;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isThisDeviceConnected 
                      ? Border.all(color: Colors.green.shade300, width: 1.5) // Highlight border kalau konek
                      : Border.all(color: Colors.transparent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isThisDeviceConnected ? Colors.green.shade50 : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.print_rounded, 
                      color: isThisDeviceConnected ? Colors.green : Colors.blueAccent
                    ),
                  ),
                  title: Text(
                    device.name ?? 'Unknown Device',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    device.address ?? 'No MAC Address',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  
                  // --- DYNAMIC TRAILING BUTTON ---
                  trailing: Builder(
                    builder: (context) {
                      // 1. STATE: Lagi Proses Konek
                      if (isConnecting) {
                        return ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                          ),
                        );
                      }

                      // 2. STATE: Udah Terhubung
                      if (isThisDeviceConnected) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            // Kalau dipencet lagi pas udah terhubung, langsung buka menu print
                            Get.toNamed('/print_tester');
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Terhubung'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }

                      // 3. STATE: Normal (Belum Konek)
                      return ElevatedButton(
                        onPressed: () => controller.connectToDevice(device),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Connect'),
                      );
                    }
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}