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

  // --- LOGIC KONEKSI YANG UDAH DI-PERBAIKI ---
  void connectToDevice(BluetoothDevice device) async {
    if (device.address == null) return;
    if (connectingDeviceId.value == device.address) return;

    connectingDeviceId.value = device.address!; // Nyalain loading

    try {
      // Kita coba konek dengan timeout biar ga stuck loading forever
      await bluetooth.connect(device).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Abaikan error di sini sementara, karena package ini sering ngasih error palsu.
      print("Package throw error: $e, checking manual status...");
    }

    // Kasih napas 1.5 detik buat hardware nyelesaiin pairing di background
    await Future.delayed(const Duration(milliseconds: 1500));

    // Double check: Apakah beneran gagal, atau aslinya udah konek?
    bool? actuallyConnected = await bluetooth.isConnected;

    if (actuallyConnected == true) {
      selectedDevice.value = device;
      isConnected.value = true;
      
      Get.snackbar(
        "Berhasil!", 
        "Printer ${device.name} udah terhubung bro.",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP, // Pindah ke atas biar ga ketutup tombol
      );
      
      // Kasih jeda 0.5 detik biar user baca snackbar, baru otomatis pindah
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed('/print-tester'); 
    } else {
      // Kalau beneran gagal (printer mati / nyambung HP lain)
      Get.snackbar(
        "Koneksi Gagal", 
        "Cek printernya nyala nggak, atau mungkin lagi nyantol di HP lain bro.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    connectingDeviceId.value = ''; // Matiin loading
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