import '../../../domain/entities/member.dart';
import '../../models/member_model.dart';
import '../local/member_local_datasource.dart';
import '../../../core/errors/exceptions.dart';

/// Source de données distante pour les membres (Firestore).
abstract class MemberRemoteDataSource {
  /// Récupère tous les membres d'une branche depuis Firestore.
  Future<List<MemberModel>> getMembersByBranch(String branchId);

  /// Récupère un membre par son ID.
  Future<MemberModel> getMemberById(String id);

  /// Crée un nouveau membre sur Firestore.
  Future<MemberModel> createMember(MemberModel member);

  /// Met à jour un membre sur Firestore.
  Future<MemberModel> updateMember(MemberModel member);

  /// Supprime un membre de Firestore.
  Future<void> deleteMember(String id);
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  // TODO: Implémenter avec Firestore
  @override
  Future<List<MemberModel>> getMembersByBranch(String branchId) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<MemberModel> getMemberById(String id) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<MemberModel> createMember(MemberModel member) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<MemberModel> updateMember(MemberModel member) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMember(String id) async {
    // TODO: Implémenter avec Firestore
    throw UnimplementedError();
  }
}

