import 'package:dartz/dartz.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

/// Implémentation du repository Branch.
class BranchRepositoryImpl implements BranchRepository {
  // TODO: Implémenter avec les datasources appropriés
  @override
  Future<Either<Failure, List<Branch>>> getAllBranches() async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Branch>> getBranchById(String id) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Branch>>> getBranchesByUnit(String unitId) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }
}

