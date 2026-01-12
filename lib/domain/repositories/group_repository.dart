import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group.dart';

/// Interface du repository pour la gestion des groupes.
abstract class GroupRepository {
  /// Récupère tous les groupes.
  Future<Either<Failure, List<Group>>> getAllGroups();

  /// Récupère un groupe par son ID.
  Future<Either<Failure, Group>> getGroupById(String id);

  /// Crée un nouveau groupe.
  Future<Either<Failure, Group>> createGroup(Group group);

  /// Met à jour un groupe existant.
  Future<Either<Failure, Group>> updateGroup(Group group);

  /// Supprime un groupe.
  Future<Either<Failure, void>> deleteGroup(String id);
}
