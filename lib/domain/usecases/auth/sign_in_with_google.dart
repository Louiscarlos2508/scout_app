import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour la connexion avec Google.
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  /// Connecte un utilisateur avec Google.
  Future<Either<Failure, User>> call() async {
    return await repository.signInWithGoogle();
  }
}
