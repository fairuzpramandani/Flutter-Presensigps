import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api"; // Untuk Web
    } else if (Platform.isAndroid) {
      return "http://192.168.100.3:8000/api"; // Untuk Android Emulator
    }
    // Tambahkan untuk iOS atau platform lain jika perlu
    return "http://localhost:8000/api";
  }

  // --- AUTENTIKASI ---
  
  static Future<dynamic> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {
        'email': email,
        'password': password,
      },
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> getDepartemenList() async {
  final response = await http.get(
      Uri.parse("$baseUrl/departemen"),
    );
    if (response.statusCode != 200) {
        return {'status': 'error', 'message': 'Gagal koneksi ke API departemen'}; 
    }
    
    return jsonDecode(response.body);
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      body: data,
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> directResetPassword(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot-password/reset"),
      body: data, 
    );
    return jsonDecode(response.body);
  }

  // --- PRESENSI & RIWAYAT ---

  static Future<dynamic> getPresensiHariIni(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/presensi/hariini"),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> presensiStore(String token, String lokasi, String imageBase64) async {
    final response = await http.post(
      Uri.parse("$baseUrl/presensi/store"),
      headers: {
        'Authorization': 'Bearer $token'
      },
      body: {
        'lokasi': lokasi,
        'image': imageBase64,
      },
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> histori(String token, String bulan, String tahun) async {
    final response = await http.get(
      Uri.parse("$baseUrl/presensi/histori?bulan=$bulan&tahun=$tahun"),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );
    return jsonDecode(response.body);
  }

  // --- PROFIL & IZIN ---
  
  static Future<dynamic> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> izinStore(String token, String tgl, String status, String ket) async {
    final response = await http.post(
      Uri.parse("$baseUrl/izin/store"),
      headers: {
        'Authorization': 'Bearer $token'
      },
      body: {
        'tgl_izin': tgl,
        'status': status,
        'keterangan': ket,
      },
    );
    return jsonDecode(response.body);
  }

    static Future<dynamic> updateProfile(String token, Map<String, dynamic> data) async {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/profile/update"),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json', // Header yang baik untuk dimiliki
          },
          body: data,
        ).timeout(const Duration(seconds: 15));

        return jsonDecode(response.body);

      } catch (e) {
        return {'status': 'error', 'message': 'Kesalahan jaringan atau server tidak merespons.'};
      }
    }
    }