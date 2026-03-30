import 'dart:convert';
import 'package:http/http.dart' as http;

class Commande {
  final int id;
  final String statut;
  final double total;
  final List<CommandeItem> items;

  Commande({
    required this.id,
    required this.statut,
    required this.total,
    required this.items,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    List<CommandeItem> items = [];
    if (json['items'] != null) {
      statut: json['statut'] ?? '',
      total: (json['total'] is num)
        ? (json['total'] as num).toDouble()
        : double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    }

    return Commande(
      id: json['id'],
      statut: json['statut'] ?? '',
      total: json['total']?.toDouble() ?? 0.0,
      items: items,
    );
  }
}

class CommandeItem {
  final int id;
  final String nom;
  final int quantite;
  final double prix;

  CommandeItem({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.prix,
  });

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    return CommandeItem(
      id: json['id'],
      nom: json['nom'] ?? '',
      quantite: json['quantite'] ?? 1,
      prix: json['prix']?.toDouble() ?? 0.0,
    );
  }
}

class CommandesService {
  final String apiUrl = "http://groupe1.lycee.local/api/paniers";

  Future<List<Commande>> fetchCommandes() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      List<dynamic> body;

      if (decoded is List) {
        body = decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('data')) {
          body = decoded['data'];
        } else if (decoded.containsKey('paniers')) {
          body = decoded['paniers'];
        } else if (decoded.containsKey('commandes')) {
          body = decoded['commandes'];
        } else {
          throw Exception(
              'Structure JSON inattendue. Clés disponibles: ${decoded.keys.toList()}');
        }
      } else {
        throw Exception('Format de réponse inattendu: ${decoded.runtimeType}');
      }

      return body.map((item) => Commande.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Valider une commande (PUT /paniers/{id}/validate)
  Future<void> validerCommande(int id) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id/validate'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la validation: ${response.body}');
    }
  }

  // Expédier une commande (PUT /paniers/{id}/checkout)
  Future<void> expedierCommande(int id) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id/checkout'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'expédition: ${response.body}');
    }
  }

  // Supprimer une commande (DELETE /paniers/{id})
  Future<void> supprimerCommande(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression: ${response.body}');
    }
  }
}
