import 'package:dartz/dartz.dart';
import '../../repositories/unit_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case pour supprimer une unité.
class DeleteUnit {
  final UnitRepository repository;

  DeleteUnit(this.repository);

  /// Supprime une unité.
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteUnit(id);
  }
}
