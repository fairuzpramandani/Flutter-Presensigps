<<<<<<< HEAD
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  // Simpan Token
=======
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _tokenKey = 'auth_token';

  // Menyimpan token ke SharedPreferences
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

<<<<<<< HEAD
  // Ambil Token
=======
  // Mengambil token dari SharedPreferences
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

<<<<<<< HEAD
  // Simpan Data User (Nama, Jabatan, dll)
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Hapus Sesi (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
=======
  // Menghapus token (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
>>>>>>> 0d66115c9de84a8bda2a8b133345512240efbc5b
  }
}