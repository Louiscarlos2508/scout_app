import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour compléter les informations d'un utilisateur Google.
class CompleteGoogleUserInfo {
  final AuthRepository repository;

  CompleteGoogleUserInfo(this.repository);

  /// Complète les informations d'un utilisateur Google.
  Future<Either<Failure, User>> call({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  }) async {
    return await repository.completeGoogleUserInfo(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      unitId: unitId,
      branchId: branchId,
    );
  }
}
