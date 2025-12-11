import 'package:flutter/material.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/models/departemen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final jabatanController = TextEditingController();
  final noHpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // State untuk Dropdown Departemen
  List<Departemen> departemenList = [];
  String? selectedKodeDept;
  
  bool isLoading = false;
  String? errorMessage;
  Map<String, List<String>> validationErrors = {};

  @override
  void initState() {
    super.initState();
    _fetchDepartemen();
  }

  Future<void> _fetchDepartemen() async {
  try {
    final res = await ApiService.getDepartemenList(); 
    
    if (res['status'] == 'success' && res['data'] != null) {
      setState(() {
        departemenList = (res['data'] as List)
            .map((json) => Departemen.fromJson(json))
            .toList();
      });
    } else {
      debugPrint("Gagal memuat departemen: ${res['message']}"); 
    }
  } catch (e) {
    debugPrint("Exception fetching departemen: $e");
  }
}
  Future<void> prosesRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
      validationErrors = {};
    });

    final data = {
      'nama_lengkap': namaController.text,
      'email': emailController.text,
      'jabatan': jabatanController.text,
      'no_hp': noHpController.text,
      'kode_dept': selectedKodeDept,
      'password': passwordController.text,
      'password_confirmation': confirmPasswordController.text,
    };

    final res = await ApiService.register(data);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (res['status'] == 'success') {
      // Navigasi ke halaman login dengan pesan sukses (Pop dan Push ke root login)
      Navigator.pop(context); // Kembali ke halaman login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Akun berhasil dibuat!")),
      );
    } else {
      setState(() {
        if (res['errors'] != null) {
          // Asumsi error validasi dari Laravel dikirim sebagai 'errors'
          validationErrors = Map<String, List<String>>.from(res['errors']);
        }
        errorMessage = res['message'] ?? "Registrasi gagal, coba periksa data Anda.";
      });
    }
  }

  // --- WIDGET VALIDATION HELPER ---
  String? _getFieldError(String fieldName) {
    if (validationErrors.containsKey(fieldName)) {
      return validationErrors[fieldName]!.join('\n');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Akun Karyawan"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // image
                Image.asset(
                  AppAssets.logo,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text("Buat Akun Karyawan",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const Text("Silahkan Isi Data Anda",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 25),

                // alert errors (Server side)
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red)),
                      child: Text(errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ),

                // NAMA LENGKAP
                TextFormField(
                  controller: namaController,
                  decoration: _inputDecoration("Nama Lengkap"),
                  validator: (value) => value == null || value.isEmpty ? 'Nama lengkap wajib diisi' : _getFieldError('nama_lengkap'),
                ),
                const SizedBox(height: 16),
                
                // EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email address"),
                  validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : _getFieldError('email'),
                ),
                const SizedBox(height: 16),

                // JABATAN
                TextFormField(
                  controller: jabatanController,
                  decoration: _inputDecoration("Jabatan"),
                  validator: (value) => value == null || value.isEmpty ? 'Jabatan wajib diisi' : _getFieldError('jabatan'),
                ),
                const SizedBox(height: 16),

                // NO HP
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("No. HP"),
                  validator: (value) => value == null || value.isEmpty ? 'No. HP wajib diisi' : _getFieldError('no_hp'),
                ),
                const SizedBox(height: 16),

                // PILIH DEPARTEMEN
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Pilih Departemen"),
                  initialValue: selectedKodeDept,
                  hint: const Text("Pilih Departemen"),
                  items: departemenList.map((d) {
                    return DropdownMenuItem(
                      value: d.kodeDept,
                      child: Text(d.namaDept),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedKodeDept = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Departemen wajib dipilih' : _getFieldError('kode_dept'),
                ),
                const SizedBox(height: 16),


                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Password"),
                  validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : _getFieldError('password'),
                ),
                const SizedBox(height: 16),

                // KONFIRMASI PASSWORD
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration("Konfirmasi Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (value != passwordController.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: isLoading ? null : prosesRegister,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Buat Akun",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),

                // LOGIN LINK
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Kembali ke halaman login
                  },
                  child: const Text("Sudah Punya Akun? Login di sini",
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      errorText: _getFieldError(_getFieldNameFromLabel(label)),
    );
  }

  String _getFieldNameFromLabel(String label) {
    switch (label) {
      case "Nama Lengkap": return "nama_lengkap";
      case "Email address": return "email";
      case "Jabatan": return "jabatan";
      case "No. HP": return "no_hp";
      case "Pilih Departemen": return "kode_dept";
      case "Password": return "password";
      default: return "";
    }
  }
}
