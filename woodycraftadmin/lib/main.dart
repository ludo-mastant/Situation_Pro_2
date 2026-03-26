import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart'; // Importation de la page d'interface

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminHomePage(),
    const AdminOrdersPage(), // On affiche la page des commandes ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF8B6F47),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.extension_rounded), label: 'Puzzles'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Commandes'),
        ],
      ),
    );
  }
}