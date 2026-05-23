import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'product_detail_screen.dart';

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

  // LOAD DATA FROM DB
  void loadData() async {
    final data = await DBHelper.getAll();

    if (!mounted) return;

    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Products"),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? const Center(child: Text("No Products Found"))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                return Card(
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text("Stock: ${item['stock']}"),
                    trailing: const Icon(Icons.arrow_forward_ios),

                    // 🔥 IMPORTANT FIX HERE
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: item),
                        ),
                      );

                      // 🔥 refresh after delete
                      if (result == true) {
                        loadData();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}