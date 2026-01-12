import 'package:dartz/dartz.dart';
import '../../entities/unit.dart' as entity;
import '../../repositories/unit_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour créer une unité.
class CreateUnit {
  final UnitRepository repository;

  CreateUnit(this.repository);

  /// Crée une nouvelle unité.
  Future<Either<Failure, entity.Unit>> call(entity.Unit unit) async {
    return await repository.createUnit(unit);
  }
}
