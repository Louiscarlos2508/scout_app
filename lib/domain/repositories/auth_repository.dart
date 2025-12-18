import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Interface du repository pour l'authentification.
abstract class AuthRepository {
  /// Connecte un utilisateur.
  Future<Either<Failure, User>> login(String email, String password);

  /// Déconnecte l'utilisateur actuel.
  Future<Either<Failure, void>> logout();

  /// Récupère l'utilisateur actuellement connecté.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Vérifie si un utilisateur est connecté.
  Future<bool> isAuthenticated();
}

