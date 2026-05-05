import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // On utilise l'URL de base que tu as définie dans tes autres services
  static const String baseUrl = "http://groupe1.lycee.local/api";

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de contacter l\'API : $e');
    }
  }
}