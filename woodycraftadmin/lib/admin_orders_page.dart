import 'package:flutter/material.dart';
import 'commandes_service.dart';
import 'order_detail_page.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late Future<List<Commande>> futureCommandes;

  // Palette WoodyCraft mise à jour
  static const Color bg      = Color(0xFFFFE8CC);
  static const Color card    = Color(0xFFFFFFFF);
  static const Color accent  = Color(0xFF8B6F47);
  static const Color danger  = Color(0xFFB85C5C);
  static const Color success = Color(0xFF6B9E6B);
  static const Color warning = Color(0xFFD4874E);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textGrey = Color(0xFF9E8B7A);

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

  Color _statutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'validé':
      case 'valide':
        return success;
      case 'expédié':
      case 'expedie':
        return accent;
      case 'annulé':
        return danger;
      default:
        return warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Gestion Commandes',
          style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        backgroundColor: card,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: accent),
          ),
        ],
      ),
      body: FutureBuilder<List<Commande>>(
        future: futureCommandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final commandes = snapshot.data ?? [];
          if (commandes.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée.'));
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
    final statutColor = _statutColor(cmd.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: card,
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statutColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.shopping_bag_outlined, color: statutColor, size: 22),
        ),
        title: Text(
          'Commande #${cmd.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statutColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cmd.statut.toUpperCase(),
                style: TextStyle(
                  color: statutColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${cmd.total.toStringAsFixed(2)} €',
              style: const TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton Détail
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(commandeId: cmd.id),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline_rounded, size: 16),
              label: const Text('Détail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: const BorderSide(color: accent),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton Supprimer
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer la commande ?'),
                    content: Text(
                        'Voulez-vous vraiment supprimer la commande #${cmd.id} ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer',
                            style: TextStyle(color: danger)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await CommandesService().supprimerCommande(cmd.id);
                  _refresh();
                }
              },
              icon: Icon(Icons.delete_outline, color: danger, size: 18),
              label: Text('Supprimer', style: TextStyle(color: danger)),
            ),
            const SizedBox(width: 8),
            // Boutons de statut
            if (cmd.statut == 'en cours')
              ElevatedButton(
                onPressed: () async {
                  await CommandesService().validerCommande(cmd.id);
                  _refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('VALIDER'),
              ),
            if (cmd.statut == 'validé' || cmd.statut == 'valide')
              ElevatedButton(
                onPressed: () async {
                  await CommandesService().expedierCommande(cmd.id);
                  _refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('EXPÉDIER'),
              ),
          ],
        ),
      ),
    );
  }
}