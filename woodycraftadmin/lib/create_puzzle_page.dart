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

  late final TextEditingController _nomController;
  late final TextEditingController _categorieIdController; // ✅ AJOUT
  late final TextEditingController _prixController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _stockController;

  bool get _isEdit => widget.puzzle != null;

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.puzzle?.nom ?? '');
    _categorieIdController = TextEditingController(
      text: widget.puzzle?.categorieId.toString() ?? '',
    ); // ✅ AJOUT
    _prixController =
        TextEditingController(text: widget.puzzle?.prix.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.puzzle?.description ?? '');
    _imageController =
        TextEditingController(text: widget.puzzle?.image ?? '');
    _stockController =
        TextEditingController(text: widget.puzzle?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _categorieIdController.dispose(); // ✅ AJOUT
    _prixController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = PuzzleService();

    final categorieId =
        int.parse(_categorieIdController.text.trim()); // ✅ FIX

    // ✅ sécurité FK
    if (categorieId < 1 || categorieId > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catégorie invalide (1 à 5)')),
      );
      return;
    }

    final data = {
      "nom": _nomController.text.trim(),
      "categorie_id": categorieId, // ✅ FIX IMPORTANT
      "prix": double.parse(
          _prixController.text.trim().replaceAll(',', '.')),
      "description": _descriptionController.text.trim(),
      "image": _imageController.text.trim().isEmpty
          ? "default.jpg"
          : _imageController.text.trim(),
      "stock": int.parse(_stockController.text.trim()),
    };

    if (_isEdit) {
      await service.updatePuzzle(widget.puzzle!.id, data);
    } else {
      await service.createPuzzle(data);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteOrClear() async {
    if (!_isEdit) {
      _nomController.clear();
      _categorieIdController.clear(); // ✅ FIX
      _prixController.clear();
      _descriptionController.clear();
      _imageController.clear();
      _stockController.clear();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Supprimer ce puzzle ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      await PuzzleService().deletePuzzle(widget.puzzle!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier' : 'Ajouter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    v!.isEmpty ? 'Champ obligatoire' : null,
              ),

              TextFormField(
                controller: _categorieIdController,
                decoration:
                    const InputDecoration(labelText: 'Catégorie ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une catégorie';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    double.tryParse(v!.replaceAll(',', '.')) == null
                        ? 'Prix invalide'
                        : null,
              ),

              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                    v!.isEmpty ? 'Champ obligatoire' : null,
              ),

              TextFormField(
                controller: _imageController,
                decoration:
                    const InputDecoration(labelText: 'Image'),
              ),

              TextFormField(
                controller: _stockController,
                decoration:
                    const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v!) == null ? 'Nombre invalide' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _save,
                child: Text(_isEdit ? 'Modifier' : 'Créer'),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),

              TextButton(
                onPressed: _deleteOrClear,
                child: Text(_isEdit ? 'Supprimer' : 'Vider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}