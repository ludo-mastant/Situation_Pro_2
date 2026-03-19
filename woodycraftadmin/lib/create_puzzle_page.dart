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

  bool _isLoading = false;

  bool get _isEdit => widget.puzzle != null;

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.puzzle?.nom ?? '');
    _categorieIdController = TextEditingController(
      text: widget.puzzle?.categorieId.toString() ?? '',
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String nom = _nomController.text.trim();
    final int categorieId = int.parse(_categorieIdController.text.trim());
    final double prix =
        double.parse(_prixController.text.trim().replaceAll(',', '.'));
    final String description = _descriptionController.text.trim();
    final String image = _imageController.text.trim();
    final int stock = int.parse(_stockController.text.trim());

    try {
      if (_isEdit) {
        await PuzzleService().updatePuzzle(
          id: widget.puzzle!.id,
          nom: nom,
          description: description,
          image: image,
          prix: prix,
          categorieId: categorieId,
          stock: stock,
        );
      } else {
        await PuzzleService().createPuzzle(
          nom: nom,
          description: description,
          image: image,
          prix: prix,
          categorieId: categorieId,
          stock: stock,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Puzzle modifié avec succès'
                : 'Puzzle ajouté avec succès',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteOrClear() async {
    final bool confirm = await _showConfirmDialog(
          title: _isEdit ? 'Confirmer ?' : 'Vider ?',
          message: _isEdit
              ? 'Confirmer la suppression ?'
              : 'Vider le formulaire ?',
          confirmText: _isEdit ? 'SUPPRIMER' : 'VIDER',
        ) ??
        false;

    if (!confirm) return;

    if (_isEdit) {
      setState(() {
        _isLoading = true;
      });

      try {
        await PuzzleService().deletePuzzle(widget.puzzle!.id);

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
            _isLoading = false;
          });
        }
      }
    } else {
      _nomController.clear();
      _categorieIdController.clear();
      _prixController.clear();
      _descriptionController.clear();
      _imageController.clear();
      _stockController.clear();
      setState(() {});
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    final String image = _imageController.text.trim();

    return Container(
      width: 90,
      height: 80,
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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color yellowCard = Color(0xFFF1DF7A);
    const Color greenBtn = Color(0xFF59C36A);
    const Color oliveBtn = Color(0xFF7A7750);
    const Color redBtn = Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier un puzzle' : 'Ajouter un puzzle'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: yellowCard,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: _decoration('Nom'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categorieIdController,
                    decoration: _decoration('Catégorie (ID)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un ID catégorie';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Veuillez entrer un nombre entier';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _prixController,
                    decoration: _decoration('Prix'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un prix';
                      }
                      if (double.tryParse(value.trim().replaceAll(',', '.')) ==
                          null) {
                        return 'Veuillez entrer un prix valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _decoration('Description'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imageController,
                    decoration: _decoration('Image'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  _buildImagePreview(),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _stockController,
                    decoration: _decoration('Stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer le stock';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Veuillez entrer un nombre entier';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenBtn,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isEdit ? 'MODIFIER' : 'CRÉER'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oliveBtn,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('ANNULER'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleDeleteOrClear,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redBtn,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_isEdit ? 'SUPPRIMER' : 'VIDER'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}