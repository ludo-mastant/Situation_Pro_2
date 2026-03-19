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
  bool _isDeleting = false;

  Future<void> _openEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePuzzlePage(puzzle: widget.puzzle),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deletePuzzle() async {
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer ?'),
            content: const Text('Confirmer la suppression ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ANNULER'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SUPPRIMER'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await PuzzleService().deletePuzzle(widget.puzzle.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle supprimé')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Widget _buildImageBox(String image) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: image.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
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
    const Color yellowCard = Color(0xFFF1DF7A);
    const Color blueBtn = Color(0xFF216BFF);
    const Color oliveBtn = Color(0xFF7A7750);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du puzzle'),
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _deletePuzzle,
            icon: _isDeleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: yellowCard,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageBox(widget.puzzle.image),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.puzzle.nom.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PRIX : ${widget.puzzle.prix.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'STOCK : ${widget.puzzle.stock}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CATÉGORIE : ${widget.puzzle.categorieId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DESCRIPTION : ${widget.puzzle.description}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _openEditPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueBtn,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('MODIFIER'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: oliveBtn,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ANNULER'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}