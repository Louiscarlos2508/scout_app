import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/member_local_datasource.dart';
import '../../data/datasources/local/attendance_local_datasource.dart';
import '../../data/datasources/remote/member_remote_datasource.dart';
import '../../data/datasources/remote/attendance_remote_datasource.dart';
import '../../data/models/member_model.dart';
import '../../data/models/attendance_model.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/data/default_branches.dart';
import '../../data/datasources/remote/firebase_service.dart' as firebase_svc;

/// Service de synchronisation en temps réel entre Firestore et Drift.
/// 
/// Synchronisation bidirectionnelle :
/// - Firestore → Local : Écoute les changements Firestore et met à jour Drift automatiquement
/// - Local → Firestore : Synchronise périodiquement les données non synchronisées (lastSync == null)
/// 
/// Note: Les branches sont codées en dur et ne sont pas synchronisées depuis Firestore.
class RealtimeSyncService {
  final MemberLocalDataSource _memberLocalDataSource;
  final AttendanceLocalDataSource _attendanceLocalDataSource;
  final MemberRemoteDataSource _memberRemoteDataSource;
  final AttendanceRemoteDataSource _attendanceRemoteDataSource;
  
  StreamSubscription<QuerySnapshot>? _membersSubscription;
  StreamSubscription<QuerySnapshot>? _attendanceSubscription;
  Timer? _syncToFirestoreTimer;

  /// Stream pour notifier quand les branches sont synchronisées
  final _branchesSyncedController = StreamController<void>.broadcast();
  Stream<void> get branchesSynced => _branchesSyncedController.stream;

  /// Stream pour notifier quand les membres sont synchronisés
  final _membersSyncedController = StreamController<void>.broadcast();
  Stream<void> get membersSynced => _membersSyncedController.stream;

  /// Stream pour notifier quand les sessions sont synchronisées
  final _attendanceSyncedController = StreamController<void>.broadcast();
  Stream<void> get attendanceSynced => _attendanceSyncedController.stream;

  RealtimeSyncService({
    required MemberLocalDataSource memberLocalDataSource,
    required AttendanceLocalDataSource attendanceLocalDataSource,
    required MemberRemoteDataSource memberRemoteDataSource,
    required AttendanceRemoteDataSource attendanceRemoteDataSource,
  })  : _memberLocalDataSource = memberLocalDataSource,
        _attendanceLocalDataSource = attendanceLocalDataSource,
        _memberRemoteDataSource = memberRemoteDataSource,
        _attendanceRemoteDataSource = attendanceRemoteDataSource;

  /// Démarre la synchronisation en temps réel.
  /// 
  /// Note: Les branches sont codées en dur et ne sont pas synchronisées depuis Firestore.
  /// Seuls les membres et les sessions sont synchronisés.
  Future<void> startSync() async {
    // Les branches ne sont plus synchronisées depuis Firestore
    // Elles sont codées en dur et initialisées automatiquement dans BranchLocalDataSource

    // Synchroniser tous les membres
    await _syncAllMembers();
    _membersSubscription = firebase_svc.FirebaseService
        .collection(FirestoreConstants.membersCollection)
        .snapshots()
        .listen((snapshot) async {
      await _handleMembersSnapshot(snapshot);
    });

    // Synchroniser toutes les sessions
    await _syncAllAttendance();
    _attendanceSubscription = firebase_svc.FirebaseService
        .collection(FirestoreConstants.attendanceCollection)
        .snapshots()
        .listen((snapshot) async {
      await _handleAttendanceSnapshot(snapshot);
    });

    // Notifier que les branches sont disponibles (codées en dur)
    if (!_branchesSyncedController.isClosed) {
      _branchesSyncedController.add(null);
    }

    // Démarrer la synchronisation périodique Local → Firestore (toutes les 30 secondes)
    _syncToFirestoreTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _syncLocalToFirestore(),
    );

    // Synchroniser immédiatement une première fois
    _syncLocalToFirestore();
  }

  /// Arrête la synchronisation en temps réel.
  Future<void> stopSync() async {
    await _membersSubscription?.cancel();
    await _attendanceSubscription?.cancel();
    _syncToFirestoreTimer?.cancel();
    
    await _branchesSyncedController.close();
    await _membersSyncedController.close();
    await _attendanceSyncedController.close();
  }

  // Les méthodes de synchronisation des branches ont été supprimées
  // car les branches sont maintenant codées en dur dans DefaultBranches
  // et initialisées automatiquement par BranchLocalDataSourceImpl

  /// Synchronise initialement tous les membres depuis Firestore.
  Future<void> _syncAllMembers() async {
    try {
      final docs = await firebase_svc.FirebaseService.getCollection(
        FirestoreConstants.membersCollection,
      );
      
      final members = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MemberModel.fromJson(data);
      }).toList();
      
      if (members.isNotEmpty) {
        await _memberLocalDataSource.cacheMembers(members);
        // Notifier que les membres sont synchronisés
        if (!_membersSyncedController.isClosed) {
          _membersSyncedController.add(null);
        }
      }
    } catch (e) {
      debugPrint('Error syncing all members: $e');
    }
  }

  /// Traite les changements de membres depuis Firestore.
  Future<void> _handleMembersSnapshot(QuerySnapshot snapshot) async {
    try {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>;
        final member = MemberModel.fromJson(data);
        
        if (change.type == DocumentChangeType.added || 
            change.type == DocumentChangeType.modified) {
          await _memberLocalDataSource.cacheMember(member);
        } else if (change.type == DocumentChangeType.removed) {
          await _memberLocalDataSource.deleteMember(member.id);
        }
      }
    } catch (e) {
      debugPrint('Error handling members snapshot: $e');
    }
  }

  /// Synchronise initialement toutes les sessions depuis Firestore.
  Future<void> _syncAllAttendance() async {
    try {
      final docs = await firebase_svc.FirebaseService.getCollection(
        FirestoreConstants.attendanceCollection,
      );
      
      final sessions = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AttendanceModel.fromJson(data);
      }).toList();
      
      if (sessions.isNotEmpty) {
        await _attendanceLocalDataSource.cacheAttendanceList(sessions);
        // Notifier que les sessions sont synchronisées
        if (!_attendanceSyncedController.isClosed) {
          _attendanceSyncedController.add(null);
        }
      }
    } catch (e) {
      debugPrint('Error syncing all attendance: $e');
    }
  }

  /// Traite les changements de sessions depuis Firestore.
  Future<void> _handleAttendanceSnapshot(QuerySnapshot snapshot) async {
    try {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>;
        final session = AttendanceModel.fromJson(data);
        
        if (change.type == DocumentChangeType.added || 
            change.type == DocumentChangeType.modified) {
          await _attendanceLocalDataSource.cacheAttendance(session);
        } else if (change.type == DocumentChangeType.removed) {
          await _attendanceLocalDataSource.deleteAttendance(session.id);
        }
      }
    } catch (e) {
      debugPrint('Error handling attendance snapshot: $e');
    }
  }

  /// Synchronise les données non synchronisées de Local → Firestore.
  /// 
  /// Cette méthode est appelée périodiquement pour synchroniser les données
  /// créées ou modifiées en mode offline vers Firestore.
  Future<void> _syncLocalToFirestore() async {
    try {
      // Synchroniser les membres non synchronisés
      await _syncUnsyncedMembers();

      // Synchroniser les sessions non synchronisées
      await _syncUnsyncedAttendance();
    } catch (e) {
      debugPrint('Error syncing local to Firestore: $e');
    }
  }

  /// Synchronise les membres non synchronisés (lastSync == null) vers Firestore.
  Future<void> _syncUnsyncedMembers() async {
    try {
      // Récupérer toutes les branches codées en dur
      final branches = DefaultBranches.allBranches;
      int totalSynced = 0;

      for (final branch in branches) {
        // Récupérer tous les membres de cette branche
        final members = await _memberLocalDataSource.getMembersByBranch(branch.id);

        // Filtrer les membres non synchronisés (lastSync == null)
        final unsyncedMembers = members.where((m) => m.lastSync == null).toList();

        for (final member in unsyncedMembers) {
          try {
            // Normaliser le branchId du membre si nécessaire
            final normalizedBranchId = DefaultBranches.normalizeBranchId(member.branchId);
            final memberWithNormalizedBranch = member.copyWith(branchId: normalizedBranchId);

            // Tenter de créer sur Firestore
            final created = await _memberRemoteDataSource.createMember(memberWithNormalizedBranch);
            // Mettre à jour le cache local avec lastSync
            await _memberLocalDataSource.cacheMember(created);
            
            totalSynced++;
            debugPrint('✅ Membre synchronisé vers Firestore: ${member.id}');
          } catch (e) {
            // Si échec (peut-être que l'ID existe déjà), tenter une mise à jour
            try {
              final normalizedBranchId = DefaultBranches.normalizeBranchId(member.branchId);
              final memberWithNormalizedBranch = member.copyWith(branchId: normalizedBranchId);
              
              final updated = await _memberRemoteDataSource.updateMember(memberWithNormalizedBranch);
              await _memberLocalDataSource.cacheMember(updated);
              
              totalSynced++;
              debugPrint('✅ Membre mis à jour sur Firestore: ${member.id}');
            } catch (e2) {
              debugPrint('⚠️ Impossible de synchroniser le membre ${member.id}: $e2');
            }
          }
        }
      }

      // Notifier que les membres ont été synchronisés si des données ont été synchronisées
      if (totalSynced > 0 && !_membersSyncedController.isClosed) {
        _membersSyncedController.add(null);
      }
    } catch (e) {
      debugPrint('Error syncing unsynced members: $e');
    }
  }

  /// Synchronise les sessions non synchronisées (lastSync == null) vers Firestore.
  Future<void> _syncUnsyncedAttendance() async {
    try {
      // Récupérer toutes les branches codées en dur
      final branches = DefaultBranches.allBranches;
      int totalSynced = 0;

      for (final branch in branches) {
        // Récupérer toutes les sessions de cette branche
        final sessions = await _attendanceLocalDataSource.getAttendanceByBranch(branch.id);

        // Filtrer les sessions non synchronisées (lastSync == null)
        final unsyncedSessions = sessions.where((s) => s.lastSync == null).toList();

        for (final session in unsyncedSessions) {
          try {
            // Normaliser le branchId de la session si nécessaire
            final normalizedBranchId = DefaultBranches.normalizeBranchId(session.branchId);
            final sessionWithNormalizedBranch = session.copyWith(branchId: normalizedBranchId);

            // Tenter de créer sur Firestore
            final created = await _attendanceRemoteDataSource.createAttendance(sessionWithNormalizedBranch);
            // Mettre à jour le cache local avec lastSync
            await _attendanceLocalDataSource.cacheAttendance(created);
            
            totalSynced++;
            debugPrint('✅ Session synchronisée vers Firestore: ${session.id}');
          } catch (e) {
            // Si échec (peut-être que l'ID existe déjà), tenter une mise à jour
            try {
              final normalizedBranchId = DefaultBranches.normalizeBranchId(session.branchId);
              final sessionWithNormalizedBranch = session.copyWith(branchId: normalizedBranchId);
              
              final updated = await _attendanceRemoteDataSource.updateAttendance(sessionWithNormalizedBranch);
              await _attendanceLocalDataSource.cacheAttendance(updated);
              
              totalSynced++;
              debugPrint('✅ Session mise à jour sur Firestore: ${session.id}');
            } catch (e2) {
              debugPrint('⚠️ Impossible de synchroniser la session ${session.id}: $e2');
            }
          }
        }
      }

      // Notifier que les sessions ont été synchronisées si des données ont été synchronisées
      if (totalSynced > 0 && !_attendanceSyncedController.isClosed) {
        _attendanceSyncedController.add(null);
      }
    } catch (e) {
      debugPrint('Error syncing unsynced attendance: $e');
    }
  }
}

