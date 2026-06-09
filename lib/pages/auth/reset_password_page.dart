import 'package:flutter/material.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_colors.dart';
import 'package:presensigps/utils/app_assets.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!")),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _message = null;
      _success = false;
    });

    final data = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'password_confirmation': _confirmPassController.text,
    };

    final res = await ApiService.directResetPassword(data); 

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res['status'] == true || res['status'] == 'success') {
      setState(() {
        _success = true;
        _message = "Password berhasil diperbarui! Silahkan login.";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      setState(() {
        _message = res['message'] ?? "Gagal memperbarui password.";
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Ubah Password"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(child: Image.asset(AppAssets.logo, height: 100)),
                const SizedBox(height: 20),
                const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Text(
                  "Masukkan Email & Password Baru Anda",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Pesan Alert
                if (_message != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _success ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _success ? Colors.green : Colors.red),
                    ),
                    child: Text(_message!, style: TextStyle(color: _success ? Colors.green : Colors.red)),
                  ),

                // Input Email
                _buildInput(_emailController, "Email Terdaftar", Icons.email),
                const SizedBox(height: 15),

                // Input Password Baru
                _buildInput(_passwordController, "Password Baru", Icons.lock, isPassword: true),
                const SizedBox(height: 15),

                // Input Konfirmasi Password
                _buildInput(_confirmPassController, "Konfirmasi Password Baru", Icons.lock_clock, isPassword: true),
                const SizedBox(height: 30),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _handleResetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Ubah Password", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kembali ke Login", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (v) => v!.isEmpty ? "$hint wajib diisi" : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}