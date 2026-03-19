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
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return Puzzle(
      id: parseInt(json['id']),
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      prix: parseDouble(json['prix']),
      categorieId: parseInt(json['categorie_id'] ?? json['categorie']),
      stock: parseInt(json['stock']),
    );
  }
}

class PuzzleService {
  static const String apiUrl = 'http://groupe1.lycee.local/api/puzzles';

  Future<List<Puzzle>> fetchPuzzles() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Puzzle.fromJson(item)).toList();
    } else {
      throw Exception('Erreur chargement puzzles : ${response.body}');
    }
  }

  Future<Puzzle> createPuzzle({
    required String nom,
    required String description,
    required String image,
    required double prix,
    required int categorieId,
    required int stock,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Accept': 'application/json'},
      body: {
        'nom': nom,
        'description': description,
        'image': image,
        'prix': prix.toString(),
        'categorie_id': categorieId.toString(),
        'stock': stock.toString(),
      },
    );

    return _parsePuzzleResponse(response);
  }

  Future<Puzzle> updatePuzzle({
    required int id,
    required String nom,
    required String description,
    required String image,
    required double prix,
    required int categorieId,
    required int stock,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$id'),
      headers: {'Accept': 'application/json'},
      body: {
        '_method': 'PUT',
        'nom': nom,
        'description': description,
        'image': image,
        'prix': prix.toString(),
        'categorie_id': categorieId.toString(),
        'stock': stock.toString(),
      },
    );

    return _parsePuzzleResponse(response);
  }

  Future<void> deletePuzzle(int id) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$id'),
      headers: {'Accept': 'application/json'},
      body: {
        '_method': 'DELETE',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression puzzle : ${response.body}');
    }
  }

  Puzzle _parsePuzzleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return Puzzle.fromJson(decoded);
      }
      throw Exception('Réponse API invalide');
    } else {
      throw Exception(
        'Erreur ${response.statusCode} : ${response.body}',
      );
    }
  }
}