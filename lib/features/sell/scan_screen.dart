import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../product/product_service.dart';
import 'sell_screen.dart';
import 'package:myapp/widgets/home_leading_button.dart';

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
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Scan Product"),
        leading: const HomeLeadingButton(),
      ),
      body: MobileScanner(
        onDetect: (capture) async {
          if (scanned) return;

          final barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;

            if (code != null) {
              scanned = true;

              final product =
                  await ProductService.getByBarcode(code);

              if (product != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellScreen(product: product),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product not found")),
                );

                scanned = false;
              }
            }
          }
        },
      ),
    );
  }
}