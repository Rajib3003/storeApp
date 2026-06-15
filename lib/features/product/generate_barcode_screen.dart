import 'dart:math';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

import 'product_service.dart';
import '../../services/pdf_service.dart';
import 'product_label_screen.dart';


class GenerateBarcodeScreen extends StatefulWidget {
  const GenerateBarcodeScreen({super.key});

  @override
  State<GenerateBarcodeScreen> createState() =>
      _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState extends State<GenerateBarcodeScreen> {
  final nameController = TextEditingController();
  final purchaseController = TextEditingController();
  final sellingController = TextEditingController();
  final stockController = TextEditingController();

  String barcode = "";
  bool isPrinted = false;

  // 🔥 Generate barcode
  void generateBarcode() {
    final random = Random();

    setState(() {
      barcode = "89${100000000 + random.nextInt(999999999)}";
      isPrinted = false;
    });
  }

  // 🔥 QR DATA
  String get qrData => '''
{
  "name": "${nameController.text}",
  "barcode": "$barcode",
  "purchase": "${purchaseController.text}",
  "selling": "${sellingController.text}",
  "stock": "${stockController.text}"
}
''';

  // 🔥 SAVE PRODUCT
 Future<void> saveProduct() async {
  if (barcode.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please generate barcode first")),
    );
    return;
  }

  if (nameController.text.isEmpty ||
      purchaseController.text.isEmpty ||
      sellingController.text.isEmpty ||
      stockController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all fields first")),
    );
    return;
  }

  try {
    await ProductService.insertProduct({
      "name": nameController.text.trim(),
      "barcode": barcode,
      "purchase_price":
          double.tryParse(purchaseController.text) ?? 0,
      "selling_price":
          double.tryParse(sellingController.text) ?? 0,
      "stock":
          int.tryParse(stockController.text) ?? 0,
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product Saved Successfully")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductLabelScreen(
          productName: nameController.text,
          barcode: barcode,
          purchasePrice: purchaseController.text,
          sellingPrice: sellingController.text,
            stock: int.tryParse(stockController.text) ?? 0,
        ),
      ),
    );

  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Save Failed: $e")),
    );
  }
}

  // 🔥 CLEAR ONLY FORM (barcode KEEP)
  void clearFormKeepBarcode() {
    nameController.clear();
    purchaseController.clear();
    sellingController.clear();
    stockController.clear();

    setState(() {
      isPrinted = false;
    });
  }

  // 🔥 PRINT LABEL
  void printLabel() {
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please generate barcode first")),
      );
      return;
    }

    final qtyText = stockController.text.trim();
    final qty = int.tryParse(qtyText);

    if (qty == null || qty <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Valid stock quantity required")),
    );
    return;
    }

    PdfService.generatePdf(
    productName: nameController.text,
    barcode: barcode,
    quantity: qty,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    purchaseController.dispose();
    sellingController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Barcode"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: purchaseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Purchase Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: sellingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Selling Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stock Quantity",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generateBarcode,
                  child: const Text("GENERATE BARCODE"),
                ),
              ),

              const SizedBox(height: 20),

              if (barcode.isNotEmpty) ...[
                Text(
                  "Code: $barcode",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

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
                  data: qrData,
                  width: 200,
                  height: 200,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveProduct,
                    child: const Text("SAVE PRODUCT"),
                  ),
                ),

                // const SizedBox(height: 15),

                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: printLabel,
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //     ),
                //     child: const Text("PRINT BARCODE / QR"),
                //   ),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}