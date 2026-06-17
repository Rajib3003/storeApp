import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
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

    final user = await GoogleAuthService.signIn();

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    await DriveService.initDrive(user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("google_logged_in", true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: login,
                child: const Text("Sign in with Google"),
              ),
      ),
    );
  }
}