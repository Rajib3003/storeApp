import 'package:flutter/material.dart';

import 'features/sell/screens/scan_screen.dart';
import 'features/product/screens/generate_barcode_screen.dart';
import 'features/product/screens/store_list_screen.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Dashboard"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),

        child: Column(
          children: [

            const SizedBox(height: 20),

            // 🔥 SINGLE ROW MENU (5 ITEMS)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  _menuButton(
                    context,
                    icon: Icons.qr_code_scanner,
                    label: "Scan",
                    color: Colors.green,
                    page: const ScanScreen(),
                  ),

                  _menuButton(
                    context,
                    icon: Icons.add_box,
                    label: "Add",
                    color: Colors.blue,
                    page: const GenerateBarcodeScreen(),
                  ),

                  _menuButton(
                    context,
                    icon: Icons.list,
                    label: "Products",
                    color: Colors.orange,
                    page: const StoreListScreen(),
                  ),

                  _menuButton(
                    context,
                    icon: Icons.print,
                    label: "Print",
                    color: Colors.purple,
                    page: const StoreListScreen(),
                  ),

                  _menuButton(
                    context,
                    icon: Icons.bar_chart,
                    label: "Report",
                    color: Colors.red,
                    page: const StoreListScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11),
              )
            ],
          ),
        ),
      ),
    );
  }
}