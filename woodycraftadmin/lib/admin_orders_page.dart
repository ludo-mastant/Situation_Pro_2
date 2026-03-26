import 'package:flutter/material.dart';
import 'commandes_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late Future<List<Commande>> futureCommandes;
  
  // Couleurs WoodyCraft
  final Color bg = const Color(0xFFF5F0E8);
  final Color accent = const Color(0xFF8B6F47);
  final Color danger = const Color(0xFFB85C5C);
  final Color success = const Color(0xFF6B9E6B);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      futureCommandes = CommandesService().fetchCommandes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Gestion Commandes", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh, color: accent)),
        ],
      ),
      body: FutureBuilder<List<Commande>>(
        future: futureCommandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          
          final commandes = snapshot.data ?? [];
          if (commandes.isEmpty) {
            return const Center(child: Text("Aucune commande trouvée."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commandes.length,
            itemBuilder: (context, index) => _buildOrderCard(commandes[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Commande cmd) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.shopping_bag_outlined, color: accent),
        title: Text("Commande #${cmd.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Statut: ${cmd.statut.toUpperCase()} • Total: ${cmd.total}€"),
        children: [
          const Divider(),
          ...cmd.items.map((item) => ListTile(
            dense: true,
            title: Text(item.nom),
            subtitle: Text("${item.prix}€"),
            trailing: Text("x${item.quantite}", style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Supprimer
                TextButton.icon(
                  onPressed: () async {
                    await CommandesService().supprimerCommande(cmd.id);
                    _refresh();
                  },
                  icon: Icon(Icons.delete_outline, color: danger, size: 18),
                  label: Text("Supprimer", style: TextStyle(color: danger)),
                ),
                // Actions de statut
                Row(
                  children: [
                    if (cmd.statut == 'en cours') 
                      ElevatedButton(
                        onPressed: () async {
                          await CommandesService().validerCommande(cmd.id);
                          _refresh();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: success),
                        child: const Text("VALIDER"),
                      ),
                    if (cmd.statut == 'validé')
                      ElevatedButton(
                        onPressed: () async {
                          await CommandesService().expedierCommande(cmd.id);
                          _refresh();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: accent),
                        child: const Text("EXPÉDIER"),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}