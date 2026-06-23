import 'package:flutter/material.dart';
import '../features/home/home_page.dart';

class HomeLeadingButton extends StatelessWidget {
  const HomeLeadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      },
    );
  }
}