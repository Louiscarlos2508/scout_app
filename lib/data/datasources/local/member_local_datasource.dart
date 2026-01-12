import '../../models/member_model.dart';
// Export unique implementation using Drift (works on all platforms)
export 'member_local_datasource_impl.dart';

/// Source de données locale pour les membres.
/// 
/// Utilise Drift sur toutes les plateformes (mobile, desktop, web).
abstract class MemberLocalDataSource {
  /// Récupère tous les membres d'une branche depuis le stockage local.
  Future<List<MemberModel>> getMembersByBranch(String branchId);

  /// Récupère un membre par son ID.
  Future<MemberModel?> getMemberById(String id);

  /// Sauvegarde un membre localement.
  Future<void> cacheMember(MemberModel member);

  /// Sauvegarde plusieurs membres localement.
  Future<void> cacheMembers(List<MemberModel> members);

  /// Supprime un membre du cache local.
  Future<void> deleteMember(String id);

  /// Récupère tous les membres supprimés depuis le stockage local.
  Future<List<MemberModel>> getDeletedMembers();

  /// Supprime tous les membres du cache local.
  Future<void> clearCache();
}
