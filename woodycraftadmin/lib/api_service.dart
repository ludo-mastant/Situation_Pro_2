import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://groupe1.lycee.local/api';

  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur API ($endpoint) : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API inaccessible : $e');
    }
  }

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur POST ($endpoint) : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
}
