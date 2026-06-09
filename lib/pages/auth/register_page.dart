import 'package:flutter/material.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_colors.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/models/departemen.dart';
import 'package:presensigps/models/jam_kerja.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  bool _isConnectionError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
  if (!mounted) return;
  setState(() {
    _isDataLoading = true;
    _isConnectionError = false;
  });

    try {
      final deptResult = await ApiService.getDepartemenList();
      final jamResult = await ApiService.getJamKerjaList();

      if (!mounted) return;

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
      if (!mounted) return;
      setState(() {
        _isDataLoading = false;
        _isConnectionError = true;
      });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                ? _buildRetryButton("Gagal memuat Departemen")
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
                ? _buildRetryButton("Gagal memuat Jam Kerja")
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