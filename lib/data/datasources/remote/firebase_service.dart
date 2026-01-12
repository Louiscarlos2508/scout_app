import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Firebase centralisé pour les opérations Firestore.
class FirebaseService {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Récupère une collection.
  static CollectionReference collection(String path) {
    return firestore.collection(path);
  }

  /// Récupère un document.
  static DocumentReference doc(String collectionPath, String docId) {
    return firestore.collection(collectionPath).doc(docId);
  }

  /// Récupère tous les documents d'une collection avec une requête.
  static Future<List<QueryDocumentSnapshot>> getCollection(
    String collectionPath, {
    String? whereField,
    dynamic whereValue,
    int? limit,
  }) async {
    try {
      Query query = collection(collectionPath);
      
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la collection $collectionPath: ${e.toString()}');
    }
  }

  /// Récupère un document par son ID.
  static Future<DocumentSnapshot?> getDocument(
    String collectionPath,
    String docId,
  ) async {
    try {
      final docRef = doc(collectionPath, docId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists ? docSnapshot : null;
    } catch (e) {
      // Ne pas masquer l'erreur, la propager pour un meilleur diagnostic
      throw Exception('Erreur lors de la récupération du document $collectionPath/$docId: ${e.toString()}');
    }
  }

  /// Crée ou met à jour un document.
  static Future<void> setData(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await doc(collectionPath, docId).set(data, SetOptions(merge: true));
  }

  /// Met à jour un document existant.
  static Future<void> updateData(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await doc(collectionPath, docId).update(data);
  }

  /// Supprime un document.
  static Future<void> deleteData(
    String collectionPath,
    String docId,
  ) async {
    await doc(collectionPath, docId).delete();
  }

  /// Batch write pour les opérations multiples atomiques.
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = firestore.batch();
    
    for (final op in operations) {
      final collectionPath = op['collection'] as String;
      final docId = op['docId'] as String;
      final action = op['action'] as String;
      final data = op['data'] as Map<String, dynamic>?;
      
      final docRef = doc(collectionPath, docId);
      
      switch (action) {
        case 'set':
          batch.set(docRef, data ?? {});
          break;
        case 'update':
          batch.update(docRef, data ?? {});
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }
    
    await batch.commit();
  }
}

