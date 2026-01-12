import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour l'inscription d'un nouvel utilisateur.
class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  /// Inscrit un nouvel utilisateur (en attente de validation).
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      unitId: unitId,
      branchId: branchId,
    );
  }
}
