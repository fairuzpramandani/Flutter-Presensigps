import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/pages/auth/login_page.dart';
import 'package:presensigps/pages/auth/register_page.dart';
import 'package:presensigps/pages/auth/reset_password_page.dart';
import 'package:presensigps/pages/dashboard/dashboard_page.dart';
import 'package:presensigps/pages/profile/edit_profile_page.dart';
import 'package:presensigps/pages/profile/profile_page.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/pages/presensi/presensi_create_page.dart';
import 'package:presensigps/pages/izin/izin_page.dart';
import 'package:presensigps/pages/izin/buat_izin_page.dart';
import 'package:presensigps/pages/presensi/histori_page.dart';
import '../pages/presensi/face_enrollment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A234E)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A234E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ResetPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/settings': (context) => const ProfilePage(),
        '/profile': (context) => const ProfilePage(),
        '/profile/edit': (context) => const EditProfilePage(),
        
        // Route Presensi
        '/presensi/create': (context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return PresensiCreatePage(ket: args['ket'] ?? 'in');
          }
          return const PresensiCreatePage(ket: 'in'); 
        },
        
        // ROUTE HISTORI
        '/presensi/histori': (context) => const HistoriPage(),

        '/registrasi-wajah': (context) => const FaceEnrollmentPage(),

        // Route Izin
        '/presensi/izin': (context) => const IzinPage(), 
        '/izin/list': (context) => const IzinPage(),
        '/presensi/buatizin': (context) => const BuatIzinPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final token = await SessionManager.getToken();
    final email = await SessionManager.getEmail();
    
    if (!mounted) return;
    
    if (token != null && email != null) {
      final profileData = await ApiService.getProfile(email);
      
      if (!mounted) return;
      bool isSuccess = profileData['status'] == true || profileData['status'] == 'success';

      if (isSuccess && profileData['data'] != null) {
        var faceData = profileData['data']['face_embedding'];
        if (faceData == null || faceData.toString().trim().isEmpty) {
          Navigator.pushReplacementNamed(context, '/registrasi-wajah');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }

    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A234E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}