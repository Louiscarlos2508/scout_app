import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour récupérer les utilisateurs en attente de validation (admin uniquement).
class GetPendingUsers {
  final AuthRepository repository;

  GetPendingUsers(this.repository);

  /// Récupère tous les utilisateurs en attente de validation.
  Future<Either<Failure, List<User>>> call() async {
    try {
      final users = await repository.getPendingUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
