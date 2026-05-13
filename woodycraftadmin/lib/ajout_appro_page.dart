import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjoutApproPage extends StatefulWidget {
  const AjoutApproPage({super.key});

  @override
  State<AjoutApproPage> createState() => _AjoutApproPageState();
}

class _AjoutApproPageState extends State<AjoutApproPage> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final quantiteController = TextEditingController();
  final puzzleController = TextEditingController();
  final dateController = TextEditingController();

  static const String baseUrl =
      "http://127.0.0.1:8000/api/approvisionnements";

  static const Color bg = Color(0xFFFFE8CC);
  static const Color accent = Color(0xFF8B6F47);

  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final data = {
      "nomFournisseur": nomController.text.trim(),
      "quantitee": int.parse(quantiteController.text.trim()),
      "puzzle_id": int.parse(puzzleController.text.trim()),
      "date": dateController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      setState(() => isLoading = false);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ajout réussi 👍")),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: const Text("Ajouter Approvisionnement"),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: accent),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2C1810),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Nom fournisseur",
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Champ requis" : null,
            ),

            TextFormField(
              controller: quantiteController,
              decoration: const InputDecoration(
                labelText: "Quantité",
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? "Champ requis" : null,
            ),

            TextFormField(
              controller: puzzleController,
              decoration: const InputDecoration(
                labelText: "ID Puzzle",
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? "Champ requis" : null,
            ),

            TextFormField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Date (YYYY-MM-DD)",
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Champ requis" : null,
            ),

            const SizedBox(height: 30),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("AJOUTER"),
                  ),
          ],
        ),
      ),
    );
  }
}