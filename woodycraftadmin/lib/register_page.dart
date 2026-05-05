import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
          (route) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() => _errorMessage = data['message'] ?? 'Erreur inscription');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFFFDE84E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Text(
                    'CRÉE UN\nCOMPTE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: Colors.red, size: 36),
                  ),
                  SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nom',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12),
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  ],
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFDE84E),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('S\'INSCRIRE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                          ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('RETOUR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}