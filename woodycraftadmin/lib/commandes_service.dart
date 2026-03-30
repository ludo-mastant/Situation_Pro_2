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
    var list = json['items'] as List? ?? [];
    List<CommandeItem> itemsList = list.map((i) => CommandeItem.fromJson(i)).toList();

    return Commande(
      id: json['id'],
      statut: json['statut'] ?? 'en cours',
      total: (json['total'] is num)
          ? (json['total'] as num).toDouble()
          : 0.0, // ← c'était ça qui manquait
      items: itemsList,
    );
  }
}

class CommandeItem {
  final String nom;
  final int quantite;
  final double prix;

  CommandeItem({required this.nom, required this.quantite, required this.prix});

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    return CommandeItem(
      nom: json['nom'] ?? 'Produit',
      quantite: json['quantite'] ?? 0,
      prix: (json['prix'] ?? 0).toDouble(),
    );
  }
}

class CommandesService {
  final String apiUrl = "http://groupe1.lycee.local/api/paniers";

  // GET /api/paniers
  Future<List<Commande>> fetchCommandes() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'];
        } else {
          data = [];
        }

        return data.map((item) => Commande.fromJson(item)).toList();
      }
      throw Exception('Erreur serveur (${response.statusCode})');
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  // PUT /api/paniers/{id}/validate (Validé)
  Future<void> validerCommande(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/$id/validate'));
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la validation');
    }
  }

  // PUT /api/paniers/{id}/checkout (Expédié)
  Future<void> expedierCommande(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/$id/checkout'));
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'expédition');
    }
  }

  // DELETE /api/paniers/{id} (Suppression)
  Future<void> supprimerCommande(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}