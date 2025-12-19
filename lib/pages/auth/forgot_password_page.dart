import 'package:flutter/material.dart';
import 'package:presensigps/services/api_service.dart';
<<<<<<< HEAD
import 'package:presensigps/utils/app_colors.dart';
=======
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
<<<<<<< HEAD
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.forgotPassword(_emailController.text);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
=======
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _message = null;
      _success = false;
    });

    final res = await ApiService.directResetPassword({
      'email': _emailController.text,
      // Untuk direct reset, Anda juga perlu password baru di form ini, tapi 
      // karena Blade hanya meminta email, kita asumsikan ini adalah 'Forgot Password' sederhana.
    }); 

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res['status'] == 'success') {
      setState(() {
        _success = true;
        _message = res['message'] ?? "Silakan cek email Anda untuk instruksi reset password.";
      });
      // Navigasi ke halaman Reset Password (opsional, tergantung alur Anda)
      // Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage())); 

    } else {
      setState(() {
        _message = res['message'] ?? res['errors']?['email']?.join('\n') ?? "Gagal mengirim link reset.";
        _success = false;
      });
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text("Lupa Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Masukkan email Anda untuk reset password"),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Kirim"),
              ),
            )
          ],
=======
      appBar: AppBar(
        title: const Text("Lupa Password"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masukkan email Anda. Kami akan mengirimkan link untuk mereset password Anda.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Alert Messages
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _success ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _success ? Colors.green : Colors.red),
                      ),
                      child: Text(_message!, style: TextStyle(color: _success ? Colors.green : Colors.red)),
                    ),
                  ),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Terdaftar",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Button Kirim Link
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Kirim Link Reset", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Link Kembali
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Center(
                    child: Text("Kembali ke Login", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  ),
                ),
              ],
            ),
          ),
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
        ),
      ),
    );
  }
}