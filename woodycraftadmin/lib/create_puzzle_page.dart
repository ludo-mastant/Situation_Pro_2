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
  late final TextEditingController _categorieIdController;
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
      text: widget.puzzle != null ? widget.puzzle!.categorieId.toString() : '',
    );
    _prixController = TextEditingController(
      text: widget.puzzle != null ? widget.puzzle!.prix.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: widget.puzzle?.description ?? '',
    );
    _imageController = TextEditingController(text: widget.puzzle?.image ?? '');
    _stockController = TextEditingController(
      text: widget.puzzle != null ? widget.puzzle!.stock.toString() : '',
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _categorieIdController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = PuzzleService();

    final nom = _nomController.text.trim();
    final categorieId = int.parse(_categorieIdController.text.trim());
    final prix = double.parse(_prixController.text.trim().replaceAll(',', '.'));
    final description = _descriptionController.text.trim();
    final image = _imageController.text.trim();
    final stock = int.parse(_stockController.text.trim());

    if (_isEdit) {
      await service.updatePuzzle(
        id: widget.puzzle!.id,
        nom: nom,
        description: description,
        image: image,
        prix: prix,
        categorieId: categorieId,
        stock: stock,
      );
    } else {
      await service.createPuzzle(
        nom: nom,
        description: description,
        image: image,
        prix: prix,
        categorieId: categorieId,
        stock: stock,
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteOrClear() async {
    if (!_isEdit) {
      _nomController.clear();
      _categorieIdController.clear();
      _prixController.clear();
      _descriptionController.clear();
      _imageController.clear();
      _stockController.clear();
      setState(() {});
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Supprimer ce puzzle ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
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
        title: Text(_isEdit ? 'Modifier un puzzle' : 'Ajouter un puzzle'),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categorieIdController,
                decoration: const InputDecoration(labelText: 'Catégorie ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une catégorie';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Veuillez entrer un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image'),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un stock';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Veuillez entrer un nombre';
                  }
                  return null;
                },
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