import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/print_tester_controller.dart';

class PrintTesterView extends GetView<PrintTesterController> {
  const PrintTesterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background clean ala modern app
      appBar: AppBar(
        title: const Text(
          'MINA Print System', // Gue ganti judulnya biar sekalian custom
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // Flat design
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            tooltip: 'Disconnect',
            onPressed: () {
              controller.bluetooth.disconnect();
              Get.back();
              Get.snackbar(
                "Disconnected", 
                "Koneksi printer diputus.",
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- STATUS BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    "Printer Connected & Ready!",
                    style: TextStyle(
                      color: Colors.green, 
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 1: CUSTOM TEXT ---
            _buildSectionCard(
              title: "Cetak Teks ke Struk",
              icon: Icons.text_snippet_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.textController,
                    maxLength: 100, // Fitur limit 100 karakter
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan custom buat pelanggan...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: controller.printCustomText,
                    icon: const Icon(Icons.print_rounded),
                    label: const Text("Cetak Teks dengan Template"),
                    style: _primaryButtonStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- SECTION 2: GAMBAR CUSTOM ---
            _buildSectionCard(
              title: "Cetak Gambar ke Struk",
              icon: Icons.image_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickAndCompressImage,
                          icon: const Icon(Icons.add_photo_alternate_rounded),
                          label: const Text("Pilih Gambar"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => ElevatedButton.icon(
                          onPressed: controller.selectedImagePath.value.isEmpty 
                              ? null 
                              : controller.printCustomImage,
                          icon: const Icon(Icons.print_rounded),
                          label: const Text("Print Gambar"),
                          style: _actionButtonStyle(Colors.blueAccent),
                        )),
                      ),
                    ],
                  ),
                  // Preview text kalau gambar udah dipilih
                  Obx(() {
                    if (controller.selectedImagePath.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Siap cetak: ${controller.selectedImagePath.value.split('/').last}",
                                style: const TextStyle(color: Colors.green, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BIKIN UI KONSISTEN ---

  // Bikin Container / Card putih modern untuk tiap section
  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Style button utama
  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black87, // Warna gelap ala modern minimalis
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Style button warna-warni
  ButtonStyle _actionButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}