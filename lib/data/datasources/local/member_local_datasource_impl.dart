import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../domain/entities/member.dart' as entities;
import '../../../domain/entities/phone_number.dart';
import '../../../domain/entities/parent_contact.dart';
import '../../models/member_model.dart';
import 'drift_database.dart' as drift_db;
import 'database.dart' as db;
import 'member_local_datasource.dart';

/// Implémentation utilisant Drift sur mobile/desktop.
/// Sur le web, retourne des listes vides (Firebase est utilisé directement).
class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  db.AppDatabase? get _db {
    if (kIsWeb) return null;
    return drift_db.DriftDatabase.database;
  }

  @override
  Future<List<MemberModel>> getMembersByBranch(String branchId) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return [];
    }
    
    final members = await (_db!.select(_db!.members)
          ..where((m) => m.branchId.equals(branchId)))
        .get();

    final models = members.map((row) => _memberRowToModel(row)).toList();
    // Exclure les membres supprimés
    return models.where((m) => m.deletedAt == null).toList();
  }

  @override
  Future<List<MemberModel>> getDeletedMembers() async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return [];
    }
    
    // Note: On doit charger tous les membres et filtrer car Drift ne supporte pas directement
    // les requêtes avec deletedAt != null. On pourrait améliorer cela avec un index.
    final allMembers = await (_db!.select(_db!.members)).get();
    final models = allMembers.map((row) => _memberRowToModel(row)).toList();
    
    // Retourner uniquement les membres supprimés
    return models.where((m) => m.deletedAt != null).toList();
  }

  @override
  Future<MemberModel?> getMemberById(String id) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return null;
    }
    
    final member = await (_db!.select(_db!.members)
          ..where((m) => m.memberId.equals(id))
          ..limit(1))
        .getSingleOrNull();

    if (member == null) return null;

    return _memberRowToModel(member);
  }

  @override
  Future<void> cacheMember(MemberModel member) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.into(_db!.members).insertOnConflictUpdate(_memberModelToRow(member));
  }

  @override
  Future<void> cacheMembers(List<MemberModel> members) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.batch((batch) {
      for (final member in members) {
        batch.insert(_db!.members, _memberModelToRow(member), mode: InsertMode.replace);
      }
    });
  }

  @override
  Future<void> deleteMember(String id) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await (_db!.delete(_db!.members)..where((m) => m.memberId.equals(id))).go();
  }

  @override
  Future<void> clearCache() async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.delete(_db!.members).go();
  }

  /// Convertit un MemberRow en MemberModel
  MemberModel _memberRowToModel(db.Member row) {
    entities.MedicalInfo? medicalInfo;
    if (row.medicalInfoJson != null && row.medicalInfoJson!.isNotEmpty) {
      try {
        final json = jsonDecode(row.medicalInfoJson!) as Map<String, dynamic>;
        medicalInfo = entities.MedicalInfo(
          allergies: List<String>.from(json['allergies'] ?? []),
          illnesses: List<String>.from(json['illnesses'] ?? []),
          medications: List<String>.from(json['medications'] ?? []),
          bloodGroup: json['bloodGroup'] as String?,
          notes: json['notes'] as String?,
        );
      } catch (e) {
        // En cas d'erreur de parsing, medicalInfo reste null
      }
    }

    // Convertir parentPhone en parentContacts pour compatibilité
    final parentContacts = row.parentPhone != null && row.parentPhone!.isNotEmpty
        ? [
            ParentContact(
              name: '',
              phoneNumbers: [
                PhoneNumber(
                  number: row.parentPhone!,
                  type: PhoneType.regular,
                ),
              ],
              relation: ParentRelation.other,
            ),
          ]
        : <ParentContact>[];

    // Parser les données JSON pour phoneNumbers et parentContacts si disponibles
    // Pour l'instant, on utilise parentPhone pour compatibilité
    // TODO: Ajouter support pour phoneNumbers et parentContacts dans la table Drift
    
    final member = entities.Member(
      id: row.memberId,
      firstName: row.firstName,
      lastName: row.lastName,
      dateOfBirth: row.dateOfBirth,
      branchId: row.branchId,
      parentContacts: parentContacts,
      medicalInfo: medicalInfo,
      lastSync: row.lastSync,
      deletedAt: row.deletedAt,
      deletionReason: row.deletionReason,
    );

    return MemberModel.fromEntity(member);
  }

  /// Convertit un MemberModel en MembersCompanion pour insertion
  db.MembersCompanion _memberModelToRow(MemberModel member) {
    final medicalInfoJson = member.medicalInfo != null
        ? jsonEncode({
            'allergies': member.medicalInfo!.allergies,
            'illnesses': member.medicalInfo!.illnesses,
            'medications': member.medicalInfo!.medications,
            'bloodGroup': member.medicalInfo!.bloodGroup,
            'notes': member.medicalInfo!.notes,
          })
        : null;

    return db.MembersCompanion.insert(
      memberId: member.id,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      parentPhone: Value(member.parentPhone),
      lastSync: Value(member.lastSync),
      medicalInfoJson: Value(medicalInfoJson),
    );
  }
}
