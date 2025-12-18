/// Rôle d'un utilisateur (chef).
enum UserRole {
  unitLeader, // Chef d'Unité
  assistantLeader, // Chef Assistant
}

/// Entité représentant un utilisateur (chef).
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String unitId;
  final String? branchId; // Null si unitLeader, défini si assistantLeader

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.unitId,
    this.branchId,
  });

  String get fullName => '$firstName $lastName';

  /// Vérifie si l'utilisateur a accès à une branche spécifique.
  bool hasAccessToBranch(String branchId) {
    if (role == UserRole.unitLeader) {
      return true; // Le chef d'unité a accès à toutes les branches
    }
    return this.branchId == branchId; // L'assistant n'a accès qu'à sa branche
  }
}

