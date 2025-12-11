import 'package:flutter/material.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/services/auth_service.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/utils/session_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    final navigator = Navigator.of(context);
    await SessionManager.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photoUrl = (_currentUser?.foto?.isNotEmpty ?? false)
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_currentUser!.foto}'
        : AppAssets.avatarDefault;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserData,
          )
        ],
        leading: IconButton( 
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Bagian Profil dan Jabatan ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: photoUrl.startsWith('http')
                              ? NetworkImage(photoUrl) as ImageProvider
                              : AssetImage(AppAssets.avatarDefault) as ImageProvider,
                        ),
                      ),
                      // Nama Lengkap
                      Text(
                        _currentUser?.namaLengkap ?? 'User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // Jabatan
                      Text(
                        _currentUser?.jabatan ?? '-',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                
                _buildListTitle('Akun'),
                _buildListItem(
                  title: 'Edit Profil',
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile/edit').then((result) {
                        if (result == true) {
                            _fetchUserData();
                        }
                    });
                  },
                ),
                
                _buildListTitle('Aplikasi'),
                _buildListItem(
                  title: 'Versi Aplikasi',
                  icon: Icons.info_outline,
                  color: Colors.black54,
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                  onTap: null, 
                ),

                _buildListTitle('Keluar'),
                _buildListItem(
                  title: 'Logout',
                  icon: Icons.exit_to_app,
                  color: Colors.red,
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}