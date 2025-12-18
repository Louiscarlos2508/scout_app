import '../../domain/entities/unit.dart';

/// Modèle de données pour Unit avec sérialisation JSON.
class UnitModel extends Unit {
  const UnitModel({
    required super.id,
    required super.name,
    required super.groupId,
    super.branchIds,
  });

  /// Crée un UnitModel à partir d'un Unit.
  factory UnitModel.fromEntity(Unit unit) {
    return UnitModel(
      id: unit.id,
      name: unit.name,
      groupId: unit.groupId,
      branchIds: unit.branchIds,
    );
  }

  /// Crée un UnitModel à partir d'un JSON (Firestore).
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      groupId: json['groupId'] as String,
      branchIds: List<String>.from(json['branchIds'] ?? []),
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groupId': groupId,
      'branchIds': branchIds,
    };
  }
}

