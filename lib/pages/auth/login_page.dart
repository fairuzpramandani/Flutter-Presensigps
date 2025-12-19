import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/session_manager.dart';
import '../../utils/app_assets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> prosesLogin() async {
  setState(() {
    isLoading = true;
    message = null;
  });

<<<<<<< HEAD
  final res = await ApiService.login(
=======
  final res = await ApiService.login( // 1. Panggil API
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
    emailController.text,
    passwordController.text,
  );

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  if (res['status'] == 'success') {
    final String? token = res['token']; 
    if (token != null) {
        await SessionManager.saveToken(token); 
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
        setState(() {
           message = "Login berhasil, tetapi token tidak ditemukan."; 
        });
    }
  } else {
    setState(() {
      message = res['message'] ?? "Login gagal. Cek email dan password Anda.";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

<<<<<<< HEAD
=======
              // image
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
              Image.asset(
                AppAssets.logo,
                height: 150,
              ),

              const SizedBox(height: 20),
              const Text("Presensi-Geolocation",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const Text("Silahkan Login",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),

              const SizedBox(height: 25),

<<<<<<< HEAD
=======
              // alert
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
              if (message != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red)),
                  child: Text(message!,
                      style: const TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 20),

              // email input
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email address",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),

              const SizedBox(height: 20),

              // password input
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),

              const SizedBox(height: 10),

              // links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: const Text("Register Now",
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                  GestureDetector(
                    child: const Text("Forgot Password?",
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // login button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: isLoading ? null : prosesLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Log In",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
