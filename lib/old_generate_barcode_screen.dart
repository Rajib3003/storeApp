import 'package:flutter/material.dart';
import 'dart:math';
import 'database/db_helper.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'pdf_service.dart';

class GenerateBarcodeScreen extends StatefulWidget {
  const GenerateBarcodeScreen({super.key});

  @override
  State<GenerateBarcodeScreen> createState() =>
      _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState
    extends State<GenerateBarcodeScreen> {
  final nameController = TextEditingController();
  final purchaseController = TextEditingController();
  final sellingController = TextEditingController();
  final stockController = TextEditingController();

  String barcode = "";
  bool isPrinted = false;

  // 🔥 Generate Barcode
  void generateBarcode() {
    final random = Random();

    setState(() {
      barcode = "89${100000000 + random.nextInt(999999999)}";
      isPrinted = false;
    });
  }

  // 🔥 QR DATA (IMPORTANT FIX)
  String get qrData => '''
{
  "name": "${nameController.text}",
  "barcode": "$barcode",
  "purchase": "${purchaseController.text}",
  "selling": "${sellingController.text}",
  "stock": "${stockController.text}"
}
''';

  // 🔥 Save Product
  void saveProduct() async {
    if (barcode.isEmpty ||
        nameController.text.isEmpty ||
        purchaseController.text.isEmpty ||
        sellingController.text.isEmpty ||
        stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields first")),
      );
      return;
    }

    await DBHelper.insertProduct({
      "name": nameController.text.trim(),
      "barcode": barcode,
      "purchase_price": double.parse(purchaseController.text),
      "selling_price": double.parse(sellingController.text),
      "stock": int.parse(stockController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product Saved Successfully")),
    );
  }

  // 🔥 Print PDF
  void printPdf() async {
    if (barcode.isEmpty) return;

    await PdfService.generatePdf(
      productName: nameController.text,
      barcode: barcode,
      quantity: int.parse(stockController.text),
    );

    setState(() {
      isPrinted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF Generated")),
    );
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

              const SizedBox(height: 15),

              TextField(
                controller: purchaseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Purchase Price",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: sellingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Selling Price",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

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

                const SizedBox(height: 20),

                // STATUS
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPrinted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPrinted ? "PRINTED" : "NOT PRINTED",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("BARCODE",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: barcode,
                  width: 300,
                  height: 80,
                ),

                const SizedBox(height: 30),

                const Text("QR CODE",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                // 🔥 QR FIXED HERE
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: qrData,
                  width: 200,
                  height: 200,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveProduct,
                    child: const Text("SAVE PRODUCT"),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: printPdf,
                    child: const Text("PRINT PDF"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}