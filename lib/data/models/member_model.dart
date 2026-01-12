import '../../domain/entities/member.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/entities/parent_contact.dart';

/// Modèle de données pour Member avec sérialisation JSON.
class MemberModel extends Member {
  const MemberModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.dateOfBirth,
    required super.branchId,
    super.unitId,
    super.photoUrl,
    super.phoneNumbers,
    super.parentContacts,
    super.medicalInfo,
    super.lastSync,
    super.deletedAt,
    super.deletionReason,
  });

  /// Crée un MemberModel à partir d'un Member.
  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      id: member.id,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      unitId: member.unitId,
      photoUrl: member.photoUrl,
      phoneNumbers: member.phoneNumbers,
      parentContacts: member.parentContacts,
      medicalInfo: member.medicalInfo,
      lastSync: member.lastSync,
      deletedAt: member.deletedAt,
      deletionReason: member.deletionReason,
    );
  }

  /// Crée un MemberModel à partir d'un JSON (Firestore).
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    // Support de l'ancien format avec parentPhone pour compatibilité
    List<ParentContact> parentContacts = [];
    if (json['parentContacts'] != null) {
      parentContacts = (json['parentContacts'] as List<dynamic>)
          .map((p) => ParentContact.fromJson(p as Map<String, dynamic>))
          .toList();
    } else if (json['parentPhone'] != null) {
      // Migration depuis l'ancien format
      parentContacts = [
        ParentContact(
          name: json['parentName'] as String? ?? '',
          phoneNumbers: [
            PhoneNumber(
              number: json['parentPhone'] as String,
              type: PhoneType.regular,
            ),
          ],
          relation: ParentRelation.other,
        ),
      ];
    }

    // Support de l'ancien format pour phoneNumbers
    List<PhoneNumber> phoneNumbers = [];
    if (json['phoneNumbers'] != null) {
      phoneNumbers = (json['phoneNumbers'] as List<dynamic>)
          .map((p) => PhoneNumber.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return MemberModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      branchId: json['branchId'] as String,
      unitId: json['unitId'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumbers: phoneNumbers,
      parentContacts: parentContacts,
      medicalInfo: json['medicalInfo'] != null
          ? MedicalInfo(
              allergies: List<String>.from(json['medicalInfo']['allergies'] ?? []),
              illnesses: List<String>.from(json['medicalInfo']['illnesses'] ?? []),
              medications:
                  List<String>.from(json['medicalInfo']['medications'] ?? []),
              bloodGroup: json['medicalInfo']['bloodGroup'] as String?,
              notes: json['medicalInfo']['notes'] as String?,
            )
          : null,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      deletionReason: json['deletionReason'] as String?,
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
      'unitId': unitId,
      'photoUrl': photoUrl,
      'phoneNumbers': phoneNumbers.map((p) => p.toJson()).toList(),
      'parentContacts': parentContacts.map((p) => p.toJson()).toList(),
      // Garder parentPhone pour compatibilité avec l'ancien code
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
      'deletedAt': deletedAt?.toIso8601String(),
      'deletionReason': deletionReason,
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  MemberModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? branchId,
    String? unitId,
    String? photoUrl,
    List<PhoneNumber>? phoneNumbers,
    List<ParentContact>? parentContacts,
    MedicalInfo? medicalInfo,
    DateTime? lastSync,
    DateTime? deletedAt,
    String? deletionReason,
  }) {
    return MemberModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      branchId: branchId ?? this.branchId,
      unitId: unitId ?? this.unitId,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      parentContacts: parentContacts ?? this.parentContacts,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      lastSync: lastSync ?? this.lastSync,
      deletedAt: deletedAt ?? this.deletedAt,
      deletionReason: deletionReason ?? this.deletionReason,
    );
  }
}

