import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:presensigps/services/api_service.dart';

class LokasiService {

  Future<List<dynamic>> getLokasi() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/lokasi"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["data"];
    }

    return [];
  }
}
