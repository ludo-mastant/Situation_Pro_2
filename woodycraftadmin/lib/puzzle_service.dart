import 'dart:convert';
import 'package:http/http.dart' as http;

class Puzzle {
  final int id;
  final String nom;
  final String description;
  final String image; // Champ pour l'image
  final double prix; // Champ pour le prix
  final String categorie; // Champ pour la catégorie

  Puzzle({
    required this.id,
    required this.nom,
    required this.description,
    this.image = '', // Valeur par défaut
    this.prix = 0.0, // Valeur par défaut
    this.categorie = '', // Valeur par défaut
  });

  // Méthode pour convertir la réponse JSON en un objet Puzzle
  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'],
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      prix: json['prix']?.toDouble() ?? 0.0,
      categorie: json['categorie'] ?? '',
    );
  }
}

class PuzzleService {
  final String apiUrl = "http://localhost/woodycraftweb/public/api/puzzles"; // URL de l'API Laravel

  // Fonction pour récupérer tous les puzzles
  Future<List<Puzzle>> fetchPuzzles() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Puzzle> puzzles = body.map((dynamic item) => Puzzle.fromJson(item)).toList();
      return puzzles;
    } else {
      throw Exception('Failed to load puzzles');
    }
  }

  // Fonction pour ajouter un nouveau puzzle (POST)
  // Fonction pour ajouter un nouveau puzzle (POST)
Future<Puzzle> createPuzzle(String nom, String description, String image, double prix, String categorie) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nom': nom,
        'description': description,
        'image': image, // Ajouter l'image
        'prix': prix, // Ajouter le prix
        'categorie': categorie, // Ajouter la catégorie
      }),
    );

    if (response.statusCode == 201) {
      return Puzzle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create puzzle: ${response.body}'); // Afficher le corps de la réponse en cas d'erreur
    }
}

}
