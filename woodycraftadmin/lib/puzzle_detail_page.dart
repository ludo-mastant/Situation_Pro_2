import 'package:flutter/material.dart';
import 'create_puzzle_page.dart';
import 'puzzle_service.dart';

class PuzzleDetailPage extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleDetailPage({super.key, required this.puzzle});

  @override
  State<PuzzleDetailPage> createState() => _PuzzleDetailPageState();
}

class _PuzzleDetailPageState extends State<PuzzleDetailPage> {
  Future<void> _editPuzzle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePuzzlePage(puzzle: widget.puzzle),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deletePuzzle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Supprimer ce puzzle ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await PuzzleService().deletePuzzle(widget.puzzle.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.puzzle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Nom : ${puzzle.nom}'),
            const SizedBox(height: 8),
            Text('Prix : ${puzzle.prix.toStringAsFixed(2)} €'),
            const SizedBox(height: 8),
            Text('Catégorie : ${puzzle.categorieId}'),
            const SizedBox(height: 8),
            Text('Stock : ${puzzle.stock}'),
            const SizedBox(height: 8),
            Text('Description : ${puzzle.description}'),
            const SizedBox(height: 8),
            Text('Image : ${puzzle.image.isEmpty ? 'Aucune' : puzzle.image}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editPuzzle,
              child: const Text('Modifier'),
            ),
            TextButton(
              onPressed: _deletePuzzle,
              child: const Text('Supprimer'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}