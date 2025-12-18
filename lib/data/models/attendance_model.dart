import '../../domain/entities/attendance.dart';

/// Modèle de données pour Attendance avec sérialisation JSON.
class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.date,
    required super.type,
    required super.branchId,
    super.presentMemberIds,
    super.absentMemberIds,
    super.lastSync,
  });

  /// Crée un AttendanceModel à partir d'un Attendance.
  factory AttendanceModel.fromEntity(Attendance attendance) {
    return AttendanceModel(
      id: attendance.id,
      date: attendance.date,
      type: attendance.type,
      branchId: attendance.branchId,
      presentMemberIds: attendance.presentMemberIds,
      absentMemberIds: attendance.absentMemberIds,
      lastSync: attendance.lastSync,
    );
  }

  /// Crée un AttendanceModel à partir d'un JSON (Firestore).
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: SessionType.values.firstWhere(
        (e) => e.toString() == 'SessionType.${json['type']}',
        orElse: () => SessionType.weekly,
      ),
      branchId: json['branchId'] as String,
      presentMemberIds: List<String>.from(json['presentMemberIds'] ?? []),
      absentMemberIds: List<String>.from(json['absentMemberIds'] ?? []),
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
    );
  }

  /// Convertit le modèle en JSON (Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'branchId': branchId,
      'presentMemberIds': presentMemberIds,
      'absentMemberIds': absentMemberIds,
      'lastSync': lastSync?.toIso8601String(),
    };
  }
}

