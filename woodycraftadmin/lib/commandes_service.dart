import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Modèle article ──────────────────────────────────────────────────────────

class CommandeItem {
  final int puzzleId;
  final String nom;
  final int quantite;
  final double prix;
  final String? image;

  CommandeItem({
    required this.puzzleId,
    required this.nom,
    required this.quantite,
    required this.prix,
    this.image,
  });

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    final rawPrix = json['prix'] ??
        json['prix_unitaire'] ??
        json['price'] ??
        json['puzzle']?['prix'] ??
        0;
    final double prix = rawPrix is num
        ? rawPrix.toDouble()
        : double.tryParse(rawPrix.toString().replaceAll(',', '.')) ?? 0.0;

    final rawQty = json['quantite'] ?? json['quantity'] ?? json['qty'] ?? 1;
    final int quantite =
        rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 1;

    final String nom = json['nom'] ??
        json['name'] ??
        json['puzzle']?['nom'] ??
        json['puzzle']?['name'] ??
        'Produit';

    return CommandeItem(
      puzzleId: json['puzzle_id'] ?? json['id'] ?? 0,
      nom: nom,
      quantite: quantite,
      prix: prix,
      image: json['image'] ?? json['puzzle']?['image'],
    );
  }

  double get sousTotal => prix * quantite;
}

// ─── Modèle client ───────────────────────────────────────────────────────────

class CommandeClient {
  final int id;
  final String? nom;
  final String? email;
  final String? telephone;

  const CommandeClient({
    required this.id,
    this.nom,
    this.email,
    this.telephone,
  });

  factory CommandeClient.fromJson(Map<String, dynamic> json) {
    return CommandeClient(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      nom: json['nom']?.toString(),
      email: json['email']?.toString(),
      telephone: json['telephone']?.toString(),
    );
  }
}

// ─── Modèle adresse livraison ────────────────────────────────────────────────

class AdresseLivraison {
  final String? rue;
  final String? ville;
  final String? codePostal;
  final String? pays;

  const AdresseLivraison({this.rue, this.ville, this.codePostal, this.pays});

  factory AdresseLivraison.fromJson(Map<String, dynamic> json) {
    return AdresseLivraison(
      rue: json['rue']?.toString(),
      ville: json['ville']?.toString(),
      codePostal: json['code_postal']?.toString(),
      pays: json['pays']?.toString(),
    );
  }

  String get formatted {
    final parts = [rue, codePostal, ville, pays]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

// ─── Modèle commande ─────────────────────────────────────────────────────────

class Commande {
  final int id;
  final String statut;
  final double total;
  final List<CommandeItem> items;
  // Champs détail
  final String? modePaiement;
  final String? dateCommande;
  final CommandeClient? client;
  final AdresseLivraison? adresseLivraison;
  final int nbArticles;

  Commande({
    required this.id,
    required this.statut,
    required this.total,
    required this.items,
    this.modePaiement,
    this.dateCommande,
    this.client,
    this.adresseLivraison,
    this.nbArticles = 0,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    // Articles : clé "articles" en priorité (réponse API réelle)
    final rawItems =
        json['articles'] as List? ??
        json['items'] as List? ??
        json['lignes'] as List? ??
        [];
    final List<CommandeItem> itemsList = rawItems
        .map((i) => CommandeItem.fromJson(i as Map<String, dynamic>))
        .toList();

    // Total : String ou num
    double computedTotal = 0;
    final rawTotal = json['total'];
    if (rawTotal != null) {
      computedTotal = rawTotal is num
          ? rawTotal.toDouble()
          : double.tryParse(rawTotal.toString().replaceAll(',', '.')) ?? 0.0;
    }
    if (computedTotal == 0 && itemsList.isNotEmpty) {
      computedTotal = itemsList.fold(0.0, (s, i) => s + i.sousTotal);
    }

    // Client (objet imbriqué ou champs plats)
    CommandeClient? client;
    if (json['client'] is Map<String, dynamic>) {
      client = CommandeClient.fromJson(json['client'] as Map<String, dynamic>);
    } else if (json['client_id'] != null) {
      client = CommandeClient(
        id: json['client_id'] is int
            ? json['client_id']
            : int.tryParse(json['client_id'].toString()) ?? 0,
        email: json['email']?.toString(),
        nom: json['nom_client']?.toString(),
      );
    }

    // Adresse livraison (objet imbriqué ou champs plats)
    AdresseLivraison? adresse;
    if (json['adresse_livraison'] is Map<String, dynamic>) {
      adresse = AdresseLivraison.fromJson(
          json['adresse_livraison'] as Map<String, dynamic>);
    } else if (json['rue'] != null || json['ville'] != null) {
      adresse = AdresseLivraison(
        rue: json['rue']?.toString(),
        ville: json['ville']?.toString(),
        codePostal: json['code_postal']?.toString(),
        pays: json['pays']?.toString(),
      );
    }

    // nb_articles
    final rawNb = json['nb_articles'] ?? json['nbArticles'] ?? 0;
    final int nbArticles =
        rawNb is int ? rawNb : int.tryParse(rawNb.toString()) ?? 0;

    return Commande(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      statut: json['statut'] ?? 'en cours',
      total: computedTotal,
      items: itemsList,
      modePaiement: json['mode_paiement']?.toString(),
      dateCommande: json['date_commande']?.toString(),
      client: client,
      adresseLivraison: adresse,
      nbArticles: nbArticles,
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class CommandesService {
  final String apiUrl = "http://groupe1.lycee.local/api/paniers";

  Future<List<Commande>> fetchCommandes() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
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
        return data.map((e) => Commande.fromJson(e)).toList();
      }
      throw Exception('Erreur serveur (${response.statusCode})');
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<Commande> fetchCommandeDetail(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/$id'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Commande.fromJson(decoded);
        }
        throw Exception('Format JSON invalide');
      }
      throw Exception('Erreur serveur (${response.statusCode})');
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<void> validerCommande(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/$id/validate'),
        headers: {'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la validation');
    }
  }

  Future<void> expedierCommande(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/$id/checkout'),
        headers: {'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception("Erreur lors de l'expédition");
    }
  }

  Future<void> supprimerCommande(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'),
        headers: {'Accept': 'application/json'});
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}