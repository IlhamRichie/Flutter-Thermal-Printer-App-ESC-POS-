import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:image_picker/image_picker.dart';

class PrintTesterController extends GetxController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  var isLoading = false.obs;
  var selectedImagePath = ''.obs;

  // ==========================================
  // HELPER: Format Tanggal (Misal: 17 Apr 26 14:45)
  // ==========================================
  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final monthStr = months[now.month - 1];
    final yearStr = now.year.toString().substring(2); // Ambil 2 digit tahun
    final hourStr = now.hour.toString().padLeft(2, '0');
    final minuteStr = now.minute.toString().padLeft(2, '0');
    
    return "${now.day} $monthStr $yearStr $hourStr:$minuteStr";
  }

  // ==========================================
  // HELPER: Cetak Header Struk
  // ==========================================
  void _printHeader() {
    // Nama Toko (Size 2 = Large, 1 = Center)
    bluetooth.printCustom("MINA Headquarter", 2, 1); 
    
    // Alamat (Size 0 = Normal, 1 = Center)
    bluetooth.printCustom("Gg. Ampel, Jetis, Pepedan,", 0, 1);
    bluetooth.printCustom("Kec. Dukuhturi, Kabupaten Tegal,", 0, 1);
    bluetooth.printCustom("Jawa Tengah 52192", 0, 1);
    
    // Garis Pemisah Double
    bluetooth.printCustom("================================", 0, 1);
    
    // Waktu Transaksi (Rata Kiri Kanan)
    String currentTime = _getFormattedDate();
    bluetooth.printLeftRight("Waktu", ": $currentTime", 0);
    
    // Garis Pemisah Single
    bluetooth.printCustom("--------------------------------", 0, 1);
  }

  // ==========================================
  // HELPER: Cetak Footer Struk
  // ==========================================
  void _printFooter() {
    // Garis Pemisah Single
    bluetooth.printCustom("--------------------------------", 0, 1);
    
    // Info WiFi
    bluetooth.printCustom("Wifi : rumahsangrai", 0, 1);
    bluetooth.printNewLine();
    
    // Info Pembayaran & Kasir
    String currentTime = _getFormattedDate();
    bluetooth.printCustom("Terbayar  $currentTime", 0, 1);
    bluetooth.printCustom("dicetak: rigan", 0, 1);
    
    // Spasi buat disobek
    bluetooth.printNewLine();
    bluetooth.printNewLine();
  }

  // ==========================================
  // FITUR 1: Cetak Teks Custom ke dalam Template
  // ==========================================
  void printCustomText() async {
    String text = textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar("Peringatan", "Isi teksnya dulu dong bro wkwk");
      return;
    }

    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      _printHeader();               // 1. Cetak Header
      bluetooth.printCustom(text, 1, 0); // 2. Cetak Konten (Teks Custom)
      _printFooter();               // 3. Cetak Footer
    } else {
      Get.snackbar("Gagal", "Printer terputus, coba konekin ulang.");
    }
  }

  // ==========================================
  // FITUR 2: Pilih & Compress Gambar Custom
  // ==========================================
  Future<void> pickAndCompressImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 384, 
        imageQuality: 50,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        Get.snackbar("Sukses", "Gambar berhasil dimuat!");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal milih gambar: $e");
    }
  }

  // ==========================================
  // FITUR 3: Cetak Gambar Custom ke dalam Template
  // ==========================================
  void printCustomImage() async {
    if (selectedImagePath.value.isEmpty) {
      Get.snackbar("Peringatan", "Pilih gambar dulu bro!");
      return;
    }

    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      _printHeader();                          // 1. Cetak Header
      bluetooth.printImage(selectedImagePath.value); // 2. Cetak Konten (Gambar)
      _printFooter();                          // 3. Cetak Footer
    } else {
      Get.snackbar("Gagal", "Printer terputus.");
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}