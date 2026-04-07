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

    try {
      final res = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      if (res['status'] == true) {
        final String? token = res['access_token']; 

        if (token != null) {
          await SessionManager.saveToken(token);
          await SessionManager.saveEmail(emailController.text);
          final profileData = await ApiService.getProfile(emailController.text);
          if (!mounted) return;
          setState(() => isLoading = false);

          debugPrint("=== BALASAN API PROFILE ===");
          debugPrint(profileData.toString());
          debugPrint("===========================");

          bool isSuccess = profileData['status'] == true || profileData['status'] == 'success';

          if (isSuccess && profileData['data'] != null) {
            var faceData = profileData['data']['face_embedding'];
            if (faceData == null || faceData.toString().trim().isEmpty) {
              Navigator.pushReplacementNamed(context, '/registrasi-wajah');
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          } else {
             debugPrint("Gagal baca profile, fallback ke dashboard.");
             Navigator.pushReplacementNamed(context, '/dashboard');
          }

        } else {
          setState(() {
            isLoading = false;
            message = "Login berhasil, tetapi token tidak ditemukan.";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          message = res['message'] ?? "Email atau Password salah.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = "Gagal terhubung ke server.";
        });
      }
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

              // image
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

              // alert
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
