import 'package:flutter/material.dart';
import 'package:presensigps/pages/auth/forgot_password_page.dart';
import 'package:presensigps/pages/auth/login_page.dart';
import 'package:presensigps/pages/auth/register_page.dart';
import 'package:presensigps/pages/auth/reset_password_page.dart';
import 'package:presensigps/pages/dashboard/dashboard_page.dart';
import 'package:presensigps/pages/profile/edit_profile_page.dart';
import 'package:presensigps/pages/profile/profile_page.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/pages/presensi/presensi_create_page.dart';
import 'package:presensigps/pages/settings/settings_page.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile/edit': (context) => const EditProfilePage(),
        '/presensi/create': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PresensiCreatePage(ket: args['ket']);
        },
        '/presensi/histori': (context) => Scaffold(appBar: AppBar(title: const Text('Histori Presensi')), body: const Center(child: Text("Halaman Histori"))),
        '/izin/list': (context) => Scaffold(appBar: AppBar(title: const Text('Daftar Izin')), body: const Center(child: Text("Halaman Izin"))),
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
    final token = await SessionManager.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
