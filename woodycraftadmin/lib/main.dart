import 'package:flutter/material.dart';
import 'puzzle_list_page.dart'; // Importer la page d'affichage des puzzles

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PuzzleListPage(), // Affiche la liste des puzzles en page d'accueil
    );
  }
}
