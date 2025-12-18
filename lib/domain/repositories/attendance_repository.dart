import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/attendance.dart';

/// Interface du repository pour la gestion des présences.
abstract class AttendanceRepository {
  /// Récupère toutes les sessions de présence d'une branche.
  Future<Either<Failure, List<Attendance>>> getAttendanceSessionsByBranch(
    String branchId,
  );

  /// Récupère une session de présence par son ID.
  Future<Either<Failure, Attendance>> getAttendanceById(String id);

  /// Crée une nouvelle session de présence.
  Future<Either<Failure, Attendance>> createAttendanceSession(
    Attendance attendance,
  );

  /// Marque la présence d'un membre pour une session.
  Future<Either<Failure, Attendance>> markAttendance(
    String sessionId,
    String memberId,
    bool isPresent,
  );

  /// Synchronise les présences avec le serveur.
  Future<Either<Failure, void>> syncAttendance();
}

