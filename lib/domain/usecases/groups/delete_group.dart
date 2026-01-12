import 'package:dartz/dartz.dart';
import '../../repositories/group_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour supprimer un groupe.
class DeleteGroup {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  /// Supprime un groupe.
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteGroup(id);
  }
}
