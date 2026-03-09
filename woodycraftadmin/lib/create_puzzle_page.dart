import 'package:flutter/material.dart';
import 'puzzle_service.dart'; // Importer PuzzleService

class CreatePuzzlePage extends StatefulWidget {
  @override
  _CreatePuzzlePageState createState() => _CreatePuzzlePageState();
}

class _CreatePuzzlePageState extends State<CreatePuzzlePage> {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _description = '';
  String _image = ''; // Champ pour l'image
  double _prix = 0.0; // Champ pour le prix
  String _categorie = ''; // Champ pour la catégorie

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nom = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL (optionnelle)'),
                onSaved: (value) {
                  _image = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
                onSaved: (value) {
                  _prix = double.tryParse(value!) ?? 0.0; // Conversion en double
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une catégorie';
                  }
                  return null;
                },
                onSaved: (value) {
                  _categorie = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      PuzzleService().createPuzzle(_nom, _description, _image, _prix, _categorie)
        .then((puzzle) {
          // Succès: Retourner à la page précédente
          Navigator.pop(context, true);
        })
        .catchError((error) {
          // Affiche le message d'erreur dans la console
          print('Erreur lors de la création du puzzle: $error');

          // Afficher une notification à l'utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la création du puzzle')),
          );
        });
    }
  },
  child: Text('Créer'),
),

             
            ],
          ),
        ),
      ),
    );
  }
}
