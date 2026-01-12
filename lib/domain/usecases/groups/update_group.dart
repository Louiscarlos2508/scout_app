import 'package:dartz/dartz.dart';
import '../../entities/group.dart';
import '../../repositories/group_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour mettre à jour un groupe.
class UpdateGroup {
  final GroupRepository repository;

  UpdateGroup(this.repository);

  /// Met à jour un groupe existant.
  Future<Either<Failure, Group>> call(Group group) async {
    return await repository.updateGroup(group);
  }
}
