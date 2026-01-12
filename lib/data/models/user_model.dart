import '../../domain/entities/user.dart';

/// Modèle de données pour User avec sérialisation JSON.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.role,
    required super.status,
    required super.unitId,
    required super.branchId,
    super.photoUrl,
  });

  /// Crée un UserModel à partir d'un User.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: user.phoneNumber,
      dateOfBirth: user.dateOfBirth,
      role: user.role,
      status: user.status,
      unitId: user.unitId,
      branchId: user.branchId,
      photoUrl: user.photoUrl,
    );
  }

  /// Crée un UserModel à partir d'un JSON (Firestore).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : DateTime.now().subtract(const Duration(days: 365 * 25)),
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.assistantLeader,
      ),
      status: json['status'] != null
          ? UserStatus.values.firstWhere(
              (e) => e.toString() == 'UserStatus.${json['status']}',
              orElse: () => UserStatus.pending,
            )
          : UserStatus.pending,
      unitId: json['unitId'] as String,
      branchId: json['branchId'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'unitId': unitId,
      'branchId': branchId,
      'photoUrl': photoUrl,
    };
  }
}

