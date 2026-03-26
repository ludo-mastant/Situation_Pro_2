import 'package:flutter/material.dart';
import 'puzzle_service.dart';
import 'create_puzzle_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future<List<Puzzle>> futurePuzzles;

  // Palette de couleurs WoodyCraft
  static const Color bg = Color(0xFFF5F0E8);
  static const Color accent = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);
  static const Color danger = Color(0xFFB85C5C); // Rouge pour la suppression

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      futurePuzzles = PuzzleService().fetchPuzzles();
    });
  }

  // --- NOUVELLE FONCTION POUR SUPPRIMER ---
  void _confirmDelete(Puzzle puzzle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le puzzle ?"),
        content: Text("Voulez-vous vraiment retirer '${puzzle.nom}' du catalogue ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await PuzzleService().deletePuzzle(puzzle.id);
                Navigator.pop(context); // Ferme la boîte de dialogue
                _refresh(); // Actualise la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Puzzle supprimé avec succès")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur lors de la suppression : $e")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Catalogue Puzzles', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: accent)),
        ],
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accent));
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          final puzzles = snapshot.data ?? [];
          if (puzzles.isEmpty) return const Center(child: Text("Aucun puzzle trouvé."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: puzzles.length,
            itemBuilder: (context, index) => _buildPuzzleCard(puzzles[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePuzzlePage()));
          if (res == true) _refresh();
        },
      ),
    );
  }

  Widget _buildPuzzleCard(Puzzle puzzle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () async {
          // Permet de modifier en cliquant sur la ligne
          final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePuzzlePage(puzzle: puzzle)));
          if (res == true) _refresh();
        },
        leading: const Icon(Icons.extension_rounded, color: accent),
        title: Text(puzzle.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${puzzle.prix}€ • Stock: ${puzzle.stock}"),
        // --- BOUTON DE SUPPRESSION AJOUTÉ ICI ---
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: danger),
          onPressed: () => _confirmDelete(puzzle),
        ),
      ),
    );
  }
}