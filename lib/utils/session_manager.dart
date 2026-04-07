import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyToken = "token";
  static const String keyEmail = "email";
  // Menyimpan Token
  static Future<void> saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyToken, token);
  }

  // Mengambil Token
  static Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(keyToken);
  }

  // Menyimpan Email
  static Future<void> saveEmail(String email) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyEmail, email);
  }

  // Mengambil Email
  static Future<String?> getEmail() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(keyEmail);
  }

  // --- LOGOUT ---
  
  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}