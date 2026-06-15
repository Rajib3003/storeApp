import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int stock;

  const StockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    Color color;

    if (stock <= 0) {
      color = Colors.red;
    } else if (stock <= 2) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        stock <= 0 ? "OUT" : "Stock: $stock",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}