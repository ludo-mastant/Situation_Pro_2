import 'package:flutter/material.dart';
import 'admin_dashboard_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<DashboardResume> futureResume;

  static const Color bg = Color(0xFFF5F0E8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF8B6F47);
  static const Color accentLight = Color(0xFFD4B896);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textGrey = Color(0xFF9E8B7A);
  static const Color success = Color(0xFF6B9E6B);
  static const Color warning = Color(0xFFD4874E);
  static const Color danger = Color(0xFFB85C5C);
  static const Color info = Color(0xFF6F8FB8);

  @override
  void initState() {
    super.initState();
    futureResume = AdminDashboardService().fetchResume();
  }

  Future<void> _refresh() async {
    setState(() {
      futureResume = AdminDashboardService().fetchResume();
    });
    try {
      await futureResume;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: accent),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DashboardResume>(
          future: futureResume,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: accent));
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildErrorCard(snapshot.error.toString()),
                ],
              );
            }

            final resume = snapshot.data!;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeroCard(),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          icon: Icons.shopping_cart_checkout_rounded,
                          title: 'Commandes en attente',
                          value: '${resume.commandesEnAttente}',
                          subtitle: 'À traiter',
                          color: warning,
                        ),
                        _buildStatCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Stock bas',
                          value: '${resume.puzzlesStockBas}',
                          subtitle: 'Produits à surveiller',
                          color: danger,
                        ),
                        _buildStatCard(
                          icon: Icons.payments_rounded,
                          title: 'Chiffre du mois',
                          value: '${resume.chiffreAffaireMois.toStringAsFixed(2)} €',
                          subtitle: 'Ventes mensuelles',
                          color: success,
                        ),
                        _buildStatCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Clients',
                          value: '${resume.totalClients}',
                          subtitle: 'Total enregistrés',
                          color: info,
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [accent, accentLight]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 34),
          SizedBox(height: 14),
          Text('Dashboard administrateur', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Vue centralisée de votre activité WoodyCraft.', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: danger)),
      child: Text("Erreur API : $error", style: const TextStyle(color: danger)),
    );
  }
}