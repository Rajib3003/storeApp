import 'package:flutter/material.dart';
import '../sales/sales_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.sell),
            title: const Text("Sales Report"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SalesReportScreen(),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}