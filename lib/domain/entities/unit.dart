/// Entité représentant une unité scoute.
class Unit {
  final String id;
  final String name;
  final String groupId;
  final List<String> branchIds;

  const Unit({
    required this.id,
    required this.name,
    required this.groupId,
    this.branchIds = const [],
  });
}

