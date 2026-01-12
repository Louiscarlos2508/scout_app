import '../../models/attendance_model.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/firestore_constants.dart';
import 'firebase_service.dart';

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
  @override
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId) async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.attendanceCollection,
        whereField: FirestoreConstants.attendanceBranchIdField,
        whereValue: branchId,
      );

      final models = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AttendanceModel.fromJson(data);
      }).toList();

      // Trier par date décroissante (plus récentes en premier)
      models.sort((a, b) => b.date.compareTo(a.date));

      return models;
    } catch (e) {
      throw ServerException('Failed to fetch attendance: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceModel> getAttendanceById(String id) async {
    try {
      final doc = await FirebaseService.getDocument(
        FirestoreConstants.attendanceCollection,
        id,
      );

      if (doc == null || !doc.exists) {
        throw ServerException('Attendance session not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return AttendanceModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch attendance: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceModel> createAttendance(AttendanceModel attendance) async {
    try {
      final json = attendance.toJson();
      json[FirestoreConstants.attendanceLastSyncField] = DateTime.now().toIso8601String();

      await FirebaseService.setData(
        FirestoreConstants.attendanceCollection,
        attendance.id,
        json,
      );

      return attendance.copyWith(lastSync: DateTime.now());
    } catch (e) {
      throw ServerException('Failed to create attendance: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceModel> updateAttendance(AttendanceModel attendance) async {
    try {
      final json = attendance.toJson();
      json[FirestoreConstants.attendanceLastSyncField] = DateTime.now().toIso8601String();

      await FirebaseService.updateData(
        FirestoreConstants.attendanceCollection,
        attendance.id,
        json,
      );

      return attendance.copyWith(lastSync: DateTime.now());
    } catch (e) {
      throw ServerException('Failed to update attendance: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAttendance(String id) async {
    try {
      await FirebaseService.deleteData(
        FirestoreConstants.attendanceCollection,
        id,
      );
    } catch (e) {
      throw ServerException('Failed to delete attendance: ${e.toString()}');
    }
  }
}

