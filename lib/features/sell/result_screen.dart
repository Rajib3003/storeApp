import 'package:flutter/material.dart';
import 'sell_service.dart';

class ResultScreen extends StatefulWidget {
  final String barcode;

  const ResultScreen({super.key, required this.barcode});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<String, dynamic>? product;

  final qtyController = TextEditingController(text: "1");
  final sellPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  void loadProduct() async {
    final data = await SellService.getProductByBarcode(widget.barcode);

    if (data != null) {
      setState(() {
        product = data;
        sellPriceController.text =
            data['selling_price'].toString();
      });
    }
  }

  void confirmSell() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Sell"),
        content: const Text("Are you sure?"),
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
      ),
    );
  }

  void sellProduct() async {
    if (product == null) return;

    int qty = int.parse(qtyController.text);
    int stock = product!['stock'];
    double price = double.parse(sellPriceController.text);

    if (qty <= 0 || stock < qty) return;

    int newStock = stock - qty;

    await SellService.updateStock(product!['barcode'], newStock);

    await SellService.insertSale(
      barcode: product!['barcode'],
      qty: qty,
      sellPrice: price,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sold Successfully")),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Product Sell")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            Text("Name: ${product!['name']}"),
            Text("Stock: ${product!['stock']}"),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Qty"),
            ),

            TextField(
              controller: sellPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Sell Price"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: confirmSell,
              child: const Text("SELL"),
            ),
          ],
        ),
      ),
    );
  }
}