/// Type de session de présence.
enum SessionType {
  weekly, // Hebdomadaire
  monthly, // Mensuelle
  special, // Activité spéciale
}

/// Entité représentant une session de présence.
class Attendance {
  final String id;
  final DateTime date;
  final SessionType type;
  final String branchId;
  final List<String> presentMemberIds;
  final List<String> absentMemberIds;
  final DateTime? lastSync;

  const Attendance({
    required this.id,
    required this.date,
    required this.type,
    required this.branchId,
    this.presentMemberIds = const [],
    this.absentMemberIds = const [],
    this.lastSync,
  });

  int get totalMembers => presentMemberIds.length + absentMemberIds.length;
}

