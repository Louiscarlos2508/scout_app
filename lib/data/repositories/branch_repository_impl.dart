import 'package:dartz/dartz.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/local/branch_local_datasource.dart';

/// Implémentation du repository Branch avec Drift.
class BranchRepositoryImpl implements BranchRepository {
  final BranchLocalDataSource localDataSource;

  BranchRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Branch>>> getAllBranches() async {
    try {
      final branches = await localDataSource.getAllBranches();
      return Right(branches);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Branch>> getBranchById(String id) async {
    try {
      final branch = await localDataSource.getBranchById(id);
      if (branch == null) {
        return Left(CacheFailure('Branch not found'));
      }
      return Right(branch);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Branch>>> getBranchesByUnit(String unitId) async {
    // Pour l'instant, toutes les branches appartiennent à toutes les unités
    return getAllBranches();
  }
}

