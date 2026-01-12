/// Constantes pour les collections Firestore.
class FirestoreConstants {
  FirestoreConstants._();

  // Collections
  static const String membersCollection = 'members';
  static const String attendanceCollection = 'attendance';
  static const String branchesCollection = 'branches';
  static const String unitsCollection = 'units';
  static const String groupsCollection = 'groups';
  static const String usersCollection = 'users';

  // Champs pour les membres
  static const String memberIdField = 'id';
  static const String memberFirstNameField = 'firstName';
  static const String memberLastNameField = 'lastName';
  static const String memberDateOfBirthField = 'dateOfBirth';
  static const String memberBranchIdField = 'branchId';
  static const String memberParentPhoneField = 'parentPhone';
  static const String memberMedicalInfoField = 'medicalInfo';
  static const String memberLastSyncField = 'lastSync';

  // Champs pour les présences
  static const String attendanceIdField = 'id';
  static const String attendanceDateField = 'date';
  static const String attendanceTypeField = 'type';
  static const String attendanceBranchIdField = 'branchId';
  static const String attendancePresentMemberIdsField = 'presentMemberIds';
  static const String attendanceAbsentMemberIdsField = 'absentMemberIds';
  static const String attendanceLastSyncField = 'lastSync';
}
