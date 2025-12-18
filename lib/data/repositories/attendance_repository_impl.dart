import 'package:dartz/dartz.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/local/attendance_local_datasource.dart';
import '../datasources/remote/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';
import '../../core/network/network_info.dart';

/// Implémentation du repository Attendance avec synchronisation offline-first.
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Attendance>>> getAttendanceSessionsByBranch(
    String branchId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteAttendance =
            await remoteDataSource.getAttendanceByBranch(branchId);
        await localDataSource.cacheAttendanceList(
          remoteAttendance.map((a) => AttendanceModel.fromEntity(a)).toList(),
        );
        return Right(remoteAttendance);
      } else {
        final localAttendance =
            await localDataSource.getAttendanceByBranch(branchId);
        return Right(localAttendance);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Attendance>> getAttendanceById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteAttendance = await remoteDataSource.getAttendanceById(id);
        await localDataSource.cacheAttendance(
          AttendanceModel.fromEntity(remoteAttendance),
        );
        return Right(remoteAttendance);
      } else {
        final localAttendance = await localDataSource.getAttendanceById(id);
        if (localAttendance != null) {
          return Right(localAttendance);
        } else {
          return Left(CacheFailure('Attendance not found in cache'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Attendance>> createAttendanceSession(
    Attendance attendance,
  ) async {
    try {
      final attendanceModel = AttendanceModel.fromEntity(attendance);
      // Sauvegarder localement d'abord
      await localDataSource.cacheAttendance(attendanceModel);

      if (await networkInfo.isConnected) {
        final createdAttendance =
            await remoteDataSource.createAttendance(attendanceModel);
        await localDataSource.cacheAttendance(createdAttendance);
        return Right(createdAttendance);
      }

      return Right(attendanceModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Attendance>> markAttendance(
    String sessionId,
    String memberId,
    bool isPresent,
  ) async {
    try {
      // Récupérer la session actuelle
      final currentAttendance = await getAttendanceById(sessionId);
      return currentAttendance.fold(
        (failure) => Left(failure),
        (attendance) async {
          final presentIds = List<String>.from(attendance.presentMemberIds);
          final absentIds = List<String>.from(attendance.absentMemberIds);

          if (isPresent) {
            presentIds.add(memberId);
            absentIds.remove(memberId);
          } else {
            absentIds.add(memberId);
            presentIds.remove(memberId);
          }

          final updatedAttendance = Attendance(
            id: attendance.id,
            date: attendance.date,
            type: attendance.type,
            branchId: attendance.branchId,
            presentMemberIds: presentIds,
            absentMemberIds: absentIds,
            lastSync: attendance.lastSync,
          );

          return await createAttendanceSession(updatedAttendance);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncAttendance() async {
    try {
      if (await networkInfo.isConnected) {
        // TODO: Implémenter la synchronisation bidirectionnelle
        return const Right(null);
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

