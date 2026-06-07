import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScannerController extends GetxController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  var devices = <BluetoothDevice>[].obs;
  var selectedDevice = Rxn<BluetoothDevice>();
  var isConnected = false.obs;

  // State baru buat nampilin loading pas lagi proses koneksi
  var connectingDeviceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _requestPermissionAndInit();
  }

  Future<void> _requestPermissionAndInit() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect] == PermissionStatus.granted || 
        statuses[Permission.bluetooth] == PermissionStatus.granted) {
      initBluetooth();
    } else {
      Get.snackbar(
        "Akses Ditolak", 
        "Bro, izin Bluetooth wajib diaktifin buat nge-print.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void initBluetooth() async {
    try {
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      devices.value = bondedDevices;

      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            isConnected.value = true;
            break;
          case BlueThermalPrinter.DISCONNECTED:
            isConnected.value = false;
            selectedDevice.value = null;
            break;
          default:
            break;
        }
      });
    } on PlatformException catch (e) {
      print("Error inisialisasi bluetooth: ${e.message}");
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    if (device.address == null) return;

    // Cegah user nge-spam pencet tombol
    if (connectingDeviceId.value == device.address) return;

    try {
      connectingDeviceId.value = device.address!; // Nyalain loading
      
      bool? connected = await bluetooth.connect(device);
      
      if (connected == true) {
        selectedDevice.value = device;
        isConnected.value = true;
        
        Get.snackbar(
          "Berhasil!", 
          "Printer ${device.name} udah terhubung bro.",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        
        // Kasih jeda dikit biar user sempet liat tombol jadi ijo
        await Future.delayed(const Duration(milliseconds: 500));
        Get.toNamed('/print_tester'); 
      }
    } catch (e) {
      // Error handling kalau printer mati atau nolak koneksi
      Get.snackbar(
        "Koneksi Gagal", 
        "Cek printernya nyala nggak, atau jangan-jangan masih konek ke HP lain bro.\nDetails: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
    } finally {
      connectingDeviceId.value = ''; // Matiin loading apapun yang terjadi
    }
  }

  void disconnectDevice() async {
    try {
      await bluetooth.disconnect();
      selectedDevice.value = null;
      isConnected.value = false;
    } catch (e) {
      print("Gagal disconnect: $e");
    }
  }
}