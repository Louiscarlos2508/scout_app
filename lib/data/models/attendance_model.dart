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
    SessionType sessionType;
    final typeValue = json['type'];
    if (typeValue is int) {
      sessionType = SessionType.values[typeValue];
    } else if (typeValue is String) {
      sessionType = SessionType.values.firstWhere(
        (e) => e.toString().split('.').last == typeValue,
        orElse: () => SessionType.weekly,
      );
    } else {
      sessionType = SessionType.weekly;
    }

    return AttendanceModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: sessionType,
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
      'type': type.index, // Stocker comme index pour une meilleure compatibilité
      'branchId': branchId,
      'presentMemberIds': presentMemberIds,
      'absentMemberIds': absentMemberIds,
      'lastSync': lastSync?.toIso8601String(),
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  AttendanceModel copyWith({
    String? id,
    DateTime? date,
    SessionType? type,
    String? branchId,
    List<String>? presentMemberIds,
    List<String>? absentMemberIds,
    DateTime? lastSync,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      branchId: branchId ?? this.branchId,
      presentMemberIds: presentMemberIds ?? this.presentMemberIds,
      absentMemberIds: absentMemberIds ?? this.absentMemberIds,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

