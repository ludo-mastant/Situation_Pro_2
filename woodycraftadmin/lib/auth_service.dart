import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = "http://127.0.0.1:8000/api/login";

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }
}