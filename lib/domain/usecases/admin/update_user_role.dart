import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour mettre à jour le rôle d'un utilisateur (admin uniquement).
class UpdateUserRole {
  final AuthRepository repository;

  UpdateUserRole(this.repository);

  /// Met à jour le rôle d'un utilisateur.
  /// Nécessite les droits administrateur.
  Future<Either<Failure, User>> call(String userId, UserRole newRole) async {
    try {
      final user = await repository.updateUserRole(userId, newRole);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
