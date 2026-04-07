import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:presensigps/utils/session_manager.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000"; 
    } else if (Platform.isAndroid) {
      return "http://192.168.100.3:8000"; 
    }
    return "http://192.168.100.3:8000";
  }

  static String get pythonUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000"; 
    } else if (Platform.isAndroid) {
      return "http://192.168.100.3:5000"; 
    }
    return "http://192.168.100.3:5000";
  }

  static Map<String, String> headers = {
    'Accept': 'application/json',
  };

  
  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/proseslogin"),
        headers: headers,
        body: {
          'email': email,
          'password': password,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error Login: $e");
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  static Future<dynamic> getDepartemenList() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/departemen-list"), 
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server Error'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat data'};
    }
  }

  static Future<dynamic> getJamKerjaList() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/jam-kerja-list"), 
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server Error'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat data'};
    }
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/prosesregister"), 
        headers: headers,
        body: data,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal melakukan registrasi'};
    }
  }

  static Future<dynamic> directResetPassword(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ubah-password-cepat"), 
        headers: headers,
        body: data, 
      );
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error Decode: $e");
      return {'status': false, 'message': 'Format data dari server salah.'};
    }
  }

  static Future<dynamic> getPresensiHariIni(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/presensi/hariini"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat presensi hari ini'};
    }
  }

 static Future<dynamic> presensiStore(String token, String lokasi, String imageBase64) async {
    try {
      String urlTarget = "$baseUrl/api/presensi/store";
      debugPrint("==== 🚀 MENGIRIM ABSEN ====");
      debugPrint("Menembak URL: $urlTarget");
      debugPrint("Token: $token");

      final response = await http.post(
        Uri.parse(urlTarget),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'lokasi': lokasi,
          'image': imageBase64,
        },
      );

      debugPrint("==== 📩 BALASAN SERVER ====");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Isi Balasan: ${response.body}");

      if (response.body.contains('|')) {
        List<String> hasil = response.body.split('|');
        return {
          'status': hasil[0], 
          'message': hasil.length > 1 ? hasil[1] : 'Selesai'
        };
      }
      
      return jsonDecode(response.body);

    } catch (e) {
      debugPrint("==== ❌ ERROR APLIKASI ====");
      debugPrint("Pesan Error: $e");
      return {'status': 'error', 'message': 'Gagal mengirim presensi ke server'};
    }
  }

  static Future<dynamic> histori(String token, String bulan, String tahun) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/gethistori"), 
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
            'bulan': bulan,
            'tahun': tahun
        }
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat riwayat'};
    }
  }

  static Future<dynamic> getProfile(String email) async {
    try {
      final String url = "${baseUrl.replaceAll(RegExp(r'/$'), '')}/getprofile/$email";
      
      final response = await http.get(
        Uri.parse(url), 
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Kesalahan: $e'};
    }
  }

  static Future<dynamic> izinStore(String token, String tgl, String status, String ket) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/presensi/storeizin"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'tgl_izin': tgl,
          'status': status,
          'keterangan': ket,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal mengirim izin'};
    }
  }

  static Future<dynamic> updateProfile(String token, String email, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/profile/update/$email"), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: data,
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Kesalahan jaringan atau server tidak merespons.'};
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data,
      ).timeout(const Duration(seconds: 15));
      return response.body;
    } catch (e) {
      return "error|Gagal terhubung ke server.";
    }
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      return response.body;
    } catch (e) {
      return jsonEncode({'status': 'error', 'message': 'Koneksi gagal'});
    }
  }

  static Future<dynamic> getIzinList() async {
    try {
      String? token = await SessionManager.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'Token tidak ditemukan. Silakan login ulang.'};
      }
      debugPrint("Token dikirim: $token");

      final response = await http.get(
        Uri.parse("$baseUrl/api/presensi/izin"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Respon Body: ${response.body}");

      if (response.statusCode == 401) {
        return {'status': 'error', 'message': 'Sesi telah berakhir. Silakan login kembali.'};
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error API: $e");
      return {'status': 'error', 'message': 'Gagal memuat data izin'};
    }
  }

  static Future<dynamic> storeIzin(String tgl, String status, String ket) async {
    try {
      String? token = await SessionManager.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'Token tidak ditemukan. Silakan login ulang.'};
      }
      final response = await http.post(
        Uri.parse("$baseUrl/api/presensi/storeizin"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'tgl_izin': tgl,
          'status': status,
          'keterangan': ket,
        },
      );
      if (response.statusCode == 401) {
        return {'status': 'error', 'message': 'Sesi telah berakhir. Silakan login kembali.'};
      }
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal mengirim pengajuan'};
    }
  }

  static Future<dynamic> getHistori(String bulan, String tahun) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/presensi/histori"), 
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'bulan': bulan,
          'tahun': tahun,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat histori'};
    }
  }  

  static Future<void> laporKecurangan(String email, String tipe, String pesan) async {
    try {
      String? token = await SessionManager.getToken();
      await http.post(
        Uri.parse("$baseUrl/api/lapor-kecurangan"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'email': email,
          'tipe': tipe,
          'pesan': pesan,
        },
      );
    } catch (e) {
      debugPrint("Gagal kirim log kecurangan: $e");
    }
  }

}
