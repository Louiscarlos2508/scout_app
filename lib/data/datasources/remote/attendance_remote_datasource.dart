import '../../../domain/entities/attendance.dart';
import '../../models/attendance_model.dart';
import '../../../core/errors/exceptions.dart';

/// Source de données distante pour les présences (Firestore).
abstract class AttendanceRemoteDataSource {
  /// Récupère toutes les sessions de présence d'une branche depuis Firestore.
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId);

  /// Récupère une session par son ID.
  Future<AttendanceModel> getAttendanceById(String id);

  /// Crée une nouvelle session sur Firestore.
  Future<AttendanceModel> createAttendance(AttendanceModel attendance);

  /// Met à jour une session sur Firestore.
  Future<AttendanceModel> updateAttendance(AttendanceModel attendance);

  /// Supprime une session de Firestore.
  Future<void> deleteAttendance(String id);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  // TODO: Implémenter avec Firestore
  @override
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<AttendanceModel> getAttendanceById(String id) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<AttendanceModel> createAttendance(AttendanceModel attendance) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<AttendanceModel> updateAttendance(AttendanceModel attendance) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAttendance(String id) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }
}

