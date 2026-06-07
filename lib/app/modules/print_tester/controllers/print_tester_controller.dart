import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PrintTesterController extends GetxController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  
  // Controller buat handle input text custom dari UI
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var selectedImagePath = ''.obs; // Buat nyimpen path gambar yang dipilih
  var isLoading = false.obs;


  Future<void> pickAndCompressImage() async {
    try {
      // Ini rahasianya bro: pake maxWidth dan imageQuality
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 384,     // Mentokin di 384 pixel biar pas di kertas 58mm
        imageQuality: 50,  // Kompres kualitasnya jadi 50% biar size file kecil
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        Get.snackbar("Sukses", "Gambar berhasil dimuat dan dikompres!");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal milih gambar: $e");
    }
  }

  // Fungsi buat nge-print gambar yang udah dipilih
  void printCustomImage() async {
    if (selectedImagePath.value.isEmpty) {
      Get.snackbar("Peringatan", "Pilih gambar dulu bro!");
      return;
    }

    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      // Langsung print dari path lokal hasil pick image
      bluetooth.printImage(selectedImagePath.value);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
    }
  }
  
  // 1. Fungsi Cetak Teks Custom dari Input-an User
  void printCustomText() async {
    String text = textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar("Peringatan", "Isi teksnya dulu dong bro wkwk");
      return;
    }

    // Cek koneksi dulu sebelum ngeprint
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      // printCustom(Teks, Ukuran_Font, Alignment)
      // Size: 0 (Normal), 1 (Medium), 2 (Large), 3 (Extra Large)
      // Align: 0 (Left), 1 (Center), 2 (Right)
      bluetooth.printCustom(text, 1, 0); 
      bluetooth.printNewLine();
      bluetooth.printNewLine(); // Kasih space kosong biar gampang disobek
    } else {
      Get.snackbar("Gagal", "Printer terputus, coba konekin ulang.");
    }
  }

  // 2. Fungsi Cetak Contoh Struk Kasir (Biar keliatan keren)
  void printSampleReceipt() async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      // Header
      bluetooth.printCustom("WARUNG KOPI JONO", 2, 1);
      bluetooth.printCustom("Jl. Ahmad Yani No. 12, Tegal", 0, 1);
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      // Body Struk (Kiri & Kanan)
      // printLeftRight(Teks_Kiri, Teks_Kanan, Ukuran_Font)
      bluetooth.printLeftRight("Kopi Susu Gula Aren", "15.000", 1);
      bluetooth.printLeftRight("Roti Bakar Cokelat", "12.000", 1);
      bluetooth.printLeftRight("Es Teh Manis", "5.000", 1);
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      // Total
      bluetooth.printLeftRight("TOTAL", "32.000", 1);
      bluetooth.printNewLine();
      
      // Footer
      bluetooth.printCustom("Terima Kasih Banyak Bro!", 0, 1);
      bluetooth.printCustom("Ditunggu Datang Lagi wkwk", 0, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
    } else {
      Get.snackbar("Gagal", "Printer terputus.");
    }
  }

  // 3. Fungsi Cetak Gambar/Logo dari Asset
  // Catatan: Printer thermal butuh path file lokal, gak bisa langsung baca path asset Flutter.
  // Jadi logic-nya: Asset di-copy dulu ke temporary directory HP, baru di-print.
  void printImageFromAsset() async {
    bool? isConnected = await bluetooth.isConnected;
    if (!isConnected!) {
      Get.snackbar("Gagal", "Printer kagak konek bro!");
      return;
    }

    try {
      isLoading.value = true;
      
      // Setup nama file gambar di asset lo (misal: assets/images/logo.png)
      // Pastiin udah lo daftarin di pubspec.yaml ya!
      String assetPath = 'assets/images/logo.png'; 
      
      // Copy asset ke local file
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      String tempPath = (await getTemporaryDirectory()).path;
      File file = File('$tempPath/temp_logo.png');
      await file.writeAsBytes(bytes);

      // Eksekusi print gambarnya
      // printImage(path_file_lokal)
      bluetooth.printImage(file.path); 
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      
      Get.snackbar("Sukses", "Gambar berhasil dikirim ke printer");
    } catch (e) {
      Get.snackbar("Error Gambar", "Pastiin file asset logo.png udah bener. Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}