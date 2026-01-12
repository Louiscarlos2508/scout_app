import 'package:dartz/dartz.dart';
import '../../entities/group.dart';
import '../../repositories/group_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour récupérer tous les groupes.
class GetAllGroups {
  final GroupRepository repository;

  GetAllGroups(this.repository);

  /// Récupère tous les groupes du système.
  Future<Either<Failure, List<Group>>> call() async {
    return await repository.getAllGroups();
  }
}
