import 'package:flutter/material.dart';
import '../backup/backup_service.dart';
import '../backup/drive_service.dart';
import '../backup/google_auth_service.dart';
import '../../main.dart';
import '../backup/restore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  Future<void> _loginAndInit() async {
    setState(() => loading = true);

    try {
      // 1. Google Login
      final user = await GoogleAuthService.signIn();

      if (user == null) {
        setState(() => loading = false);
        return;
      }

      // 2. Init Drive
      await DriveService.initDrive(user);

      // 3. Optional: immediate backup check
      await BackupService.backup();

      // 4. Optional: immediate restore check
      await RestoreService.restore();

      if (!mounted) return;

      // 4. Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      debugPrint("Login error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.store,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Smart Shop",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _loginAndInit,
                        icon: const Icon(Icons.login),
                        label: const Text("Sign in with Google"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}