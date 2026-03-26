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

  // Palette beige admin
  static const Color bg        = Color(0xFFF5F0E8);
  static const Color card      = Color(0xFFFFFFFF);
  static const Color accent    = Color(0xFF8B6F47);
  static const Color textDark  = Color(0xFF2C1810);
  static const Color textGrey  = Color(0xFF9E8B7A);
  static const Color success   = Color(0xFF6B9E6B);
  static const Color warning   = Color(0xFFD4874E);
  static const Color danger    = Color(0xFFB85C5C);

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

  void _confirmDelete(Puzzle puzzle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: Text("Voulez-vous supprimer '${puzzle.nom}' ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await PuzzleService().deletePuzzle(puzzle.id);
              Navigator.pop(context);
              _refresh();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Catalogue puzzles', style: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: accent)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Puzzle>>(
                future: futurePuzzles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: accent));
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  }
                  final puzzles = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) => _buildPuzzleCard(puzzles[index]),
                  );
                },
              ),
            ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.06), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.extension_rounded, color: accent),
        ),
        title: Text(puzzle.nom, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
        subtitle: Text("${puzzle.prix}€ • Stock: ${puzzle.stock}", style: const TextStyle(color: textGrey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: accent, size: 20),
              onPressed: () async {
                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePuzzlePage(puzzle: puzzle)));
                if (res == true) _refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: danger, size: 20),
              onPressed: () => _confirmDelete(puzzle),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de structure (Header & Stats) ---
  Widget _buildHeader() { /* Ton code de header beige ici */ return Container(); }
  Widget _buildStatsBar() { /* Ton code de stats ici */ return Container(); }
  Widget _buildErrorState() { return const Center(child: Text("Erreur de connexion")); }
}