/// Entité représentant un groupe scout.
class Group {
  final String id;
  final String name;
  final String? description;
  final List<String> unitIds;

  const Group({
    required this.id,
    required this.name,
    this.description,
    this.unitIds = const [],
  });
}

