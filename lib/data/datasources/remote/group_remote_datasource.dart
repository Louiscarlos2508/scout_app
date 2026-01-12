import '../../../../domain/entities/group.dart';
import '../../models/group_model.dart';
import '../../../core/constants/firestore_constants.dart';
import 'firebase_service.dart';
import '../../../core/errors/exceptions.dart';

/// Source de données distante pour les groupes (Firestore).
abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getAllGroups();
  Future<GroupModel?> getGroupById(String id);
  Future<GroupModel> createGroup(GroupModel group);
  Future<GroupModel> updateGroup(GroupModel group);
  Future<void> deleteGroup(String id);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  @override
  Future<List<GroupModel>> getAllGroups() async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.groupsCollection,
      );
      return docs
          .map((doc) =>
              GroupModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get groups: ${e.toString()}');
    }
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    try {
      final doc = await FirebaseService.getDocument(
        FirestoreConstants.groupsCollection,
        id,
      );
      if (doc == null) return null;
      return GroupModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to get group: ${e.toString()}');
    }
  }

  @override
  Future<GroupModel> createGroup(GroupModel group) async {
    try {
      final json = group.toJson();
      await FirebaseService.setData(
        FirestoreConstants.groupsCollection,
        group.id,
        json,
      );
      return group;
    } catch (e) {
      throw ServerException('Failed to create group: ${e.toString()}');
    }
  }

  @override
  Future<GroupModel> updateGroup(GroupModel group) async {
    try {
      final json = group.toJson();
      await FirebaseService.updateData(
        FirestoreConstants.groupsCollection,
        group.id,
        json,
      );
      return group;
    } catch (e) {
      throw ServerException('Failed to update group: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      await FirebaseService.deleteData(
        FirestoreConstants.groupsCollection,
        id,
      );
    } catch (e) {
      throw ServerException('Failed to delete group: ${e.toString()}');
    }
  }
}
