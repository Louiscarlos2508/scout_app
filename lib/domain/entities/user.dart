/// Rôle d'un utilisateur (chef).
enum UserRole {
  admin, // Administrateur système
  unitLeader, // Chef d'Unité
  assistantLeader, // Chef Assistant
}

/// Statut d'un utilisateur.
enum UserStatus {
  pending, // En attente de validation
  approved, // Validé par l'admin
}

/// Entité représentant un utilisateur (chef).
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final UserRole role;
  final UserStatus status;
  final String unitId;
  final String branchId; // Tous les utilisateurs ont une branche
  final String? photoUrl; // URL de la photo de profil

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.role,
    required this.status,
    required this.unitId,
    required this.branchId,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  /// Vérifie si l'utilisateur a accès à une branche spécifique.
  bool hasAccessToBranch(String branchId) {
    if (role == UserRole.admin || role == UserRole.unitLeader) {
      return true; // L'admin et le chef d'unité ont accès à toutes les branches
    }
    return this.branchId == branchId; // L'assistant n'a accès qu'à sa branche
  }

  /// Vérifie si l'utilisateur est administrateur.
  bool get isAdmin => role == UserRole.admin;

  /// Vérifie si l'utilisateur a accès au panneau d'administration.
  bool get hasAdminAccess => role == UserRole.admin;

  /// Vérifie si l'utilisateur est en attente de validation.
  bool get isPending => status == UserStatus.pending;

  /// Vérifie si l'utilisateur est approuvé.
  bool get isApproved => status == UserStatus.approved;
}

