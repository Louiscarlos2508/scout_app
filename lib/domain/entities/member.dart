/// Entité représentant un membre (scout) dans le système.
class Member {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String branchId;
  final String? parentPhone;
  final MedicalInfo? medicalInfo;
  final DateTime? lastSync;

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.branchId,
    this.parentPhone,
    this.medicalInfo,
    this.lastSync,
  });

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

