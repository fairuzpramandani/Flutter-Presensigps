import 'package:flutter/material.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/auth_service.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_assets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Mengambil data profil terbaru dari API
  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Opsional: tampilkan error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photoUrl = (_user?.foto?.isNotEmpty ?? false)
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_user!.foto}'
        : AppAssets.avatarDefault;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigasi ke Edit Profile dan tunggu hasilnya (saat pop)
              final result = await Navigator.pushNamed(context, '/profile/edit');
              
              // Jika data diperbarui, refresh halaman
              if (result == true) {
                _fetchProfileData();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Foto Profil ---
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: photoUrl.startsWith('http')
                    ? NetworkImage(photoUrl) as ImageProvider
                    : AssetImage(AppAssets.avatarDefault) as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileItem('Nama Lengkap', _user?.namaLengkap),
                    _buildProfileItem('Email', _user?.email),
                    _buildProfileItem('Jabatan', _user?.jabatan),
                    _buildProfileItem('No. HP', _user?.noHp),
                    _buildProfileItem('Departemen', _user?.namaDept),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? '-', style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}