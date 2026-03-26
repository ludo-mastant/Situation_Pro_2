import 'package:flutter/material.dart';
import 'puzzle_service.dart';
import 'create_puzzle_page.dart';
import 'commandes_service.dart';

class PuzzleListPage extends StatefulWidget {
  @override
  _PuzzleListPageState createState() => _PuzzleListPageState();
}

class _PuzzleListPageState extends State<PuzzleListPage> {
  late Future<List<Puzzle>> futurePuzzles;
  late Future<List<Commande>> futureCommandes;
  int _selectedIndex = 0;

  void _itemClique(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    futurePuzzles = PuzzleService().fetchPuzzles();
    futureCommandes = CommandesService().fetchCommandes();
  }

  void _rafraichirCommandes() {
    setState(() {
      futureCommandes = CommandesService().fetchCommandes();
    });
  }

  // Affiche un badge coloré selon le statut
  Widget _statutBadge(String statut) {
    Color couleur;
    IconData icone;

    switch (statut.toLowerCase()) {
      case 'validé':
      case 'valide':
        couleur = Colors.green;
        icone = Icons.check_circle;
        break;
      case 'expédiée':
      case 'expediee':
      case 'checkout':
        couleur = Colors.blue;
        icone = Icons.local_shipping;
        break;
      case 'en attente':
      default:
        couleur = Colors.orange;
        icone = Icons.hourglass_empty;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: couleur, size: 16),
        SizedBox(width: 4),
        Text(
          statut.isEmpty ? 'En attente' : statut,
          style: TextStyle(color: couleur, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Ouvre la boite de dialogue pour changer le statut
  void _afficherMenuStatut(BuildContext context, Commande commande) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commande #${commande.id}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Statut actuel : ${commande.statut.isEmpty ? "En attente" : commande.statut}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Divider(height: 24),

              // Bouton Valider
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Marquer comme Validée'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await CommandesService().validerCommande(commande.id);
                    _rafraichirCommandes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Commande #${commande.id} validée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              // Bouton Expédier
              ListTile(
                leading: Icon(Icons.local_shipping, color: Colors.blue),
                title: Text('Marquer comme Expédiée'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await CommandesService().expedierCommande(commande.id);
                    _rafraichirCommandes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Commande #${commande.id} expédiée'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              Divider(),

              // Bouton Supprimer
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer la commande',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmerSuppression(context, commande);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Demande confirmation avant suppression
  void _confirmerSuppression(BuildContext context, Commande commande) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer la commande'),
        content: Text(
            'Voulez-vous vraiment supprimer la commande #${commande.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await CommandesService().supprimerCommande(commande.id);
                _rafraichirCommandes();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Commande #${commande.id} supprimée'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleList() {
    return FutureBuilder<List<Puzzle>>(
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
    );
  }

  Widget _buildCommandeList() {
    return FutureBuilder<List<Commande>>(
      future: futureCommandes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          final commandes = snapshot.data!;
          if (commandes.isEmpty) {
            return Center(child: Text('Aucune commande trouvée'));
          }
          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.blue),
                  title: Text(
                    'Commande #${commande.id}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _statutBadge(commande.statut),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${commande.total.toStringAsFixed(2)} €',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.edit, color: Colors.grey),
                    ],
                  ),
                  onTap: () => _afficherMenuStatut(context, commande),
                ),
              );
            },
          );
        }
      },
    );
  }

  String get _titre {
    switch (_selectedIndex) {
      case 1:
        return 'Gestion catalogue';
      case 2:
        return 'Gestion commandes';
      default:
        return 'Accueil';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titre),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Catalogue',
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Center(child: Text('Bienvenue sur la page d\'accueil')),
          _buildPuzzleList(),
          _buildCommandeList(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePuzzlePage()),
                ).then((value) {
                  if (value == true) {
                    setState(() {
                      futurePuzzles = PuzzleService().fetchPuzzles();
                    });
                  }
                });
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
