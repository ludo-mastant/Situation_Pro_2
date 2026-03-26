import 'api_service.dart';

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(
        (value?.toString() ?? '').replaceAll(',', '.'),
      ) ??
      0.0;
}

class DashboardResume {
  final int commandesEnAttente;
  final int puzzlesStockBas;
  final double chiffreAffaireMois;
  final int totalClients;

  const DashboardResume({
    required this.commandesEnAttente,
    required this.puzzlesStockBas,
    required this.chiffreAffaireMois,
    required this.totalClients,
  });

  factory DashboardResume.fromJson(Map<String, dynamic> json) {
    return DashboardResume(
      commandesEnAttente: _toInt(
        json['commandes_en_attente'] ?? json['commandesEnAttente'],
      ),
      puzzlesStockBas: _toInt(
        json['puzzles_stock_bas'] ??
            json['puzzlesStockBas'] ??
            json['stock_bas'],
      ),
      chiffreAffaireMois: _toDouble(
        json['chiffre_affaire_mois'] ??
            json['chiffreAffaireMois'] ??
            json['ventes_mois'],
      ),
      totalClients: _toInt(
        json['total_clients'] ??
            json['totalClients'] ??
            json['nombre_clients'],
      ),
    );
  }
}

class AdminDashboardService {
  Future<DashboardResume> fetchResume() async {
    final data = await ApiService.get('dashboard/resume');

    if (data is Map<String, dynamic>) {
      return DashboardResume.fromJson(data);
    }

    throw Exception('Format JSON invalide pour le dashboard');
  }
}