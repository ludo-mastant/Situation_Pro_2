import 'package:flutter/material.dart';
import 'commandes_service.dart';

class OrderDetailPage extends StatefulWidget {
  final int commandeId;
  const OrderDetailPage({super.key, required this.commandeId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static const Color bg       = Color(0xFFFFE8CC);
  static const Color card     = Color(0xFFFFFFFF);
  static const Color accent   = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textGrey = Color(0xFF9E8B7A);
  static const Color success  = Color(0xFF6B9E6B);
  static const Color warning  = Color(0xFFD4874E);
  static const Color danger   = Color(0xFFB85C5C);

  late Future<Commande> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = CommandesService().fetchCommandeDetail(widget.commandeId);
  }

  Color _statutColor(String s) {
    switch (s.toLowerCase()) {
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

  IconData _statutIcon(String s) {
    switch (s.toLowerCase()) {
      case 'validé':
      case 'valide':
        return Icons.check_circle_rounded;
      case 'expédié':
      case 'expedie':
        return Icons.local_shipping_rounded;
      case 'annulé':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  /// Formate "2025-10-09T07:38:39.000000Z" → "09/10/2025 à 07:38"
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$d/$mo/${dt.year} à $h:$mi';
    } catch (_) {
      return raw;
    }
  }

  String _modePaiementLabel(String? raw) {
    if (raw == null) return '—';
    switch (raw.toLowerCase()) {
      case 'cheque':
      case 'chèque':
        return '🧾 Chèque';
      case 'carte':
      case 'cb':
        return '💳 Carte bancaire';
      case 'especes':
      case 'espèces':
        return '💵 Espèces';
      case 'virement':
        return '🏦 Virement';
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: accent),
        title: Text(
          'Commande #${widget.commandeId}',
          style: const TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<Commande>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: accent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: danger, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger le détail\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: danger),
                    ),
                  ],
                ),
              ),
            );
          }

          final cmd = snapshot.data!;
          final statColor = _statutColor(cmd.statut);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Bannière statut ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [accent, Color(0xFFD4B896)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(_statutIcon(cmd.statut),
                          color: Colors.white, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Commande #${cmd.id}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cmd.statut.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text('${cmd.total.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Infos générales ────────────────────────────────────────
                _sectionTitle('Informations commande'),
                _infoCard([
                  _infoRow(Icons.calendar_today_rounded, 'Date',
                      _formatDate(cmd.dateCommande)),
                  _divider(),
                  _infoRow(Icons.payment_rounded, 'Paiement',
                      _modePaiementLabel(cmd.modePaiement)),
                  _divider(),
                  _infoRow(Icons.shopping_bag_outlined, 'Articles',
                      '${cmd.nbArticles} article(s)'),
                ]),

                const SizedBox(height: 16),

                // ── Client ─────────────────────────────────────────────────
                if (cmd.client != null) ...[
                  _sectionTitle('Client'),
                  _infoCard([
                    _infoRow(Icons.person_rounded, 'Nom',
                        cmd.client!.nom ?? '—'),
                    _divider(),
                    _infoRow(Icons.email_rounded, 'Email',
                        cmd.client!.email ?? '—'),
                    if (cmd.client!.telephone != null) ...[
                      _divider(),
                      _infoRow(Icons.phone_rounded, 'Téléphone',
                          cmd.client!.telephone!),
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],

                // ── Adresse livraison ──────────────────────────────────────
                if (cmd.adresseLivraison != null) ...[
                  _sectionTitle('Adresse de livraison'),
                  _infoCard([
                    _infoRow(Icons.home_rounded, 'Rue',
                        cmd.adresseLivraison!.rue ?? '—'),
                    _divider(),
                    _infoRow(Icons.location_city_rounded, 'Ville',
                        '${cmd.adresseLivraison!.codePostal ?? ''} ${cmd.adresseLivraison!.ville ?? ''}'.trim()),
                    _divider(),
                    _infoRow(Icons.public_rounded, 'Pays',
                        cmd.adresseLivraison!.pays ?? '—'),
                  ]),
                  const SizedBox(height: 16),
                ],

                // ── Articles ───────────────────────────────────────────────
                _sectionTitle('Articles commandés'),
                cmd.items.isEmpty
                    ? _emptyArticles()
                    : _articlesCard(cmd.items),

                const SizedBox(height: 16),

                // ── Total récap ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textDark)),
                      Text('${cmd.total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: accent)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textDark)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Text('$label :',
                style: const TextStyle(color: textGrey, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _emptyArticles() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined,
                color: textGrey.withOpacity(0.5), size: 40),
            const SizedBox(height: 10),
            const Text('Aucun article enregistré pour cette commande.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textGrey, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Le total (${_totalFromParent()}) provient du champ API.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textGrey, fontSize: 11)),
          ],
        ),
      );

  // dummy — remplacé dynamiquement via le FutureBuilder ci-dessus
  String _totalFromParent() => '';

  Widget _articlesCard(List<CommandeItem> items) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.extension_rounded,
                            color: accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                    fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(
                                'Qté : ${item.quantite}  •  ${item.prix.toStringAsFixed(2)} €/u',
                                style: const TextStyle(
                                    color: textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${item.sousTotal.toStringAsFixed(2)} €',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accent,
                              fontSize: 15)),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: 72),
              ],
            );
          }).toList(),
        ),
      );
}