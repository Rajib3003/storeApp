import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/restore_service.dart';

import '../backup/google_auth_service.dart';
import '../backup/drive_service.dart';
import '../home/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final user = await GoogleAuthService.signIn();

      if (user == null) {
        setState(() => loading = false);
        return;
      }

      // Initialize Google Drive
      await DriveService.initDrive(user);

      // Restore Firebase data to local SQLite
      await RestoreService.restoreAll();

      // Save login status (Only first login)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("google_logged_in", true);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                onPressed: login,
              ),
      ),
    );
  }
}