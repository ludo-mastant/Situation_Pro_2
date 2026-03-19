import 'package:flutter/material.dart';
import 'create_puzzle_page.dart';
import 'puzzle_detail_page.dart';
import 'puzzle_service.dart';

class PuzzleListPage extends StatefulWidget {
  const PuzzleListPage({super.key});

  @override
  State<PuzzleListPage> createState() => _PuzzleListPageState();
}

class _PuzzleListPageState extends State<PuzzleListPage> {
  late Future<List<Puzzle>> _futurePuzzles;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  void _loadPuzzles() {
    _futurePuzzles = PuzzleService().fetchPuzzles();
  }

  Future<void> _refreshPuzzles() async {
    setState(() {
      _loadPuzzles();
    });
  }

  Future<void> _openCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePuzzlePage(),
      ),
    );

    if (result == true) {
      await _refreshPuzzles();
    }
  }

  Future<void> _openDetailPage(Puzzle puzzle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleDetailPage(puzzle: puzzle),
      ),
    );

    if (result == true) {
      await _refreshPuzzles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des puzzles'),
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: _futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          final puzzles = snapshot.data ?? [];

          if (puzzles.isEmpty) {
            return const Center(
              child: Text('Aucun puzzle'),
            );
          }

          return ListView.builder(
            itemCount: puzzles.length,
            itemBuilder: (context, index) {
              final puzzle = puzzles[index];

              return ListTile(
                title: Text(puzzle.nom),
                subtitle: Text(
                  'Prix : ${puzzle.prix.toStringAsFixed(2)} € - Stock : ${puzzle.stock}',
                ),
                onTap: () => _openDetailPage(puzzle),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}