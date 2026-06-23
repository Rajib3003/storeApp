import 'package:flutter/material.dart';
import 'package:myapp/services/sync_service.dart';
import 'package:myapp/features/network/network_service.dart';

import '../sell/scan_screen.dart';
import '../product/generate_barcode_screen.dart';
import '../product/store_list_screen.dart';
import '../cart/cart_screen.dart';
import '../reports/report_screen.dart';
import '../backup/drive_service.dart';
import '../backup/backup_service.dart';
import '../backup/backup_list_screen.dart';
import '../backup/google_auth_service.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';
import '../master/master_screen.dart';
import '../cart/widgets/cart_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {

    final ok = await DriveService.tryAutoInit();

    if (!ok) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // 🌐 Internet check after login success
    final hasNet = await NetworkService.hasInternet();

    if (hasNet) {
      try {
        await SyncService.syncSales();
        await SyncService.syncProducts();
        await SyncService.syncCustomers();
        await SyncService.syncExpenses();
      } catch (e) {
        debugPrint("Sync error: $e");
      }
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          const CartIcon(),
          PopupMenuButton<HomeMenuAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) async {
              switch (action) {
                case HomeMenuAction.settings:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  break;
                case HomeMenuAction.backupList:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupListScreen(),
                    ),
                  );
                  break;
                case HomeMenuAction.backupNow:
                  try {
                    await BackupService.backupToDrive();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup completed')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')),
                    );
                  }
                  break;
                case HomeMenuAction.manageTables:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MasterScreen(),
                    ),
                  );
                  break;
                case HomeMenuAction.userInfo:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  break;
                case HomeMenuAction.logout:
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Do you want to sign out now?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  await GoogleAuthService.signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: HomeMenuAction.settings,
                child: Text('Settings'),
              ),
              PopupMenuItem(
                value: HomeMenuAction.backupList,
                child: Text('Backup List'),
              ),
              PopupMenuItem(
                value: HomeMenuAction.backupNow,
                child: Text('Backup Now'),
              ),
              PopupMenuItem(
                value: HomeMenuAction.manageTables,
                child: Text('Manage Database'),
              ),
              PopupMenuItem(
                value: HomeMenuAction.userInfo,
                child: Text('User Information'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: HomeMenuAction.logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            const HomeMenuButton(
              icon: Icons.qr_code_scanner,
              label: "Scan",
              color: Colors.green,
              page: ScanScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.add_box,
              label: "Add",
              color: Colors.blue,
              page: GenerateBarcodeScreen(),
            ),
            const HomeMenuButton(
              icon: Icons.list,
              label: "List",
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

enum HomeMenuAction {
  settings,
  backupList,
  backupNow,
  manageTables,
  userInfo,
  logout,
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
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ))
          ],
        ),
      ),
    );
  }
}