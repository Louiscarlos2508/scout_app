import 'package:dartz/dartz.dart';
import '../../entities/unit.dart' as entity;
import '../../repositories/unit_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour récupérer toutes les unités.
class GetAllUnits {
  final UnitRepository repository;

  GetAllUnits(this.repository);

  /// Récupère toutes les unités du système.
  Future<Either<Failure, List<entity.Unit>>> call() async {
    return await repository.getAllUnits();
  }
}
