import 'package:flutter/material.dart';

import '../services/product_service.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await ProductService.getAllProducts();

    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store Products")),
      body: products.isEmpty
          ? const Center(child: Text("No Products Found"))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                return Card(
                  child: ListTile(
                    title: Text(item['name'].toString()),
                    subtitle: Text("Stock: ${item['stock']}"),
                    trailing: Text("৳${item['selling_price']}"),
                  ),
                );
              },
            ),
    );
  }
}