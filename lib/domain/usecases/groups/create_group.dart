import 'package:dartz/dartz.dart';
import '../../entities/group.dart';
import '../../repositories/group_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour créer un groupe.
class CreateGroup {
  final GroupRepository repository;

  CreateGroup(this.repository);

  /// Crée un nouveau groupe.
  Future<Either<Failure, Group>> call(Group group) async {
    return await repository.createGroup(group);
  }
}
