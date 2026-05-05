import 'package:flutter/material.dart';
import 'puzzle_service.dart';

class CreatePuzzlePage extends StatefulWidget {
  final Puzzle? puzzle;
  const CreatePuzzlePage({super.key, this.puzzle});

  @override
  State<CreatePuzzlePage> createState() => _CreatePuzzlePageState();
}

class _CreatePuzzlePageState extends State<CreatePuzzlePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController,
      _catController,
      _prixController,
      _descController,
      _imgController,
      _stockController;

  static const Color bg     = Color(0xFFFFE8CC);
  static const Color accent = Color(0xFF8B6F47);

  bool get _isEdit => widget.puzzle != null;

  @override
  void initState() {
    super.initState();
    _nomController   = TextEditingController(text: widget.puzzle?.nom ?? '');
    _catController   = TextEditingController(text: widget.puzzle?.categorieId.toString() ?? '1');
    _prixController  = TextEditingController(text: widget.puzzle?.prix.toString() ?? '');
    _descController  = TextEditingController(text: widget.puzzle?.description ?? '');
    _imgController   = TextEditingController(text: widget.puzzle?.image ?? '');
    _stockController = TextEditingController(text: widget.puzzle?.stock.toString() ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nom': _nomController.text,
      'categorie_id': int.parse(_catController.text),
      'prix': double.parse(_prixController.text.replaceAll(',', '.')),
      'description': _descController.text,
      'image': _imgController.text.isEmpty ? 'default.jpg' : _imgController.text,
      'stock': int.parse(_stockController.text),
    };

    try {
      if (_isEdit) {
        await PuzzleService().updatePuzzle(widget.puzzle!.id, data);
      } else {
        await PuzzleService().createPuzzle(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier Puzzle' : 'Nouveau Puzzle'),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: accent),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2C1810),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom du puzzle'),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: _catController,
              decoration: const InputDecoration(labelText: 'ID Catégorie (1-5)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _prixController,
              decoration: const InputDecoration(labelText: 'Prix (€)'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _imgController,
              decoration: const InputDecoration(labelText: "Nom de l'image"),
            ),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Quantité en stock'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(_isEdit ? 'METTRE À JOUR' : 'CRÉER LE PUZZLE'),
            ),
          ],
        ),
      ),
    );
  }
}