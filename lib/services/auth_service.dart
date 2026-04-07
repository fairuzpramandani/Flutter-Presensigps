import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:presensigps/models/user.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/services/api_service.dart';

class AuthService {

  Future<UserModel?> getCurrentUser() async {
    final token = await SessionManager.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body["status"] == "success") {
        return UserModel.fromJson(body["data"]);
      }
    }

    return null;
  }
}
