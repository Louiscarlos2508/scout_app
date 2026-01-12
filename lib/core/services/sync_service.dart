import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import '../../data/datasources/local/member_local_datasource.dart';
import '../../data/datasources/remote/member_remote_datasource.dart';
import '../../data/models/member_model.dart';

/// Service de synchronisation bidirectionnelle avec gestion des conflits.
class SyncService {
  final MemberLocalDataSource localDataSource;
  final MemberRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Synchronise les membres d'une branche (bidirectionnel avec résolution de conflits).
  Future<Either<Failure, void>> syncMembers(String branchId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      // 1. Récupérer les membres locaux et distants
      final localMembers = await localDataSource.getMembersByBranch(branchId);
      final remoteMembers = await remoteDataSource.getMembersByBranch(branchId);

      // 2. Créer des maps pour faciliter la recherche
      final localMap = {
        for (var member in localMembers) member.id: member
      };
      final remoteMap = {
        for (var member in remoteMembers) member.id: member
      };

      final now = DateTime.now();
      final List<MemberModel> membersToUpdate = [];

      // 3. Traiter les membres locaux non synchronisés (nouveaux ou modifiés)
      for (final localMember in localMembers) {
        final remoteMember = remoteMap[localMember.id];
        
        if (remoteMember == null) {
          // Membre local qui n'existe pas sur Firestore
          if (localMember.lastSync == null) {
            // Nouveau membre local, créer sur Firestore
            try {
              final created = await remoteDataSource.createMember(localMember);
              // Le createMember du remoteDataSource met déjà à jour lastSync
              membersToUpdate.add(created);
            } catch (e) {
              // Ignorer si erreur (peut être déjà créé par un autre client)
              // Garder la version locale sans lastSync pour réessayer plus tard
              membersToUpdate.add(localMember);
            }
          } else {
            // Membre supprimé sur Firestore mais présent localement
            // Garder la version locale (pas de mise à jour)
            membersToUpdate.add(localMember);
          }
        } else {
          // Membre existe sur Firestore et localement
          // Résoudre le conflit (Last-Write-Wins)
          final resolvedMember = _resolveConflict(localMember, remoteMember);
          if (resolvedMember.id == localMember.id) {
            // Le membre local a gagné, mettre à jour Firestore
            if (localMember.lastSync == null ||
                (remoteMember.lastSync != null &&
                    localMember.lastSync!.isAfter(remoteMember.lastSync!))) {
              try {
                final updated = await remoteDataSource.updateMember(localMember);
                membersToUpdate.add(updated);
              } catch (e) {
                // En cas d'erreur, garder la version distante
                membersToUpdate.add(remoteMember);
              }
            } else {
              // Le membre distant a gagné, utiliser celui-ci
              membersToUpdate.add(remoteMember);
            }
          } else {
            // Le membre distant a gagné
            membersToUpdate.add(remoteMember);
          }
        }
      }

      // 4. Traiter les membres distants non présents localement
      for (final remoteMember in remoteMembers) {
        if (!localMap.containsKey(remoteMember.id)) {
          // Nouveau membre distant, ajouter localement
          membersToUpdate.add(remoteMember.copyWith(lastSync: now));
        }
      }

      // 5. Mettre à jour le cache local avec toutes les résolutions
      if (membersToUpdate.isNotEmpty) {
        await localDataSource.cacheMembers(membersToUpdate);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur de synchronisation: ${e.toString()}'));
    }
  }

  /// Résout un conflit entre une version locale et distante (Last-Write-Wins).
  MemberModel _resolveConflict(
    MemberModel localMember,
    MemberModel remoteMember,
  ) {
    // Si une version a un lastSync null, utiliser l'autre
    if (localMember.lastSync == null && remoteMember.lastSync != null) {
      return remoteMember;
    }
    if (remoteMember.lastSync == null && localMember.lastSync != null) {
      return localMember;
    }

    // Si les deux ont un lastSync, utiliser le plus récent (Last-Write-Wins)
    if (localMember.lastSync != null && remoteMember.lastSync != null) {
      if (localMember.lastSync!.isAfter(remoteMember.lastSync!)) {
        return localMember;
      } else {
        return remoteMember;
      }
    }

    // Si aucune n'a de lastSync, utiliser la version locale par défaut
    return localMember;
  }

  /// Récupère les membres locaux qui nécessitent une synchronisation.
  Future<List<MemberModel>> getUnsyncedMembers(String branchId) async {
    final allMembers = await localDataSource.getMembersByBranch(branchId);
    return allMembers.where((member) => member.lastSync == null).toList();
  }

  /// Force la synchronisation de tous les membres non synchronisés d'une branche.
  Future<Either<Failure, void>> forceSyncUnsyncedMembers(
    String branchId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final unsyncedMembers = await getUnsyncedMembers(branchId);
      final now = DateTime.now();
      final List<MemberModel> updatedMembers = [];

      for (final member in unsyncedMembers) {
        try {
          // Tenter de créer sur Firestore
          final created = await remoteDataSource.createMember(member);
          // Le createMember du remoteDataSource met déjà à jour lastSync
          updatedMembers.add(created);
        } catch (e) {
          // Si échec, peut-être que l'ID existe déjà, tenter une mise à jour
          try {
            final updated = await remoteDataSource.updateMember(member);
            // Le updateMember du remoteDataSource met déjà à jour lastSync
            updatedMembers.add(updated);
          } catch (e2) {
            // Ignorer si échec total
          }
        }
      }

      if (updatedMembers.isNotEmpty) {
        await localDataSource.cacheMembers(updatedMembers);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la synchronisation forcée: ${e.toString()}'));
    }
  }
}
