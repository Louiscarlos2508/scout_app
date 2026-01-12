import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour approuver un utilisateur et définir son rôle (admin uniquement).
class ApproveUser {
  final AuthRepository repository;

  ApproveUser(this.repository);

  /// Approuve un utilisateur et définit son rôle, unité et branche.
  Future<Either<Failure, User>> call(
    String userId,
    UserRole role, {
    String? unitId,
    String? branchId,
  }) async {
    return await repository.approveUser(
      userId,
      role,
      unitId: unitId,
      branchId: branchId,
    );
  }
}
