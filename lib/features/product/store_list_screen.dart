import 'dart:async';

import 'package:flutter/material.dart';
import 'product_service.dart';
import 'product_label_screen.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<Map<String, dynamic>> products = [];

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  final int limit = 10;
  int offset = 0;

  bool isLoading = false;
  bool hasMore = true;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    loadProducts();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  // 🔥 FIRST LOAD / REFRESH
  void loadProducts({bool refresh = false}) async {

    if (refresh) {
      offset = 0;
      products.clear();
      hasMore = true;
    }

    setState(() => isLoading = true);

    final data = await ProductService.getProducts(
      limit: limit,
      offset: offset,
      search: searchText,
    );

    setState(() {
      products.addAll(data);
      offset += limit;
      isLoading = false;

      if (data.length < limit) {
        hasMore = false;
      }
    });
  }

  // 🔥 LOAD MORE
  void loadMore() {
    if (isLoading || !hasMore) return;
    loadProducts();
  }

  // 🔥 SEARCH
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchText = value;
      loadProducts(refresh: true);
    });
  }

  void search(String value) {
    searchText = value;
    loadProducts(refresh: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store Products")),

      body: Column(
        children: [

          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search product...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 📦 LIST
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: products.length + 1,
              itemBuilder: (context, index) {

                // 🔄 loader widget
                if (index == products.length) {
                  return hasMore
                      ? const Padding(
                          padding: EdgeInsets.all(15),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox();
                }

                final item = products[index];

                return Card(
                  child: ListTile(
                     title: Text(item['name']),
  
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Barcode: ${item['barcode']}"),
                          Text("Stock: ${item['stock']}"),
                        ],
                      ),

                      trailing: Text("৳${item['selling_price']}"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductLabelScreen(
                            productName: item['name'],
                            barcode: item['barcode'],
                            purchasePrice: item['purchase_price'].toString(),
                            sellingPrice: item['selling_price'].toString(),
                            stock: item['stock'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}