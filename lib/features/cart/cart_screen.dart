import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'cart_item_model.dart';
import '../product/product_service.dart';
import '../sales/sales_service.dart';
import '../sales/sale_model.dart';
import '../product/store_list_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void refresh() => setState(() {});

  void increase(CartItem item) {
    item.qty++;
    refresh();
  }

  void decrease(CartItem item) {
    item.qty--;
    if (item.qty <= 0) {
      CartService.removeItem(item.barcode);
    }
    refresh();
  }

  void remove(String barcode) {
    CartService.removeItem(barcode);
    refresh();
  }

  // 💰 CHECKOUT BUTTON
  Future<void> checkout() async {
    final discountController = TextEditingController();

    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Checkout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Total: ৳${CartService.total.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Discount Amount",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    double discount =
        double.tryParse(discountController.text) ?? 0;

    double totalAmount = CartService.total;
    if (discount > totalAmount) discount = totalAmount;

    double payable = totalAmount - discount;

    final productsByBarcode = <String, Map<String, dynamic>>{};

    // 🔥 1. STOCK VALIDATION
    for (var item in CartService.items) {
      final product = await ProductService.getByBarcode(item.barcode);

      if (product == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item.name} not found")),
        );
        return;
      }

      productsByBarcode[item.barcode] = product;

      if (item.qty > product['stock']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not enough stock for ${item.name}"),
          ),
        );
        return;
      }
    }

    // 🔥 2. PROCESS ORDER
    for (var item in CartService.items) {
      final product = productsByBarcode[item.barcode];
      if (product == null) continue;

      int newStock = product['stock'] - item.qty;

      await ProductService.updateStock(
        barcode: item.barcode,
        newStock: newStock,
      );

      SalesService.addSale(
        SaleModel(
          barcode: item.barcode,
          name: item.name,
          qty: item.qty,
          purchasePrice:
              double.parse(product['purchase_price'].toString()),
          sellingPrice: item.price,
          total: item.total,
          date: DateTime.now(),
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    // 🔥 3. CLEAR CART
    // CartService.clear();

    // refresh();

    // if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       "Checkout Done | Paid: ৳${payable.toStringAsFixed(2)}",
    //     ),
    //   ),
    //  );

    // 🔥 3. CLEAR CART
    CartService.clear();

    refresh();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Checkout Done | Paid: ৳${payable.toStringAsFixed(2)}",
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const StoreListScreen(),
      ),
    );
   
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: items.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            "৳${item.price} x ${item.qty}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => decrease(item),
                              ),
                              Text("${item.qty}"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => increase(item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    remove(item.barcode),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ৳${CartService.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: checkout,
                        child: const Text("CHECKOUT"),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}