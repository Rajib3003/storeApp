import 'package:flutter/material.dart';

class BackupPopupService {
  static bool _shown = false;

  static void checkAndShow(BuildContext context) {
    if (_shown) return;

    Future.delayed(const Duration(seconds: 2), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Restore Data?"),
          content: const Text(
            "Old data Google Drive থেকে restore করতে চান?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("New App"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // এখানে restore call করবে
                debugPrint("Restore clicked");
              },
              child: const Text("Restore"),
            ),
          ],
        ),
      );
    });

    _shown = true;
  }
}