import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class BluetoothScannerController extends GetxController {
  // Inisialisasi instance dari package
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // State GetX pake .obs biar reactive
  var devices = <BluetoothDevice>[].obs;
  var selectedDevice = Rxn<BluetoothDevice>(); // Rxn artinya bisa null
  var isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBluetooth();
  }

  void initBluetooth() async {
    try {
      // Ngambil list device bluetooth yang udah pernah di-pair di setting HP
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      devices.value = bondedDevices;

      // Listener otomatis buat mantau status koneksi bluetooth
      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            isConnected.value = true;
            print("Bluetooth Connected");
            break;
          case BlueThermalPrinter.DISCONNECTED:
            isConnected.value = false;
            selectedDevice.value = null; // Reset selected device kalau putus
            print("Bluetooth Disconnected");
            break;
          default:
            break;
        }
      });
    } on PlatformException catch (e) {
      print("Error inisialisasi bluetooth: ${e.message}");
    }
  }

  // Fungsi buat trigger connect pas tombol di-klik
  void connectToDevice(BluetoothDevice device) async {
    if (device.address == null) return;

    try {
      bool? connected = await bluetooth.connect(device);
      if (connected == true) {
        selectedDevice.value = device;
        Get.snackbar("Mantap", "Berhasil konek ke ${device.name}");
        
        // Pindah ke page print tester kalau udah sukses connect
        // Pastiin route-nya sesuai sama nama route di app lo
        Get.toNamed('/print_tester'); 
      }
    } catch (e) {
      Get.snackbar("Gagal Konek", "Coba restart printer atau cek bluetooth HP. Error: $e");
    }
  }

  // Jangan lupa fungsi disconnect biar gak gantung
  void disconnectDevice() async {
    try {
      await bluetooth.disconnect();
    } catch (e) {
      print("Gagal disconnect: $e");
    }
  }
}