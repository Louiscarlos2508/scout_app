import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/branch.dart';

/// Interface du repository pour la gestion des branches.
abstract class BranchRepository {
  /// Récupère toutes les branches.
  Future<Either<Failure, List<Branch>>> getAllBranches();

  /// Récupère une branche par son ID.
  Future<Either<Failure, Branch>> getBranchById(String id);

  /// Récupère les branches d'une unité.
  Future<Either<Failure, List<Branch>>> getBranchesByUnit(String unitId);
}

