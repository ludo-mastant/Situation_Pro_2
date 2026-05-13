import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ajout_appro_page.dart'; // 👈 AJOUT IMPORTANT

class ApprovisionnementPage extends StatefulWidget {
  const ApprovisionnementPage({super.key});

  @override
  State<ApprovisionnementPage> createState() => _ApprovisionnementPageState();
}

class _ApprovisionnementPageState extends State<ApprovisionnementPage> {
  List approvisionnements = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchApprovisionnements();
  }

  Future<void> fetchApprovisionnements() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/approvisionnements"),
      );

      if (response.statusCode == 200) {
        setState(() {
          approvisionnements = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Erreur serveur (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Erreur de connexion: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approvisionnements"),
        backgroundColor: const Color(0xFF8B6F47),
      ),

      // 🔵 BOUTON + EN BAS
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B6F47),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AjoutApproPage(),
            ),
          ).then((value) {
            // 🔄 refresh après ajout
            if (value == true) {
              fetchApprovisionnements();
            }
          });
        },
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: approvisionnements.length,
                  itemBuilder: (context, index) {
                    final item = approvisionnements[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: Text(item['nomFournisseur'] ?? 'Inconnu'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantité : ${item['quantitee']}"),
                            Text("Puzzle ID : ${item['puzzle_id']}"),
                            Text("Date : ${item['date'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}