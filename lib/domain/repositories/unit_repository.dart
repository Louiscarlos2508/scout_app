import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/unit.dart' as entity;

/// Interface du repository pour la gestion des unités.
abstract class UnitRepository {
  /// Récupère toutes les unités.
  Future<Either<Failure, List<entity.Unit>>> getAllUnits();

  /// Récupère une unité par son ID.
  Future<Either<Failure, entity.Unit>> getUnitById(String id);

  /// Récupère les unités d'un groupe.
  Future<Either<Failure, List<entity.Unit>>> getUnitsByGroup(String groupId);

  /// Crée une nouvelle unité.
  Future<Either<Failure, entity.Unit>> createUnit(entity.Unit unit);

  /// Met à jour une unité existante.
  Future<Either<Failure, entity.Unit>> updateUnit(entity.Unit unit);

  /// Supprime une unité.
  Future<Either<Failure, void>> deleteUnit(String id);
}
