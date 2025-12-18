/// Constantes pour les noms de collections et clés de base de données.
class DatabaseConstants {
  DatabaseConstants._();

  // Collections Isar
  static const String membersCollection = 'members';
  static const String attendanceCollection = 'attendance';
  static const String branchesCollection = 'branches';
  static const String unitsCollection = 'units';
  static const String groupsCollection = 'groups';
  static const String usersCollection = 'users';

  // Collections Firestore
  static const String firestoreMembersPath = 'members';
  static const String firestoreAttendancePath = 'attendance';
  static const String firestoreBranchesPath = 'branches';
  static const String firestoreUnitsPath = 'units';
  static const String firestoreGroupsPath = 'groups';
  static const String firestoreUsersPath = 'users';

  // Clés de synchronisation
  static const String lastSyncKey = 'lastSync';
  static const String syncStatusKey = 'syncStatus';
}

