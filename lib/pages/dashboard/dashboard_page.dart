import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/auth_service.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/widgets/bottom_nav.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/utils/app_assets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String waktuMasukMax = "23:45:00";
  static const String waktuPulangMin = "17:00:00";
  
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
}