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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 SCAN (SELL)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanScreen(),
                    ),
                  );
                },
                child: const Text("SCAN & SELL"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 GENERATE PRODUCT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenerateBarcodeScreen(),
                    ),
                  );
                },
                child: const Text("ADD PRODUCT"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 STORE LIST
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreListScreen(),
                    ),
                  );
                },
                child: const Text("VIEW PRODUCTS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}