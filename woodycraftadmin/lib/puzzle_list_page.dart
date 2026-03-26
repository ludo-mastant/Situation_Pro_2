import 'stocks.dart';
import 'package:flutter/material.dart';
import 'puzzle_service.dart'; // Importer PuzzleService
import 'create_puzzle_page.dart'; // Importer CreatePuzzlePage

class PuzzleListPage extends StatefulWidget {
  @override
  _PuzzleListPageState createState() => _PuzzleListPageState();
}

class _PuzzleListPageState extends State<PuzzleListPage> {
  late Future<List<Puzzle>> futurePuzzles;
  int _selectedIndex = 0;
  String _affichage = "Accueil";

  void _itemClique(int index) {
  setState(() {
    _selectedIndex = index;
  });

  // Logique de redirection selon l'index cliqué
  if (index == 1) { // 1 est l'index du bouton "Stocks"
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StocksPage()),
    );
  } else if (index == 2) {
    // Optionnel : redirection vers les commandes plus tard
    print("Page commandes demandée");
  }
}

  @override
  void initState() {
    super.initState();
    futurePuzzles = PuzzleService().fetchPuzzles(); // Appel de fetchPuzzles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion du catalogue'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Stocks',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.linear_scale),
            label: 'Commandes',
            ),
        ],
        backgroundColor: Colors.blue,
        onTap: _itemClique,
        currentIndex: _selectedIndex,
        ),
      body: FutureBuilder<List<Puzzle>>(
        future: futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            final puzzles = snapshot.data!;
            return ListView.builder(
              itemCount: puzzles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(puzzles[index].nom),
                  subtitle: Text(puzzles[index].description),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePuzzlePage()),
          ).then((value) {
            if (value == true) {
              // Rafraîchir la liste après ajout
              setState(() {
                futurePuzzles = PuzzleService().fetchPuzzles(); // Récupérer à nouveau les puzzles
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
