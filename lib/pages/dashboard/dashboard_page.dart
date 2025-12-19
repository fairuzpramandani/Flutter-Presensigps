<<<<<<< HEAD
import 'dart:convert'; // Import untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensigps/utils/app_colors.dart';
=======
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/auth_service.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/widgets/bottom_nav.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/utils/app_assets.dart';
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
<<<<<<< HEAD
  String _userName = "User";
  String _userJabatan = "Karyawan"; // Hapus 'final' agar bisa diupdate
=======
  static const String waktuMasukMax = "23:45:00";
  static const String waktuPulangMin = "17:00:00";
  
  UserModel? _currentUser;
  bool _isLoading = true;
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadUserData();
  }

  // Load data user dari SharedPreferences (Data dari Login API)
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data user yang disimpan di ApiService.login()
    final userString = prefs.getString('user');
    
    if (userString != null) {
      // Decode JSON string ke Map
      final user = jsonDecode(userString);
      setState(() {
        _userName = user['nama_lengkap'] ?? "User";
        _userJabatan = user['jabatan'] ?? "Karyawan"; 
=======
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
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
      });
    }
  }

<<<<<<< HEAD
  // Fungsi Logout
  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua sesi
    if (!mounted) return;
    
    // Kembali ke Login dan hapus history route
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --- HEADER DASHBOARD ---
          Container(
            height: 200,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary, // Warna Biru Dongker
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _userJabatan,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                )
              ],
            ),
          ),

          // --- MENU GRID ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(25),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildMenuItem(
                  "Absen Masuk", 
                  Icons.camera_alt, 
                  Colors.green, 
                  () {
                    // Navigator.pushNamed(context, '/presensi/create', arguments: {'ket': 'in'});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Absen Masuk (Segera)")));
                  }
                ),
                _buildMenuItem(
                  "Absen Pulang", 
                  Icons.camera_alt, 
                  Colors.red, 
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Absen Pulang (Segera)")));
                  }
                ),
                _buildMenuItem(
                  "Histori", 
                  Icons.history, 
                  Colors.blue, 
                  () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Histori (Segera)")));
                  }
                ),
                _buildMenuItem(
                  "Izin", 
                  Icons.mail, 
                  Colors.orange, 
                  () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Izin (Segera)")));
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // [FIX] Menggunakan .withValues() agar tidak deprecated
              color: Colors.black.withValues(alpha: 0.1), 
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
=======
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  void _handleAbsen(String batasWaktu, String jenisAbsen) {
    final currentTimeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    if (jenisAbsen == 'in') {
      if (currentTimeStr.compareTo(batasWaktu) > 0) {
        _showWarning('Waktu Habis!', 'Absen Masuk hanya bisa dilakukan sebelum jam ${batasWaktu.substring(0, 5)} WIB.');
      } else {
        Navigator.pushNamed(context, '/presensi/create', arguments: {'ket': 'in'});
      }
    } else if (jenisAbsen == 'out') {
      if (currentTimeStr.compareTo(batasWaktu) < 0) {
        _showWarning('Belum Waktunya!', 'Absen Pulang bisa dilakukan setelah jam ${batasWaktu.substring(0, 5)} WIB.');
      } else {
        Navigator.pushNamed(context, '/presensi/create', arguments: {'ket': 'out'});
      }
    }
  }

  void _showWarning(String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

    final photoUrl = (_currentUser?.foto?.isNotEmpty ?? false)
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_currentUser!.foto}'
        : AppAssets.avatarDefault;

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            final navigator = Navigator.of(context);
            await SessionManager.logout();
            if (!mounted) return;
            navigator.pushReplacementNamed('/login');
          },
        ),
      ],
    ),

    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Logo dan Avatar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    AppAssets.logo, // Logo
                    height: 110,
                  ),
                  ClipOval(
        child: FadeInImage.assetNetwork( // Menggunakan FadeInImage untuk fallback
          // Placeholder akan muncul saat loading atau jika fotoUrl bukan URL jaringan valid
          placeholder: AppAssets.avatarDefault, 
          
          // URL untuk foto profil dari Laravel
          image: photoUrl, 
          
          width: 50,  // Ukuran width (Radius 25 * 2)
          height: 50, // Ukuran height (Radius 25 * 2)
          fit: BoxFit.cover,
          
          // Fallback jika terjadi kegagalan jaringan/404
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
                AppAssets.avatarDefault,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
            );
          }),
        ),
              ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getGreeting(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Semoga harimu menyenangkan!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 95,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
                children: [
                  _buildIconItem(
                    iconPath: AppAssets.absenMasuk,
                    label: 'Absen Masuk',
                    onTap: () {
                      _handleAbsen(waktuMasukMax, 'in');
                    },
                  ),
                  _buildIconItem(
                    iconPath: AppAssets.absenKeluar,
                    label: 'Absen Pulang',
                    onTap: () {
                      _handleAbsen(waktuPulangMin, 'out');
                    },
                  ),
                  _buildIconItem(
                    iconPath: AppAssets.izin,
                    label: 'Izin & Sakit',
                    onTap: () {
                      Navigator.pushNamed(context, '/izin/list');
                    },
                  ),
                  _buildIconItem(
                    iconPath: AppAssets.histori,
                    label: 'Histori',
                    onTap: () {
                      Navigator.pushNamed(context, '/presensi/histori');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),

    bottomNavigationBar: const BottomNavigation(
      currentIndex: 0,
    ),
  );
}

Widget _buildIconItem({
  required String iconPath, 
  required String label, 
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, height: 130),
        const SizedBox(height: 15,),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
}