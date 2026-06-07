import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/print_tester_controller.dart';

class PrintTesterView extends GetView<PrintTesterController> {
  const PrintTesterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrintTesterView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PrintTesterView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
