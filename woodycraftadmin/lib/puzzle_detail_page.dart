import 'package:flutter/material.dart';
import 'create_puzzle_page.dart';
import 'puzzle_service.dart';

class PuzzleDetailPage extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleDetailPage({super.key, required this.puzzle});

  @override
  State<PuzzleDetailPage> createState() => _PuzzleDetailPageState();
}

class _PuzzleDetailPageState extends State<PuzzleDetailPage> {
  // ── Palette ────────────────────────────────────────────────
  static const Color bg       = Color(0xFFF5F0E8);
  static const Color card     = Color(0xFFFFFFFF);
  static const Color accent   = Color(0xFF8B6F47);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textGrey = Color(0xFF9E8B7A);
  static const Color success  = Color(0xFF6B9E6B);
  static const Color warning  = Color(0xFFD4874E);
  static const Color danger   = Color(0xFFB85C5C);

  Future<void> _editPuzzle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePuzzlePage(puzzle: widget.puzzle),
      ),
    );
    if (!mounted) return;
    if (result == true) Navigator.pop(context, true);
  }

  Future<void> _deletePuzzle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation',
            style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: const Text('Supprimer ce puzzle ?',
            style: TextStyle(color: textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Annuler', style: TextStyle(color: accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Supprimer', style: TextStyle(color: danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PuzzleService().deletePuzzle(widget.puzzle.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Color _stockColor(int stock) {
    if (stock <= 0) return danger;
    if (stock <= 5) return warning;
    return success;
  }

  String _stockLabel(int stock) {
    if (stock <= 0) return 'RUPTURE';
    if (stock <= 5) return 'STOCK BAS';
    return 'En stock';
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.puzzle;
    final stockColor = _stockColor(puzzle.stock);
    final stockLabel = _stockLabel(puzzle.stock);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détail du puzzle',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // ── Carte principale ──────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône + nom
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: accent.withOpacity(0.2)),
                        ),
                        child: Icon(Icons.extension_rounded,
                            color: accent.withOpacity(0.7), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          puzzle.nom,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEDE8DE)),
                  const SizedBox(height: 16),
                  // Infos
                  _buildInfoRow(
                      Icons.euro_rounded, 'Prix',
                      '${puzzle.prix.toStringAsFixed(2)} €'),
                  _buildInfoRow(
                      Icons.category_rounded, 'Catégorie',
                      'ID ${puzzle.categorieId}'),
                  _buildInfoRow(
                      Icons.inventory_2_rounded, 'Stock',
                      '${puzzle.stock} unités'),
                  _buildInfoRow(
                      Icons.image_rounded, 'Image',
                      puzzle.image.isEmpty ? 'default.jpg' : puzzle.image),
                  const SizedBox(height: 8),
                  // Badge stock
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: stockColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      stockLabel,
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Carte description ─────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    puzzle.description.isEmpty
                        ? 'Aucune description'
                        : puzzle.description,
                    style: const TextStyle(
                        color: textDark, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Boutons ───────────────────────────────────
            ElevatedButton.icon(
              onPressed: _editPuzzle,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Modifier ce puzzle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _deletePuzzle,
              icon: const Icon(Icons.delete_rounded, color: danger),
              label: const Text('Supprimer',
                  style: TextStyle(
                      color: danger, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: danger.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 10),
          Text('$label : ',
              style: const TextStyle(
                  color: textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}