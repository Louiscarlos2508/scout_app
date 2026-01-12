import '../../../../domain/entities/unit.dart';
import '../../models/unit_model.dart';
import '../../../core/constants/firestore_constants.dart';
import 'firebase_service.dart';
import '../../../core/errors/exceptions.dart';

/// Source de données distante pour les unités (Firestore).
abstract class UnitRemoteDataSource {
  Future<List<UnitModel>> getAllUnits();
  Future<UnitModel?> getUnitById(String id);
  Future<List<UnitModel>> getUnitsByGroup(String groupId);
  Future<UnitModel> createUnit(UnitModel unit);
  Future<UnitModel> updateUnit(UnitModel unit);
  Future<void> deleteUnit(String id);
}

class UnitRemoteDataSourceImpl implements UnitRemoteDataSource {
  @override
  Future<List<UnitModel>> getAllUnits() async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.unitsCollection,
      );
      return docs
          .map((doc) => UnitModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get units: ${e.toString()}');
    }
  }

  @override
  Future<UnitModel?> getUnitById(String id) async {
    try {
      final doc = await FirebaseService.getDocument(
        FirestoreConstants.unitsCollection,
        id,
      );
      if (doc == null) return null;
      return UnitModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to get unit: ${e.toString()}');
    }
  }

  @override
  Future<List<UnitModel>> getUnitsByGroup(String groupId) async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.unitsCollection,
        whereField: 'groupId',
        whereValue: groupId,
      );
      return docs
          .map((doc) => UnitModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get units by group: ${e.toString()}');
    }
  }

  @override
  Future<UnitModel> createUnit(UnitModel unit) async {
    try {
      final json = unit.toJson();
      await FirebaseService.setData(
        FirestoreConstants.unitsCollection,
        unit.id,
        json,
      );
      return unit;
    } catch (e) {
      throw ServerException('Failed to create unit: ${e.toString()}');
    }
  }

  @override
  Future<UnitModel> updateUnit(UnitModel unit) async {
    try {
      final json = unit.toJson();
      await FirebaseService.updateData(
        FirestoreConstants.unitsCollection,
        unit.id,
        json,
      );
      return unit;
    } catch (e) {
      throw ServerException('Failed to update unit: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      await FirebaseService.deleteData(
        FirestoreConstants.unitsCollection,
        id,
      );
    } catch (e) {
      throw ServerException('Failed to delete unit: ${e.toString()}');
    }
  }
}
