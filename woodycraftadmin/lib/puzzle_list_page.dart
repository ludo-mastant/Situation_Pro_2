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
  late Future<List<Puzzle>> futurePuzzles;
  int _selectedIndex = 1;
  String _affichage = 'Gestion catalogue';

  @override
  void initState() {
    super.initState();
    futurePuzzles = PuzzleService().fetchPuzzles();
  }

  void _reloadPuzzles() {
    setState(() {
      futurePuzzles = PuzzleService().fetchPuzzles();
    });
  }

  void _itemClique(int index) {
    setState(() {
      _selectedIndex = index;

      switch (_selectedIndex) {
        case 0:
          _affichage = 'Accueil';
          break;
        case 1:
          _affichage = 'Gestion catalogue';
          break;
        case 2:
          _affichage = 'Gestion commandes';
          break;
      }
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
      _reloadPuzzles();
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
      _reloadPuzzles();
    }
  }

  Widget _buildImageThumb(String image) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: image.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, color: Colors.white70);
                },
              ),
            )
          : const Icon(Icons.image, color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_affichage),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _itemClique,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Commandes',
          ),
        ],
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: futurePuzzles,
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
              child: Text('Aucun puzzle trouvé'),
            );
          }

          return ListView.builder(
            itemCount: puzzles.length,
            itemBuilder: (context, index) {
              final puzzle = puzzles[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: _buildImageThumb(puzzle.image),
                  title: Text(
                    puzzle.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(puzzle.description),
                        const SizedBox(height: 6),
                        Text('Prix : ${puzzle.prix.toStringAsFixed(2)} €'),
                        Text('Catégorie : ${puzzle.categorieId}'),
                        Text('Stock : ${puzzle.stock}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDetailPage(puzzle),
                ),
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