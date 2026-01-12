import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour créer un utilisateur (admin uniquement).
class CreateUser {
  final AuthRepository repository;

  CreateUser(this.repository);

  /// Crée un nouvel utilisateur avec email et mot de passe.
  /// Retourne l'utilisateur créé.
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required UserRole role,
    required String unitId,
    required String branchId,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final credential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(ServerFailure('Failed to create user in Firebase Auth'));
      }

      // Créer le document utilisateur dans Firestore
      final user = User(
        id: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        role: role,
        status: UserStatus.approved, // Les utilisateurs créés par l'admin sont directement approuvés
        unitId: unitId,
        branchId: branchId,
      );

      final result = await repository.createUser(user);
      return result;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Erreur lors de la création de l\'utilisateur';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Cet email est déjà utilisé';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'weak-password':
          message = 'Mot de passe trop faible';
          break;
        default:
          message = e.message ?? message;
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure('Erreur: ${e.toString()}'));
    }
  }
}
