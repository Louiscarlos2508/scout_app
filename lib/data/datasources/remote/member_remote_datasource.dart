import '../../models/member_model.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/firestore_constants.dart';
import 'firebase_service.dart';

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

  /// Supprime un membre de Firestore (soft delete).
  Future<void> deleteMember(String id);

  /// Récupère tous les membres supprimés.
  Future<List<MemberModel>> getDeletedMembers();
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  @override
  Future<List<MemberModel>> getMembersByBranch(String branchId) async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.membersCollection,
        whereField: FirestoreConstants.memberBranchIdField,
        whereValue: branchId,
      );

      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MemberModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch members: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> getMemberById(String id) async {
    try {
      final doc = await FirebaseService.getDocument(
        FirestoreConstants.membersCollection,
        id,
      );

      if (doc == null || !doc.exists) {
        throw ServerException('Member not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return MemberModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch member: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> createMember(MemberModel member) async {
    try {
      final json = member.toJson();
      json[FirestoreConstants.memberLastSyncField] = DateTime.now().toIso8601String();

      await FirebaseService.setData(
        FirestoreConstants.membersCollection,
        member.id,
        json,
      );

      return member.copyWith(lastSync: DateTime.now());
    } catch (e) {
      throw ServerException('Failed to create member: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> updateMember(MemberModel member) async {
    try {
      final json = member.toJson();
      json[FirestoreConstants.memberLastSyncField] = DateTime.now().toIso8601String();

      await FirebaseService.updateData(
        FirestoreConstants.membersCollection,
        member.id,
        json,
      );

      return member.copyWith(lastSync: DateTime.now());
    } catch (e) {
      throw ServerException('Failed to update member: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    // Cette méthode n'est plus utilisée car on fait un soft delete via updateMember
    // Gardée pour compatibilité mais ne devrait pas être appelée
    throw ServerException('Use updateMember for soft delete instead');
  }

  @override
  Future<List<MemberModel>> getDeletedMembers() async {
    try {
      // Récupérer tous les membres et filtrer ceux qui ont deletedAt != null
      // Note: Firestore ne supporte pas directement les requêtes avec != null
      // On doit récupérer tous les membres et filtrer côté client
      final allDocs = await FirebaseService.getCollection(
        FirestoreConstants.membersCollection,
      );

      final deletedMembers = allDocs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MemberModel.fromJson(data);
          })
          .where((member) => member.deletedAt != null)
          .toList();

      return deletedMembers;
    } catch (e) {
      throw ServerException('Failed to fetch deleted members: ${e.toString()}');
    }
  }
}

