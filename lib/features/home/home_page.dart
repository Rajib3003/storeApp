import 'package:flutter/material.dart';

import '../sell/scan_screen.dart';
import '../product/generate_barcode_screen.dart';
import '../product/store_list_screen.dart';
import '../cart/cart_screen.dart';
import '../reports/report_screen.dart';
import '../backup/drive_service.dart';

import '../cart/widgets/cart_icon.dart';
import '../backup/backup_service.dart';
import '../backup/backup_checker.dart';
import '../backup/backup_popup_service.dart';
import '../backup/backup_list_screen.dart';

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
    //   BackupChecker.check(context);
    //   BackupPopupService.checkAndShow(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              await BackupService.backupToDrive();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Backup Completed")),
              );
            },
          ),
          const CartIcon(),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BackupListScreen(),
                ),
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
            Text(label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ))
          ],
        ),
      ),
    );
  }
}