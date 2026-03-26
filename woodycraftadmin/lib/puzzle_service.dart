import 'dart:convert';
import 'package:http/http.dart' as http;

class Puzzle {
  final int id;
  final String nom;
  final String description;
  final String image;
  final double prix;
  final int categorieId;
  final int stock;

  const Puzzle({
    required this.id,
    required this.nom,
    required this.description,
    required this.image,
    required this.prix,
    required this.categorieId,
    required this.stock,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'],
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      prix: (json['prix'] as num).toDouble(),
      categorieId: json['categorie_id'] ?? 1,
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'image': image,
      'prix': prix,
      'categorie_id': categorieId,
      'stock': stock,
    };
  }
}

class PuzzleService {
  final String apiUrl = "http://groupe1.lycee.local/api/puzzles";

  Future<List<Puzzle>> fetchPuzzles() async {
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Puzzle.fromJson(e)).toList();
      }
      throw Exception('Erreur chargement');
    } catch (e) {
      throw Exception('API inaccessible : $e');
    }
  }

  Future<void> createPuzzle(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur création: ${response.body}');
    }
  }

  Future<void> updatePuzzle(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur update: ${response.body}');
    }
  }

  Future<void> deletePuzzle(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression');
    }
  }
}