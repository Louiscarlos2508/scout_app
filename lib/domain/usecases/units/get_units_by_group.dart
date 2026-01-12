import 'package:dartz/dartz.dart';
import '../../entities/unit.dart' as entity;
import '../../repositories/unit_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour récupérer les unités d'un groupe.
class GetUnitsByGroup {
  final UnitRepository repository;

  GetUnitsByGroup(this.repository);

  /// Récupère toutes les unités d'un groupe.
  Future<Either<Failure, List<entity.Unit>>> call(String groupId) async {
    return await repository.getUnitsByGroup(groupId);
  }
}
