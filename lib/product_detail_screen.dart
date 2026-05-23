import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'pdf_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  late Map<String, dynamic> product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  // DELETE PRODUCT
  void deleteProduct() async {
    final db = await DBHelper.db;

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [product['id']],
    );

    Navigator.pop(context, true); // ✅ IMPORTANT FIX

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product Deleted")),
    );
  }

  // PRINT PRODUCT
  void printProduct() async {
    await PdfService.generatePdf(
      productName: product['name'],
      barcode: product['barcode'],
      quantity: product['stock'],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Printing...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Stock: ${product['stock']}"),
            Text("Purchase: ${product['purchase_price']}"),
            Text("Selling: ${product['selling_price']}"),

            const SizedBox(height: 20),

            Center(
              child: BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: product['barcode'],
                width: 200,
                height: 200,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: printProduct,
                child: const Text("PRINT"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: deleteProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("DELETE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}