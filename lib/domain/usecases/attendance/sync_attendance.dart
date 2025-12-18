import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/attendance_repository.dart';

/// Use case pour synchroniser les présences avec le serveur.
class SyncAttendance {
  final AttendanceRepository repository;

  SyncAttendance(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncAttendance();
  }
}

