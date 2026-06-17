import 'package:flutter/material.dart';

class TableDataScreen extends StatelessWidget {
  final String tableName;

  const TableDataScreen({super.key, required this.tableName});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA (replace with real SQLite later)
    final List<Map<String, dynamic>> data = List.generate(
      10,
      (i) => {
        "id": i + 1,
        "name": "$tableName item $i",
        "price": 100 + i,
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(tableName)),

      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return ListTile(
            leading: const Icon(Icons.data_object),
            title: Text(item["name"]),
            subtitle: Text("ID: ${item["id"]}"),
            trailing: Text("৳${item["price"]}"),
          );
        },
      ),
    );
  }
}