import '../../models/attendance_model.dart';
// Export unique implementation using Drift (works on all platforms)
export 'attendance_local_datasource_impl.dart';

/// Source de données locale pour les présences.
/// 
/// Utilise Drift sur toutes les plateformes (mobile, desktop, web).
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
