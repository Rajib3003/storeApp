import 'package:flutter/material.dart';
import '../../product/services/product_service.dart';
import '../../cart/cart_service.dart';
import '../../cart/cart_item_model.dart';

class SellScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const SellScreen({super.key, required this.product});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final TextEditingController qtyController =
      TextEditingController(text: "1");

  final TextEditingController priceController =
      TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // 💰 default selling price load
    priceController.text =
        widget.product['selling_price'].toString();
  }

  void addToCart() async {
    setState(() => loading = true);

    final int qty = int.tryParse(qtyController.text) ?? 0;
    final double price =
        double.tryParse(priceController.text) ?? 0;

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

    // 🛒 ADD TO CART (IMPORTANT)
    CartService.addItem(
      CartItem(
        barcode: widget.product['barcode'],
        name: widget.product['name'],
        price: price, // 👈 CUSTOM PRICE ENABLED
        qty: qty,
      ),
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Cart")),
    );

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

            const SizedBox(height: 20),

            // 📦 QUANTITY
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 💰 PRICE (CUSTOM EDITABLE)
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sell Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("ADD TO CART"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}