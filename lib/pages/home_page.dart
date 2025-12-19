import 'package:flutter/material.dart';
import '../utils/session_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Presensi"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await SessionManager.logout();
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
