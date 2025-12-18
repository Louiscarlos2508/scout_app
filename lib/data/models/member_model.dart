import '../../domain/entities/member.dart';

/// Modèle de données pour Member avec sérialisation JSON.
class MemberModel extends Member {
  const MemberModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.dateOfBirth,
    required super.branchId,
    super.parentPhone,
    super.medicalInfo,
    super.lastSync,
  });

  /// Crée un MemberModel à partir d'un Member.
  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      id: member.id,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      parentPhone: member.parentPhone,
      medicalInfo: member.medicalInfo,
      lastSync: member.lastSync,
    );
  }

  /// Crée un MemberModel à partir d'un JSON (Firestore).
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      branchId: json['branchId'] as String,
      parentPhone: json['parentPhone'] as String?,
      medicalInfo: json['medicalInfo'] != null
          ? MedicalInfo(
              allergies: List<String>.from(json['medicalInfo']['allergies']),
              illnesses: List<String>.from(json['medicalInfo']['illnesses']),
              medications:
                  List<String>.from(json['medicalInfo']['medications']),
              bloodGroup: json['medicalInfo']['bloodGroup'] as String?,
              notes: json['medicalInfo']['notes'] as String?,
            )
          : null,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'branchId': branchId,
      'parentPhone': parentPhone,
      'medicalInfo': medicalInfo != null
          ? {
              'allergies': medicalInfo!.allergies,
              'illnesses': medicalInfo!.illnesses,
              'medications': medicalInfo!.medications,
              'bloodGroup': medicalInfo!.bloodGroup,
              'notes': medicalInfo!.notes,
            }
          : null,
      'lastSync': lastSync?.toIso8601String(),
    };
  }
}

