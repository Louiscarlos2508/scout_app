import '../../domain/entities/branch.dart';

/// Modèle de données pour Branch avec sérialisation JSON.
class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.name,
    required super.color,
    required super.minAge,
    required super.maxAge,
  });

  /// Crée un BranchModel à partir d'un Branch.
  factory BranchModel.fromEntity(Branch branch) {
    return BranchModel(
      id: branch.id,
      name: branch.name,
      color: branch.color,
      minAge: branch.minAge,
      maxAge: branch.maxAge,
    );
  }

  /// Crée un BranchModel à partir d'un JSON (Firestore).
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      minAge: json['minAge'] as int,
      maxAge: json['maxAge'] as int,
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'minAge': minAge,
      'maxAge': maxAge,
    };
  }
}

