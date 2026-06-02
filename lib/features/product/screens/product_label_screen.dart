import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../services/pdf_service.dart';
import 'generate_barcode_screen.dart';
import 'store_list_screen.dart';
import '../../../main.dart'; // 👈 HomePage এখান থেকে আসবে

class ProductLabelScreen extends StatelessWidget {
  final String productName;
  final String barcode;
  final String purchasePrice;
  final String sellingPrice;
  final int stock;

  const ProductLabelScreen({
    super.key,
    required this.productName,
    required this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
  });

  void printLabels(BuildContext context) {
    PdfService.generatePdf(
      productName: productName,
      barcode: barcode,
      quantity: stock,
    );
  }

  void goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void goAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GenerateBarcodeScreen(),
      ),
    );
  }

  void goProductList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StoreListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Label"),

        // LEFT SIDE BUTTONS
        leadingWidth: 120,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => goHome(context),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => goAddProduct(context),
            ),
          ],
        ),

        // RIGHT SIDE BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => goProductList(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              productName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text("Barcode: $barcode"),

            const SizedBox(height: 15),

            BarcodeWidget(
              barcode: Barcode.code128(),
              data: barcode,
              width: 300,
              height: 80,
            ),

            const SizedBox(height: 25),

            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: barcode,
              width: 200,
              height: 200,
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Purchase Price: $purchasePrice"),
                    Text("Selling Price: $sellingPrice"),
                    Text("Stock: $stock"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => printLabels(context),
                icon: const Icon(Icons.print),
                label: Text("PRINT $stock LABELS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}