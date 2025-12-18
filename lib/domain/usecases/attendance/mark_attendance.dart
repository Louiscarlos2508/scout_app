import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Use case pour marquer la présence d'un membre.
class MarkAttendance {
  final AttendanceRepository repository;

  MarkAttendance(this.repository);

  Future<Either<Failure, Attendance>> call(
    String sessionId,
    String memberId,
    bool isPresent,
  ) {
    return repository.markAttendance(sessionId, memberId, isPresent);
  }
}

