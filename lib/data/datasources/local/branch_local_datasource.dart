import '../../../domain/entities/branch.dart';
// Export unique implementation using Drift (works on all platforms)
export 'branch_local_datasource_impl.dart';

/// Source de données locale pour les branches.
/// 
/// Utilise Drift sur toutes les plateformes (mobile, desktop, web).
abstract class BranchLocalDataSource {
  /// Récupère toutes les branches.
  Future<List<Branch>> getAllBranches();

  /// Récupère une branche par son ID.
  Future<Branch?> getBranchById(String id);

  /// Sauvegarde une branche localement.
  Future<void> cacheBranch(Branch branch);

  /// Sauvegarde plusieurs branches localement.
  Future<void> cacheBranches(List<Branch> branches);

  /// Supprime une branche du cache local.
  Future<void> deleteBranch(String id);

  /// Supprime toutes les branches du cache local.
  Future<void> clearCache();
}
