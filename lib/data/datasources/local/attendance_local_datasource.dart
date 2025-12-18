import '../../../domain/entities/attendance.dart';
import '../../models/attendance_model.dart';

/// Source de données locale pour les présences (Isar).
abstract class AttendanceLocalDataSource {
  /// Récupère toutes les sessions de présence d'une branche.
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId);

  /// Récupère une session par son ID.
  Future<AttendanceModel?> getAttendanceById(String id);

  /// Sauvegarde une session localement.
  Future<void> cacheAttendance(AttendanceModel attendance);

  /// Sauvegarde plusieurs sessions localement.
  Future<void> cacheAttendanceList(List<AttendanceModel> attendanceList);

  /// Supprime une session du cache local.
  Future<void> deleteAttendance(String id);

  /// Supprime toutes les sessions du cache local.
  Future<void> clearCache();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  // TODO: Implémenter avec Isar
  @override
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<AttendanceModel?> getAttendanceById(String id) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> cacheAttendance(AttendanceModel attendance) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> cacheAttendanceList(List<AttendanceModel> attendanceList) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAttendance(String id) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() async {
    // TODO: Implémenter
    throw UnimplementedError();
  }
}

