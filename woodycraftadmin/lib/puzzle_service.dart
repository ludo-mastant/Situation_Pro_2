class Puzzle {
  final int id;
  final String nom;
  final String description;
  final String image;
  final double prix;
  final int categorieId;
  final int stock;

  const Puzzle({
    required this.id,
    required this.nom,
    required this.description,
    required this.image,
    required this.prix,
    required this.categorieId,
    required this.stock,
  });

  Puzzle copyWith({
    int? id,
    String? nom,
    String? description,
    String? image,
    double? prix,
    int? categorieId,
    int? stock,
  }) {
    return Puzzle(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      image: image ?? this.image,
      prix: prix ?? this.prix,
      categorieId: categorieId ?? this.categorieId,
      stock: stock ?? this.stock,
    );
  }
}

class PuzzleService {
  static final List<Puzzle> _puzzles = [
    const Puzzle(
      id: 1,
      nom: 'Puzzle 3D Avancé',
      description: 'Puzzle en 3D complexe',
      image: '',
      prix: 29.99,
      categorieId: 2,
      stock: 10,
    ),
    const Puzzle(
      id: 2,
      nom: 'Casse-tête en bois',
      description: 'Un casse-tête classique en bois',
      image: '',
      prix: 15.50,
      categorieId: 3,
      stock: 5,
    ),
    const Puzzle(
      id: 3,
      nom: 'Puzzle enfant',
      description: 'Puzzle facile pour enfant',
      image: '',
      prix: 9.99,
      categorieId: 4,
      stock: 8,
    ),
  ];

  static int _nextId = 4;

  Future<List<Puzzle>> fetchPuzzles() async {
    return List<Puzzle>.from(_puzzles);
  }

  Future<void> createPuzzle({
    required String nom,
    required String description,
    required String image,
    required double prix,
    required int categorieId,
    required int stock,
  }) async {
    final puzzle = Puzzle(
      id: _nextId++,
      nom: nom,
      description: description,
      image: image,
      prix: prix,
      categorieId: categorieId,
      stock: stock,
    );

    _puzzles.add(puzzle);
  }

  Future<void> updatePuzzle({
    required int id,
    required String nom,
    required String description,
    required String image,
    required double prix,
    required int categorieId,
    required int stock,
  }) async {
    final index = _puzzles.indexWhere((p) => p.id == id);

    if (index == -1) return;

    _puzzles[index] = _puzzles[index].copyWith(
      nom: nom,
      description: description,
      image: image,
      prix: prix,
      categorieId: categorieId,
      stock: stock,
    );
  }

  Future<void> deletePuzzle(int id) async {
    _puzzles.removeWhere((p) => p.id == id);
  }
}