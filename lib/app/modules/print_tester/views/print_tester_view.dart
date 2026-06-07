import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/print_tester_controller.dart';

class PrintTesterView extends GetView<PrintTesterController> {
  const PrintTesterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer Tester'),
        centerTitle: true,
        actions: [
          // Tombol disconnect di pojok kanan atas
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: () {
              controller.bluetooth.disconnect();
              Get.back(); // Balik ke halaman scanner
              Get.snackbar("Disconnected", "Koneksi printer diputus.");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text(
                      "Printer Connected & Ready!",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Custom Text Input
            const Text(
              "Cetak Teks Custom",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ketik apa aja di sini bro...',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: controller.printCustomText,
              icon: const Icon(Icons.print),
              label: const Text("Cetak Teks"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            // Section 2: Template Struk
            const Text(
              "Template Cetak Struk Kasir",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: controller.printSampleReceipt,
              icon: const Icon(Icons.receipt_long),
              label: const Text("Cetak Contoh Struk Belanja"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            // Section 3: Cetak Gambar
            const Text(
              "Cetak Logo / Gambar (Monokrom)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value 
                  ? null 
                  : controller.printImageFromAsset,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.image),
              label: Text(controller.isLoading.value ? "Processing..." : "Cetak Logo dari Asset"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            )),
          ],
        ),
      ),
    );
  }
}