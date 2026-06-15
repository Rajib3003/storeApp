import 'package:flutter/material.dart';
import 'product_model.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text("Stock: ${product.stock}"),
        trailing: Text(
          "৳${product.sellingPrice}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}