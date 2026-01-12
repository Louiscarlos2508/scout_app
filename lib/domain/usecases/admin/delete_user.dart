import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour supprimer un utilisateur (admin uniquement).
class DeleteUser {
  final AuthRepository repository;

  DeleteUser(this.repository);

  /// Supprime un utilisateur du système.
  /// Nécessite les droits administrateur.
  Future<Either<Failure, void>> call(String userId) async {
    try {
      await repository.deleteUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
