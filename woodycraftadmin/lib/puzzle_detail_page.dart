import 'package:flutter/material.dart';
import 'puzzle_service.dart';
import 'create_puzzle_page.dart';

class PuzzleDetailPage extends StatelessWidget {
  final Puzzle puzzle;
  const PuzzleDetailPage({super.key, required this.puzzle});

  static const Color bg = Color(0xFFF5F0E8);
  static const Color accent = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: Text("Voulez-vous vraiment retirer '${puzzle.nom}' du catalogue ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await PuzzleService().deletePuzzle(puzzle.id);
              Navigator.pop(ctx); // Ferme le dialog
              Navigator.pop(context, true); // Retourne à la liste avec succès
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: textDark)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: accent.withOpacity(0.1),
              child: const Icon(Icons.image_not_supported_outlined, size: 80, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(puzzle.nom, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark))),
                      Text("${puzzle.prix} €", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: accent)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Chip(label: Text("Catégorie ${puzzle.categorieId}"), backgroundColor: accent.withOpacity(0.1)),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(puzzle.description, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 30),
                  Text("Stock disponible : ${puzzle.stock} unités", style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final res = await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CreatePuzzlePage(puzzle: puzzle))
                            );
                            if (res == true) Navigator.pop(context, true);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("MODIFIER"),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), foregroundColor: accent, side: const BorderSide(color: accent)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        padding: const EdgeInsets.all(16),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}