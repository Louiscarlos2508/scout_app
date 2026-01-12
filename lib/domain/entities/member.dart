import 'phone_number.dart';
import 'parent_contact.dart';

/// Entité représentant un membre (scout) dans le système.
class Member {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String branchId;
  final String? unitId; // ID de l'unité à laquelle appartient le membre
  final String? photoUrl; // URL de la photo du membre
  final List<PhoneNumber> phoneNumbers; // Numéros de téléphone du membre (pour non-louveteaux)
  final List<ParentContact> parentContacts; // Contacts des parents/tuteurs
  final MedicalInfo? medicalInfo;
  final DateTime? lastSync;
  final DateTime? deletedAt; // Date de suppression (soft delete)
  final String? deletionReason; // Motif de suppression

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.branchId,
    this.unitId,
    this.photoUrl,
    this.phoneNumbers = const [],
    this.parentContacts = const [],
    this.medicalInfo,
    this.lastSync,
    this.deletedAt,
    this.deletionReason,
  });

  /// Vérifie si le membre est supprimé (soft delete).
  bool get isDeleted => deletedAt != null;

  String get fullName => '$firstName $lastName';

  int get age {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    final monthDiff = today.month - dateOfBirth.month;
    if (monthDiff < 0 || (monthDiff == 0 && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Retourne le numéro de téléphone principal (pour compatibilité avec l'ancien code).
  String? get parentPhone {
    if (parentContacts.isEmpty) return null;
    final firstContact = parentContacts.first;
    if (firstContact.phoneNumbers.isEmpty) return null;
    return firstContact.phoneNumbers.first.number;
  }
}

/// Informations médicales d'un membre.
class MedicalInfo {
  final List<String> allergies;
  final List<String> illnesses;
  final List<String> medications;
  final String? bloodGroup;
  final String? notes;

  const MedicalInfo({
    this.allergies = const [],
    this.illnesses = const [],
    this.medications = const [],
    this.bloodGroup,
    this.notes,
  });
}

