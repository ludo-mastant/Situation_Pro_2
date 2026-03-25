import 'package:flutter/material.dart';
import 'admin_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoodyCraft Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF5F0E8),
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
      ),
      home: const AdminHomePage(),
    );
  }
}