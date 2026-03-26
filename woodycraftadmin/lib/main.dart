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
      debugShowCheckedModeBanner: false,
      title: 'WoodyCraft Admin',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const AdminHomePage(),
    );
  }
}