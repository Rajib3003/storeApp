import 'package:flutter/material.dart';

import 'features/sell/screens/scan_screen.dart';
import 'features/product/screens/generate_barcode_screen.dart';
import 'features/product/screens/store_list_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/cart/cart_service.dart';
import 'features/sales/sales_report_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  const HomeMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Dashboard"),
        centerTitle: true,

        // 🛒 CART ICON WITH LIVE BADGE
        actions: [
          ValueListenableBuilder(
            valueListenable: CartService.cartCount,
            builder: (context, value, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                  ),

                  // 🔴 BADGE
                  if (value > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,

          children: [

            const HomeMenuButton(
              icon: Icons.qr_code_scanner,
              label: "Scan & Sell",
              color: Colors.green,
              page: ScanScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.add_box,
              label: "Add Product",
              color: Colors.blue,
              page: GenerateBarcodeScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.list,
              label: "Products",
              color: Colors.orange,
              page: StoreListScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.shopping_cart,
              label: "Cart",
              color: Colors.purple,
              page: CartScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.bar_chart,
              label: "Sales Report",
              color: Colors.red,
              page: SalesReportScreen(),
            ),
          ],
        ),
      ),
    );
  }

}