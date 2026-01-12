import 'package:dartz/dartz.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/group_remote_datasource.dart';
import '../models/group_model.dart';

/// Implémentation du repository Group.
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Group>>> getAllGroups() async {
    try {
      final groups = await remoteDataSource.getAllGroups();
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroupById(String id) async {
    try {
      final group = await remoteDataSource.getGroupById(id);
      if (group == null) {
        return Left(ServerFailure('Group not found'));
      }
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> createGroup(Group group) async {
    try {
      final groupModel = GroupModel.fromEntity(group);
      final createdGroup = await remoteDataSource.createGroup(groupModel);
      return Right(createdGroup);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> updateGroup(Group group) async {
    try {
      final groupModel = GroupModel.fromEntity(group);
      final updatedGroup = await remoteDataSource.updateGroup(groupModel);
      return Right(updatedGroup);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String id) async {
    try {
      await remoteDataSource.deleteGroup(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
