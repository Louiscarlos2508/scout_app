import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

/// Implémentation du repository Auth avec Firebase Auth.
class AuthRepositoryImpl implements AuthRepository {
  // TODO: Implémenter avec Firebase Auth
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    // TODO: Implémenter avec Firebase Auth
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // TODO: Implémenter avec Firebase Auth
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    // TODO: Implémenter avec Firebase Auth
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Implémenter avec Firebase Auth
    throw UnimplementedError();
  }
}

