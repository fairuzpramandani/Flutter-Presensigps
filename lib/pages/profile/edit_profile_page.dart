import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/utils/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  UserModel? _initialUser;
  bool _isLoading = true;
  String? _errorMessage;
  XFile? _pickedFile;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

 Future<void> _loadInitialData() async {
    try {
      String? userEmail = await SessionManager.getEmail();

      if (userEmail == null || userEmail.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final result = await ApiService.getProfile(userEmail);

      if (!mounted) return;

      if (result['status'] == true) {
        _initialUser = UserModel.fromJson(result['data']);
        namaController.text = _initialUser?.namaLengkap ?? '';
        phoneController.text = _initialUser?.noHp ?? '';
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Load Data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedFile = pickedFile;
        _base64Image = base64Encode(fileBytes);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await SessionManager.getToken();

    final data = {
      'nama_lengkap': namaController.text,
      'no_hp': phoneController.text,
      if (_base64Image != null) 'foto': _base64Image!, 
      if (passwordController.text.isNotEmpty) 'password': passwordController.text,
      if (passwordController.text.isNotEmpty) 'password_confirmation': confirmPasswordController.text,
    };

    final res = await ApiService.updateProfile(token!, _initialUser!.email ?? '', data);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Profil berhasil diperbarui.')),
      );
      Navigator.pop(context, true); 
    } else {
      setState(() {
        _errorMessage = res['message'] ?? (res['errors']?['nama_lengkap']?.join('\n') ?? 'Gagal memperbarui profil.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final currentPhotoUrl = (_initialUser?.foto?.isNotEmpty ?? false)
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_initialUser!.foto}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _pickedFile != null
                      ? NetworkImage(_pickedFile!.path)
                      : (currentPhotoUrl != null
                          ? NetworkImage(currentPhotoUrl)
                          : AssetImage(AppAssets.avatarDefault)) as ImageProvider,
                  child: _pickedFile == null && currentPhotoUrl == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.black54)
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              // --- Field Nama Lengkap ---
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // --- Field No HP ---
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Nomor HP wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              // --- Field Password Baru ---
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru (kosongkan jika tidak diubah)'),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 5) {
                    return 'Password minimal 5 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Field Konfirmasi Password ---
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Konfirmasi password tidak cocok.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}