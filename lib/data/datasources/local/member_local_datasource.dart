import '../../../domain/entities/member.dart';
import '../../models/member_model.dart';

/// Source de données locale pour les membres (Isar).
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

  /// Supprime tous les membres du cache local.
  Future<void> clearCache();
}

class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  // TODO: Implémenter avec Isar
  @override
  Future<List<MemberModel>> getMembersByBranch(String branchId) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<MemberModel?> getMemberById(String id) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> cacheMember(MemberModel member) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> cacheMembers(List<MemberModel> members) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMember(String id) async {
    // TODO: Implémenter
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() async {
    // TODO: Implémenter
    throw UnimplementedError();
  }
}

