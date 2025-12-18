import '../../domain/entities/group.dart';

/// Modèle de données pour Group avec sérialisation JSON.
class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    super.unitIds,
  });

  /// Crée un GroupModel à partir d'un Group.
  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      unitIds: group.unitIds,
    );
  }

  /// Crée un GroupModel à partir d'un JSON (Firestore).
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      unitIds: List<String>.from(json['unitIds'] ?? []),
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitIds': unitIds,
    };
  }
}

