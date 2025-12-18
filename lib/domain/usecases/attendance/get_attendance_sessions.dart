import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Use case pour récupérer les sessions de présence d'une branche.
class GetAttendanceSessions {
  final AttendanceRepository repository;

  GetAttendanceSessions(this.repository);

  Future<Either<Failure, List<Attendance>>> call(String branchId) {
    return repository.getAttendanceSessionsByBranch(branchId);
  }
}

