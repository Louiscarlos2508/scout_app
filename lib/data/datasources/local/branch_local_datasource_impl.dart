import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../domain/entities/branch.dart' as entities;
import '../../../core/data/default_branches.dart';
import 'drift_database.dart' as drift_db;
import 'database.dart' as db;
import 'branch_local_datasource.dart';

/// Implémentation utilisant Drift sur mobile/desktop.
/// Sur le web, retourne les branches par défaut (codées en dur).
/// 
/// Les branches sont codées en dur et ne sont pas synchronisées depuis Firestore.
/// Elles sont initialisées automatiquement si le cache est vide.
class BranchLocalDataSourceImpl implements BranchLocalDataSource {
  db.AppDatabase? get _db {
    if (kIsWeb) return null;
    return drift_db.DriftDatabase.database;
  }
  bool _initialized = false;

  /// Initialise les branches par défaut si le cache est vide.
  Future<void> _ensureBranchesInitialized() async {
    if (_initialized || kIsWeb || _db == null) return;

    final existingBranches = await (_db!.select(_db!.branches)).get();
    
    // Si aucune branche n'existe, initialiser avec les branches codées en dur
    if (existingBranches.isEmpty) {
      final defaultBranches = DefaultBranches.allBranches;
      await cacheBranches(defaultBranches);
    }
    
    _initialized = true;
  }

  @override
  Future<List<entities.Branch>> getAllBranches() async {
    // Sur le web, retourner directement les branches par défaut
    if (kIsWeb || _db == null) {
      return DefaultBranches.allBranches;
    }
    
    // S'assurer que les branches sont initialisées
    await _ensureBranchesInitialized();
    
    final branches = await (_db!.select(_db!.branches)).get();

    return branches.map((row) => _branchRowToEntity(row)).toList();
  }

  @override
  Future<entities.Branch?> getBranchById(String id) async {
    // Sur le web, chercher dans les branches par défaut
    if (kIsWeb || _db == null) {
      try {
        return DefaultBranches.allBranches.firstWhere(
          (branch) => branch.id == id,
        );
      } catch (e) {
        return null;
      }
    }
    
    // S'assurer que les branches sont initialisées
    await _ensureBranchesInitialized();
    
    final branch = await (_db!.select(_db!.branches)
          ..where((b) => b.branchId.equals(id))
          ..limit(1))
        .getSingleOrNull();

    if (branch == null) return null;

    return _branchRowToEntity(branch);
  }

  @override
  Future<void> cacheBranch(entities.Branch branch) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.into(_db!.branches).insertOnConflictUpdate(_branchEntityToRow(branch));
  }

  @override
  Future<void> cacheBranches(List<entities.Branch> branches) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.batch((batch) {
      for (final branch in branches) {
        batch.insert(_db!.branches, _branchEntityToRow(branch), mode: InsertMode.replace);
      }
    });
  }

  @override
  Future<void> deleteBranch(String id) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await (_db!.delete(_db!.branches)..where((b) => b.branchId.equals(id))).go();
  }

  @override
  Future<void> clearCache() async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.delete(_db!.branches).go();
  }

  /// Convertit un BranchRow (type généré par Drift) en Branch entity
  entities.Branch _branchRowToEntity(db.Branche row) {
    return entities.Branch(
      id: row.branchId,
      name: row.name,
      color: row.color,
      minAge: row.minAge,
      maxAge: row.maxAge,
    );
  }

  /// Convertit une Branch entity en BranchesCompanion pour insertion
  db.BranchesCompanion _branchEntityToRow(entities.Branch branch) {
    return db.BranchesCompanion.insert(
      branchId: branch.id,
      name: branch.name,
      color: branch.color,
      minAge: branch.minAge,
      maxAge: branch.maxAge,
    );
  }
}
