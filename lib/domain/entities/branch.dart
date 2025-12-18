/// Entité représentant une branche scoute.
class Branch {
  final String id;
  final String name;
  final String color; // Code couleur hexadécimal
  final int minAge;
  final int maxAge;

  const Branch({
    required this.id,
    required this.name,
    required this.color,
    required this.minAge,
    required this.maxAge,
  });

  String get ageRange => '$minAge-$maxAge ans';
}

