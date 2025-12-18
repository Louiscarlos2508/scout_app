import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Use case pour créer une nouvelle session de présence.
class CreateAttendanceSession {
  final AttendanceRepository repository;

  CreateAttendanceSession(this.repository);

  Future<Either<Failure, Attendance>> call(Attendance attendance) {
    return repository.createAttendanceSession(attendance);
  }
}

