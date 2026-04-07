import 'package:flutter/material.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/app_assets.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userEmail = await SessionManager.getEmail(); 
      if (userEmail == null || userEmail.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final result = await ApiService.getProfile(userEmail); 
      if (!mounted) return;

      if (result['status'] == true) {
        setState(() {
          _currentUser = UserModel.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error Profile: $e");
      if (mounted) setState(() => _isLoading = false);
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

    bool hasFoto = _currentUser?.foto?.isNotEmpty ?? false;
    final photoUrl = hasFoto
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_currentUser!.foto}'
        : '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profile', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 252, 252, 252),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: hasFoto
                          ? NetworkImage(photoUrl) as ImageProvider
                          : AssetImage(AppAssets.avatarDefault) as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _currentUser?.namaLengkap ?? 'User',
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _currentUser?.jabatan ?? '-',
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),

            // --- MENU LIST ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListTitle('Akun'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: _buildListItem(
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
                  ),
                  
                  _buildListTitle('Aplikasi'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: _buildListItem(
                      title: 'Versi Aplikasi',
                      icon: Icons.info_outline,
                      color: Colors.black54,
                      trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                      onTap: null, 
                    ),
                  ),

                  _buildListTitle('Keluar'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: _buildListItem(
                      title: 'Logout',
                      icon: Icons.exit_to_app,
                      color: Colors.red,
                      onTap: _handleLogout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildListTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 15.0, bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}