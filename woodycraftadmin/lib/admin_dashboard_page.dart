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
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: accent),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DashboardResume>(
          future: futureResume,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: CircularProgressIndicator(color: accent),
                  ),
                ],
              );
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
                    int crossAxisCount = 1;

                    if (constraints.maxWidth >= 900) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth >= 600) {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.45,
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
                          value:
                              '${resume.chiffreAffaireMois.toStringAsFixed(2)} €',
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
        gradient: const LinearGradient(
          colors: [accent, accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.dashboard_customize_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 14),
          Text(
            'Dashboard administrateur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vue centralisée des commandes en attente, des niveaux de stock bas et des statistiques de ventes.',
            style: TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: danger),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Impossible de charger le dashboard',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(
              color: textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Route attendue : /api/dashboard/resume',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}