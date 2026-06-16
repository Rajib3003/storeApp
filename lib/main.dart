import 'package:flutter/material.dart';

import 'features/sell/scan_screen.dart';
import 'features/product/generate_barcode_screen.dart';
import 'features/product/store_list_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/sales/sales_report_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/cart/widgets/cart_icon.dart';
import 'features/reports/report_screen.dart';
import 'features/backup/backup_checker.dart';
import 'features/auth/login_screen.dart';
import 'features/backup/backup_popup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// ================= APP ROOT =================
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
      // home: const SplashScreen(),
      home: const LoginScreen(),
    );
  }
}

/// ================= HOME PAGE =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackupChecker.check(context);
      BackupPopupService.checkAndShow(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Dashboard"),
        centerTitle: true,
        actions: const [
          CartIcon(),
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
            HomeMenuButton(
              icon: Icons.bar_chart,
              label: "Reports",
              color: Colors.red,
              page: ReportsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= MENU BUTTON =================
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
          boxShadow: const [
            BoxShadow(
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