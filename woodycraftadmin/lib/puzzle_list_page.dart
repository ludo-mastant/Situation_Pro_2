import 'package:flutter/material.dart';
import 'puzzle_service.dart';
import 'puzzle_detail_page.dart';
import 'create_puzzle_page.dart';

class PuzzleListPage extends StatefulWidget {
  const PuzzleListPage({super.key});

  @override
  State<PuzzleListPage> createState() => _PuzzleListPageState();
}

class _PuzzleListPageState extends State<PuzzleListPage> {
  late Future<List<Puzzle>> _futurePuzzles;

  // Palette WoodyCraft
  static const Color bg = Color(0xFFF5F0E8);
  static const Color accent = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futurePuzzles = PuzzleService().fetchPuzzles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Catalogue WoodyCraft', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: accent),
            onPressed: _refresh,
          )
        ],
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: _futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final puzzles = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: puzzles.length,
            itemBuilder: (context, index) {
              final puzzle = puzzles[index];
              return InkWell(
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PuzzleDetailPage(puzzle: puzzle)),
                  );
                  if (res == true) _refresh();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          child: const Center(child: Icon(Icons.extension, size: 40, color: accent)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(puzzle.nom, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                            const SizedBox(height: 4),
                            Text("${puzzle.prix}€", style: const TextStyle(color: accent, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePuzzlePage()));
          if (res == true) _refresh();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}