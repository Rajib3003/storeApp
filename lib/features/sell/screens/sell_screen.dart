import 'package:flutter/material.dart';
import '../../product/services/product_service.dart';

class SellScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const SellScreen({super.key, required this.product});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final TextEditingController qtyController =
      TextEditingController(text: "1");

  bool loading = false;

  void confirmSell() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Sell"),
          content: const Text("Are you sure to sell this product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                sellProduct();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void sellProduct() async {
    setState(() => loading = true);

    final int qty = int.tryParse(qtyController.text) ?? 0;
    int stock = widget.product['stock'];

    if (qty <= 0) {
      setState(() => loading = false);
      return;
    }

    if (qty > stock) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough stock")),
      );
      return;
    }

    int newStock = stock - qty;

    // 🔥 UPDATE STOCK IN DB
    await ProductService.updateStock(
      barcode: widget.product['barcode'],
      newStock: newStock,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sold Successfully")),
    );

    // 🔥 BACK TO HOME
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Barcode: ${product['barcode']}"),
            Text("Stock: ${product['stock']}"),
            Text("Price: ${product['selling_price']}"),

            const SizedBox(height: 20),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : confirmSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SELL"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}