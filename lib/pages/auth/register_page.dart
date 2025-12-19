import 'package:flutter/material.dart';
import 'package:presensigps/services/api_service.dart';
<<<<<<< HEAD
import 'package:presensigps/utils/app_colors.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/models/departemen.dart';
import 'package:presensigps/models/jam_kerja.dart';
=======
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/models/departemen.dart';
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
<<<<<<< HEAD
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  List<Departemen> _deptList = [];
  List<JamKerja> _jamKerjaList = [];
  
  String? _selectedDept;
  String? _selectedJamKerja;
  
  bool _isLoading = false;
  bool _isDataLoading = true;
  bool _isConnectionError = false; // Penanda jika koneksi gagal
=======
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
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadData();
  }

  // --- LOGIKA LOAD DATA ASLI (TANPA DUMMY) ---
  void _loadData() async {
    setState(() {
      _isDataLoading = true;
      _isConnectionError = false;
    });

    try {
      // 1. Ambil Data Real dari API
      final deptResult = await ApiService.getDepartemenList();
      final jamResult = await ApiService.getJamKerjaList();

      // Cek apakah data valid
      if (deptResult is List && jamResult is List) {
        setState(() {
          _deptList = deptResult.map((data) => Departemen.fromJson(data)).toList();
          _jamKerjaList = jamResult.map((data) => JamKerja.fromJson(data)).toList();
          _isDataLoading = false;
        });
      } else {
        throw Exception("Format data salah");
      }
    } catch (e) {
      debugPrint("Gagal Load Data: $e");
      // Jika Error, tampilkan tombol Retry, JANGAN pakai dummy data
      setState(() {
        _isDataLoading = false;
        _isConnectionError = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal terhubung ke Server. Pastikan Laravel jalan di 0.0.0.0"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_passwordController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password tidak cocok!")));
      return;
    }

    if (_selectedDept == null || _selectedJamKerja == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih Departemen & Jam Kerja")));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nama_lengkap': _namaController.text,
      'email': _emailController.text,
      'no_hp': _hpController.text,
      'jabatan': _jabatanController.text,
      'kode_dept': _selectedDept,
      'kode_jam_kerja': _selectedJamKerja,
      'password': _passwordController.text,
      'password_confirmation': _confirmPassController.text,
    };

    final result = await ApiService.register(data);
    setState(() => _isLoading = false);

    if (result['status'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil! Silahkan Login"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
    }
=======
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
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text("Registrasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Center(child: Image.asset(AppAssets.logo, height: 100)),
            const SizedBox(height: 20),
            const Text("Buat Akun Karyawan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Text("Silahkan Isi Data Anda", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),

            _buildInput(_namaController, "Nama Lengkap", Icons.person),
            const SizedBox(height: 15),
            _buildInput(_emailController, "Email", Icons.email, type: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildInput(_jabatanController, "Jabatan", Icons.work),
            const SizedBox(height: 15),
            _buildInput(_hpController, "No. HP", Icons.phone, type: TextInputType.phone),
            const SizedBox(height: 15),

            // --- DROPDOWN DEPARTEMEN (DINAMIS) ---
            _isConnectionError 
                ? _buildRetryButton("Gagal memuat Departemen") // Tampil jika koneksi putus
                : _buildDropdown(
                    hint: "Pilih Departemen",
                    icon: Icons.business,
                    value: _selectedDept,
                    items: _deptList.map((d) => DropdownMenuItem(value: d.kodeDept, child: Text(d.namaDept))).toList(),
                    onChanged: (val) => setState(() => _selectedDept = val),
                  ),
            const SizedBox(height: 15),

            // --- DROPDOWN JAM KERJA (DINAMIS) ---
            _isConnectionError 
                ? _buildRetryButton("Gagal memuat Jam Kerja") // Tampil jika koneksi putus
                : _buildDropdown(
                    hint: "Pilih Jam Kerja",
                    icon: Icons.access_time,
                    value: _selectedJamKerja,
                    items: _jamKerjaList.map((jk) => DropdownMenuItem(
                      value: jk.kodeJamKerja, 
                      child: Text("${jk.namaJamKerja} (${jk.jamMasuk}-${jk.jamPulang})")
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedJamKerja = val),
                  ),
            const SizedBox(height: 15),

            _buildInput(_passwordController, "Password", Icons.lock, isPassword: true),
            const SizedBox(height: 15),
            _buildInput(_confirmPassController, "Konfirmasi Password", Icons.lock_clock, isPassword: true),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (_isLoading || _isConnectionError) ? null : _handleRegister,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Buat Akun", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol Retry jika koneksi gagal
  Widget _buildRetryButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: _loadData, 
            child: const Text("Coba Lagi")
          )
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, 
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint, 
    required IconData icon,
    required String? value, 
    required List<DropdownMenuItem<String>>? items, 
    required Function(String?) onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: _isDataLoading 
                  ? const Text("Memuat data...", style: TextStyle(color: Colors.orange)) 
                  : Text(hint, style: TextStyle(color: Colors.grey.shade400)),
                value: value,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
=======
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
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
