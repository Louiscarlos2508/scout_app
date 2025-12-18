import 'package:dartz/dartz.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/local/member_local_datasource.dart';
import '../datasources/remote/member_remote_datasource.dart';
import '../models/member_model.dart';
import '../../core/network/network_info.dart';

/// Implémentation du repository Member avec synchronisation offline-first.
class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;
  final MemberLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MemberRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Member>>> getMembersByBranch(
    String branchId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        // Récupérer depuis Firestore et mettre en cache
        final remoteMembers =
            await remoteDataSource.getMembersByBranch(branchId);
        await localDataSource.cacheMembers(remoteMembers);
        return Right(remoteMembers);
      } else {
        // Mode offline : récupérer depuis le cache local
        final localMembers =
            await localDataSource.getMembersByBranch(branchId);
        return Right(localMembers);
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
  Future<Either<Failure, Member>> getMemberById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteMember = await remoteDataSource.getMemberById(id);
        await localDataSource.cacheMember(remoteMember);
        return Right(remoteMember);
      } else {
        final localMember = await localDataSource.getMemberById(id);
        if (localMember != null) {
          return Right(localMember);
        } else {
          return Left(CacheFailure('Member not found in cache'));
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
  Future<Either<Failure, Member>> createMember(Member member) async {
    try {
      final memberModel = MemberModel.fromEntity(member);
      // Toujours sauvegarder localement d'abord (offline-first)
      await localDataSource.cacheMember(memberModel);

      if (await networkInfo.isConnected) {
        // Synchroniser avec Firestore si connecté
        final createdMember = await remoteDataSource.createMember(memberModel);
        await localDataSource.cacheMember(createdMember);
        return Right(createdMember);
      }

      return Right(memberModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> updateMember(Member member) async {
    try {
      final memberModel = MemberModel.fromEntity(member);
      // Toujours mettre à jour localement d'abord
      await localDataSource.cacheMember(memberModel);

      if (await networkInfo.isConnected) {
        final updatedMember = await remoteDataSource.updateMember(memberModel);
        await localDataSource.cacheMember(updatedMember);
        return Right(updatedMember);
      }

      return Right(memberModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMember(String id) async {
    try {
      // Supprimer localement d'abord
      await localDataSource.deleteMember(id);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteMember(id);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncMembers() async {
    try {
      if (await networkInfo.isConnected) {
        // TODO: Implémenter la logique de synchronisation bidirectionnelle
        // - Récupérer les membres locaux non synchronisés
        // - Les envoyer à Firestore
        // - Récupérer les mises à jour depuis Firestore
        // - Fusionner les données
        return const Right(null);
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

