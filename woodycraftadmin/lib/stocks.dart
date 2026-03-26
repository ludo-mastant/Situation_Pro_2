import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StocksPage extends StatefulWidget {
  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  // Ta palette WoodyCraft
  final Color darkColor = const Color(0xFF202020);
  final Color redColor = const Color(0xFFD42323);
  final Color yellowColor = const Color(0xFFFFEE8C);

  List<dynamic> _puzzles = [];
  bool _isLoading = true;
  final String apiUrl = 'http://groupe1.lycee.local/api/stocks';

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  Future<void> _fetchStocks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _puzzles = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      _showMessage("Erreur de connexion", redColor);
    }
  }

  Future<void> _updateStock(int id, int nouvelleValeur) async {
    if (nouvelleValeur < 0) return;
    try {
      final response = await http.patch(
        Uri.parse("$apiUrl/$id"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"quantite": nouvelleValeur}),
      );
      if (response.statusCode == 200) {
        _fetchStocks();
      }
    } catch (e) {
      _showMessage("Erreur réseau", redColor);
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkColor, // FOND NOIR
        elevation: 4, // Un peu d'ombre pour le relief
        centerTitle: true,
        title: Text(
          "WOODYCRAFT",
          style: TextStyle(
            color: Colors.white, // TITRE BLANC
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: redColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _puzzles.length,
              itemBuilder: (context, index) {
                final p = _puzzles[index];
                final int currentQty = p['stock'] ?? p['quantite'] ?? 0;

                return Card(
                  color: yellowColor, // CARTES JAUNES
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: darkColor.withOpacity(0.1), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      p['nom']?.toUpperCase() ?? 'SANS NOM',
                      style: TextStyle(color: darkColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      "QUANTITÉ : $currentQty",
                      style: TextStyle(color: darkColor.withOpacity(0.7), fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: darkColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: redColor, size: 28),
                            onPressed: () => _updateStock(p['id'], currentQty - 1),
                          ),
                          Text(
                            "$currentQty",
                            style: TextStyle(color: darkColor, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: darkColor, size: 28),
                            onPressed: () => _updateStock(p['id'], currentQty + 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}