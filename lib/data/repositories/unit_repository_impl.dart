import 'package:dartz/dartz.dart';
import '../../domain/entities/unit.dart' as entity;
import '../../domain/repositories/unit_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/unit_remote_datasource.dart';
import '../models/unit_model.dart';

/// Implémentation du repository Unit.
class UnitRepositoryImpl implements UnitRepository {
  final UnitRemoteDataSource remoteDataSource;

  UnitRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<entity.Unit>>> getAllUnits() async {
    try {
      final units = await remoteDataSource.getAllUnits();
      return Right(units);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, entity.Unit>> getUnitById(String id) async {
    try {
      final unit = await remoteDataSource.getUnitById(id);
      if (unit == null) {
        return Left(ServerFailure('Unit not found'));
      }
      return Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<entity.Unit>>> getUnitsByGroup(String groupId) async {
    try {
      final units = await remoteDataSource.getUnitsByGroup(groupId);
      return Right(units);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, entity.Unit>> createUnit(entity.Unit unit) async {
    try {
      final unitModel = UnitModel.fromEntity(unit);
      final createdUnit = await remoteDataSource.createUnit(unitModel);
      return Right(createdUnit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, entity.Unit>> updateUnit(entity.Unit unit) async {
    try {
      final unitModel = UnitModel.fromEntity(unit);
      final updatedUnit = await remoteDataSource.updateUnit(unitModel);
      return Right(updatedUnit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnit(String id) async {
    try {
      await remoteDataSource.deleteUnit(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
