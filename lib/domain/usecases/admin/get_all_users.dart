import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour récupérer tous les utilisateurs (admin uniquement).
class GetAllUsers {
  final AuthRepository repository;

  GetAllUsers(this.repository);

  /// Récupère tous les utilisateurs du système.
  /// Nécessite les droits administrateur.
  Future<Either<Failure, List<User>>> call() async {
    try {
      final users = await repository.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
