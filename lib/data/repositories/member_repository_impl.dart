import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/sync_service.dart';
import '../datasources/local/member_local_datasource.dart';
import '../datasources/remote/member_remote_datasource.dart';
import '../models/member_model.dart';
import '../../core/network/network_info.dart';

/// Implémentation du repository Member avec synchronisation offline-first.
class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;
  final MemberLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SyncService? syncService;

  MemberRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.syncService,
  });

  @override
  Future<Either<Failure, List<Member>>> getMembersByBranch(
    String branchId,
  ) async {
    try {
      // Sur le web, utiliser directement Firebase
      if (kIsWeb) {
        final remoteMembers = await remoteDataSource.getMembersByBranch(branchId);
        return Right(remoteMembers);
      }
      
      // Sur mobile/desktop, charger depuis Drift d'abord (rapide)
      final localMembers = await localDataSource.getMembersByBranch(branchId);
      
      // Synchroniser en arrière-plan si connecté (non bloquant)
      if (await networkInfo.isConnected) {
        remoteDataSource.getMembersByBranch(branchId).then((remoteMembers) async {
          await localDataSource.cacheMembers(remoteMembers);
        }).catchError((e) {
          // Ignorer les erreurs de synchronisation en arrière-plan
        });
      }
      
      return Right(localMembers);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> getMemberById(String id) async {
    try {
      // Sur le web, utiliser directement Firebase
      if (kIsWeb) {
        final remoteMember = await remoteDataSource.getMemberById(id);
        return Right(remoteMember);
      }
      
      // Sur mobile/desktop, charger depuis Drift d'abord (rapide)
      final localMember = await localDataSource.getMemberById(id);
      
      if (localMember != null) {
        // Synchroniser en arrière-plan si connecté (non bloquant)
        if (await networkInfo.isConnected) {
          remoteDataSource.getMemberById(id).then((remoteMember) async {
            await localDataSource.cacheMember(remoteMember);
          }).catchError((e) {
            // Ignorer les erreurs de synchronisation en arrière-plan
          });
        }
        return Right(localMember);
      } else {
        return Left(CacheFailure('Member not found in cache'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> createMember(Member member) async {
    try {
      final now = DateTime.now();
      
      // Générer un ID unique si l'ID est vide ou invalide
      final memberId = member.id.isEmpty || member.id.trim().isEmpty
          ? 'member_${now.millisecondsSinceEpoch}_${(now.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0')}'
          : member.id;
      
      final memberWithId = member.id != memberId
          ? Member(
              id: memberId,
              firstName: member.firstName,
              lastName: member.lastName,
              dateOfBirth: member.dateOfBirth,
              branchId: member.branchId,
              unitId: member.unitId,
              photoUrl: member.photoUrl,
              phoneNumbers: member.phoneNumbers,
              parentContacts: member.parentContacts,
              medicalInfo: member.medicalInfo,
              lastSync: member.lastSync,
            )
          : member;
      
      final memberModel = MemberModel.fromEntity(memberWithId);
      // Toujours sauvegarder localement d'abord (offline-first)
      // Ne pas définir lastSync pour les nouveaux membres (sera défini après sync)
      await localDataSource.cacheMember(memberModel);

      if (await networkInfo.isConnected) {
        // Synchroniser avec Firestore si connecté
        final createdMember = await remoteDataSource.createMember(memberModel);
        // Mettre à jour avec lastSync après création réussie
        final syncedMember = createdMember.copyWith(lastSync: now);
        await localDataSource.cacheMember(syncedMember);
        return Right(syncedMember);
      }

      // Membre créé en mode offline (lastSync restera null jusqu'à la prochaine sync)
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
      final now = DateTime.now();
      final memberModel = MemberModel.fromEntity(member);
      // Toujours mettre à jour localement d'abord
      // Mettre à jour lastSync seulement si connecté
      await localDataSource.cacheMember(memberModel);

      if (await networkInfo.isConnected) {
        final updatedMember = await remoteDataSource.updateMember(memberModel);
        // Mettre à jour avec lastSync après mise à jour réussie
        final syncedMember = updatedMember.copyWith(lastSync: now);
        await localDataSource.cacheMember(syncedMember);
        return Right(syncedMember);
      }

      // Mise à jour en mode offline (conserver l'ancien lastSync ou null)
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
  Future<Either<Failure, void>> deleteMember(String id, String reason) async {
    try {
      final now = DateTime.now();
      
      // Récupérer le membre actuel
      final memberResult = await getMemberById(id);
      return await memberResult.fold(
        (failure) => Left(failure),
        (member) async {
          // Créer une version "supprimée" du membre
          final deletedMember = Member(
            id: member.id,
            firstName: member.firstName,
            lastName: member.lastName,
            dateOfBirth: member.dateOfBirth,
            branchId: member.branchId,
            unitId: member.unitId,
            photoUrl: member.photoUrl,
            phoneNumbers: member.phoneNumbers,
            parentContacts: member.parentContacts,
            medicalInfo: member.medicalInfo,
            lastSync: member.lastSync,
            deletedAt: now,
            deletionReason: reason,
          );
          
          final deletedMemberModel = MemberModel.fromEntity(deletedMember);
          
          // Mettre à jour localement d'abord
          await localDataSource.cacheMember(deletedMemberModel);

          if (await networkInfo.isConnected) {
            // Mettre à jour sur Firestore (soft delete)
            await remoteDataSource.updateMember(deletedMemberModel);
          }

          return const Right(null);
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> restoreMember(String id) async {
    try {
      // Récupérer le membre supprimé
      final memberResult = await getMemberById(id);
      return await memberResult.fold(
        (failure) => Left(failure),
        (member) async {
          if (member.deletedAt == null) {
            return Left(ServerFailure('Le membre n\'est pas supprimé'));
          }
          
          // Restaurer le membre en supprimant deletedAt et deletionReason
          final restoredMember = Member(
            id: member.id,
            firstName: member.firstName,
            lastName: member.lastName,
            dateOfBirth: member.dateOfBirth,
            branchId: member.branchId,
            unitId: member.unitId,
            photoUrl: member.photoUrl,
            phoneNumbers: member.phoneNumbers,
            parentContacts: member.parentContacts,
            medicalInfo: member.medicalInfo,
            lastSync: member.lastSync,
            deletedAt: null,
            deletionReason: null,
          );
          
          final restoredMemberModel = MemberModel.fromEntity(restoredMember);
          
          // Mettre à jour localement
          await localDataSource.cacheMember(restoredMemberModel);

          if (await networkInfo.isConnected) {
            // Mettre à jour sur Firestore
            final updatedMember = await remoteDataSource.updateMember(restoredMemberModel);
            final syncedMember = updatedMember.copyWith(lastSync: DateTime.now());
            await localDataSource.cacheMember(syncedMember);
            return Right(syncedMember);
          }

          return Right(restoredMemberModel);
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Member>>> getDeletedMembers() async {
    try {
      if (kIsWeb) {
        // Sur le web, utiliser directement Firebase
        final deletedMembers = await remoteDataSource.getDeletedMembers();
        return Right(deletedMembers);
      }
      
      // Sur mobile/desktop, charger depuis Drift d'abord
      final localDeletedMembers = await localDataSource.getDeletedMembers();
      
      // Synchroniser en arrière-plan si connecté
      if (await networkInfo.isConnected) {
        remoteDataSource.getDeletedMembers().then((remoteMembers) async {
          await localDataSource.cacheMembers(remoteMembers);
        }).catchError((e) {
          // Ignorer les erreurs de synchronisation en arrière-plan
        });
      }
      
      return Right(localDeletedMembers);
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
        // Utiliser le SyncService si disponible, sinon implémentation basique
        if (syncService != null) {
          // Pour une synchronisation complète, on synchronise toutes les branches
          // Dans une implémentation complète, on devrait récupérer toutes les branches
          // Pour l'instant, on synchronise une branche par une branche
          // Cette méthode devrait être appelée avec un branchId spécifique
          // Note: syncMembers() général devrait être remplacé par syncMembersByBranch()
          return const Right(null);
        } else {
          // Implémentation basique de fallback
          return const Right(null);
        }
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Synchronise les membres d'une branche spécifique avec résolution de conflits.
  Future<Either<Failure, void>> syncMembersByBranch(String branchId) async {
    if (syncService != null) {
      return syncService!.syncMembers(branchId);
    } else {
      // Fallback: synchronisation basique sans résolution de conflits
      try {
        if (await networkInfo.isConnected) {
          final remoteMembers =
              await remoteDataSource.getMembersByBranch(branchId);
          await localDataSource.cacheMembers(remoteMembers);
          return const Right(null);
        } else {
          return Left(NetworkFailure('No internet connection'));
        }
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}

