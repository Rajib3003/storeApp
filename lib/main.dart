import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/services/network_watcher.dart';

import 'features/auth/login_screen.dart';
import 'features/home/home_page.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());

  // Start network watcher after app starts
  Future.delayed(const Duration(seconds: 2), () {
    NetworkWatcher.startListening();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Shop",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashRouter(),
    );
  }
}

/// Decide login or home
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool("google_logged_in") ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const HomePage() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}