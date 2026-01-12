import 'package:dartz/dartz.dart';
import '../../entities/unit.dart' as entity;
import '../../repositories/unit_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour mettre à jour une unité.
class UpdateUnit {
  final UnitRepository repository;

  UpdateUnit(this.repository);

  /// Met à jour une unité existante.
  Future<Either<Failure, entity.Unit>> call(entity.Unit unit) async {
    return await repository.updateUnit(unit);
  }
}
