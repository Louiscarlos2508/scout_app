import '../../domain/entities/user.dart';

/// Modèle de données pour User avec sérialisation JSON.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.unitId,
    super.branchId,
  });

  /// Crée un UserModel à partir d'un User.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      unitId: user.unitId,
      branchId: user.branchId,
    );
  }

  /// Crée un UserModel à partir d'un JSON (Firestore).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.assistantLeader,
      ),
      unitId: json['unitId'] as String,
      branchId: json['branchId'] as String?,
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'unitId': unitId,
      'branchId': branchId,
    };
  }
}

