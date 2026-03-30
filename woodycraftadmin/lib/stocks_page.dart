import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  // Palette WoodyCraft
  static const Color bg = Color(0xFFF5F0E8);
  static const Color accent = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);
  static const Color danger = Color(0xFFB85C5C);
  static const Color cardColor = Color(0xFFFFFFFF);

  List<dynamic> _puzzles = [];
  bool _isLoading = true;

  final String apiUrl = 'http://groupe1.lycee.local/api/stocks';

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  Future<void> _fetchStocks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _puzzles = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showMessage("Erreur serveur (${response.statusCode})");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage("Erreur de connexion : $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStock(int id, int nouvelleValeur) async {
    if (nouvelleValeur < 0) return;
    try {
      final response = await http.patch(
        Uri.parse("$apiUrl/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"quantite": nouvelleValeur}),
      );
      if (response.statusCode == 200) {
        _fetchStocks();
      } else {
        _showMessage("Erreur mise à jour (${response.statusCode})");
      }
    } catch (e) {
      _showMessage("Erreur réseau : $e");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Gestion des Stocks',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: accent),
        actions: [
          IconButton(
            onPressed: _fetchStocks,
            icon: const Icon(Icons.refresh_rounded, color: accent),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : _puzzles.isEmpty
              ? const Center(child: Text("Aucun produit trouvé."))
              : RefreshIndicator(
                  onRefresh: _fetchStocks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _puzzles.length,
                    itemBuilder: (context, index) {
                      final p = _puzzles[index];
                      final int currentQty = p['stock'] ?? p['quantite'] ?? 0;
                      final bool isLow = currentQty <= 3;

                      return Card(
                        color: cardColor,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isLow
                              ? const BorderSide(color: danger, width: 1.5)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isLow
                                  ? danger.withOpacity(0.1)
                                  : accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isLow
                                  ? Icons.warning_amber_rounded
                                  : Icons.inventory_2_outlined,
                              color: isLow ? danger : accent,
                            ),
                          ),
                          title: Text(
                            p['nom'] ?? 'Sans nom',
                            style: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            isLow ? "Stock bas !" : "En stock",
                            style: TextStyle(
                              color: isLow ? danger : accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: danger, size: 26),
                                onPressed: () =>
                                    _updateStock(p['id'], currentQty - 1),
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  "$currentQty",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: accent, size: 26),
                                onPressed: () =>
                                    _updateStock(p['id'], currentQty + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}