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

  /// Récupère tous les utilisateurs (admin uniquement).
  Future<List<User>> getAllUsers();

  /// Met à jour le rôle d'un utilisateur (admin uniquement).
  Future<User> updateUserRole(String userId, UserRole newRole);

  /// Supprime un utilisateur (admin uniquement).
  Future<void> deleteUser(String userId);

  /// Crée un nouvel utilisateur (admin uniquement).
  Future<Either<Failure, User>> createUser(User user);

  /// Inscription d'un nouvel utilisateur (en attente de validation).
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  });

  /// Récupère les utilisateurs en attente de validation (admin uniquement).
  Future<List<User>> getPendingUsers();

  /// Valide un utilisateur et définit son rôle, unité et branche (admin uniquement).
  Future<Either<Failure, User>> approveUser(
    String userId,
    UserRole role, {
    String? unitId,
    String? branchId,
  });

  /// Connexion avec Google.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Complète les informations d'un utilisateur Google.
  Future<Either<Failure, User>> completeGoogleUserInfo({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  });
}

