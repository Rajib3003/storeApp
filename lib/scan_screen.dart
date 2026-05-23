import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;

            if (code != null) {
              scanned = true;

              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => ResultScreen(data: code), 
              //   ),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(data: code),
                ),
              );
            }
          }
        },
      ),
    );
  }
}