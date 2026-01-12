import 'package:dartz/dartz.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../core/errors/failures.dart';

/// Stub temporaire pour AttendanceRepository (développement UI uniquement).
/// Fournit des données mockées réalistes pour le développement de l'interface.
class StubAttendanceRepository implements AttendanceRepository {
  // Données mockées en mémoire
  final List<Attendance> _mockSessions = [
    // Sessions pour Louveteaux
    Attendance(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: SessionType.weekly,
      branchId: 'louveteaux',
      presentMemberIds: ['1', '2'],
      absentMemberIds: ['3'],
    ),
    Attendance(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 14)),
      type: SessionType.weekly,
      branchId: 'louveteaux',
      presentMemberIds: ['1', '2', '3'],
      absentMemberIds: [],
    ),
    // Sessions pour Éclaireurs
    Attendance(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: SessionType.weekly,
      branchId: 'eclaireurs',
      presentMemberIds: ['4', '5'],
      absentMemberIds: ['6'],
    ),
    Attendance(
      id: '4',
      date: DateTime.now().subtract(const Duration(days: 30)),
      type: SessionType.monthly,
      branchId: 'eclaireurs',
      presentMemberIds: ['4', '5', '6'],
      absentMemberIds: [],
    ),
    Attendance(
      id: '5',
      date: DateTime.now().subtract(const Duration(days: 60)),
      type: SessionType.special,
      branchId: 'eclaireurs',
      presentMemberIds: ['4', '6'],
      absentMemberIds: ['5'],
    ),
    // Sessions pour Sinikié
    Attendance(
      id: '6',
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: SessionType.weekly,
      branchId: 'sinikie',
      presentMemberIds: ['7'],
      absentMemberIds: ['8'],
    ),
    // Sessions pour Routiers
    Attendance(
      id: '7',
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: SessionType.weekly,
      branchId: 'routiers',
      presentMemberIds: ['9', '10'],
      absentMemberIds: [],
    ),
  ];

  @override
  Future<Either<Failure, List<Attendance>>> getAttendanceSessionsByBranch(
    String branchId,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    final sessions = _mockSessions
        .where((session) => session.branchId == branchId)
        .toList();
    
    // Trier par date décroissante (plus récentes en premier)
    sessions.sort((a, b) => b.date.compareTo(a.date));
    
    return Right(sessions);
  }

  @override
  Future<Either<Failure, Attendance>> getAttendanceById(String id) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    final session = _mockSessions.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Session not found'),
    );
    
    return Right(session);
  }

  @override
  Future<Either<Failure, Attendance>> createAttendanceSession(
    Attendance attendance,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Générer un nouvel ID
    final newId = (_mockSessions.length + 1).toString();
    final newSession = Attendance(
      id: newId,
      date: attendance.date,
      type: attendance.type,
      branchId: attendance.branchId,
      presentMemberIds: attendance.presentMemberIds,
      absentMemberIds: attendance.absentMemberIds,
      lastSync: DateTime.now(),
    );
    
    _mockSessions.add(newSession);
    return Right(newSession);
  }

  @override
  Future<Either<Failure, Attendance>> markAttendance(
    String sessionId,
    String memberId,
    bool isPresent,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    final sessionIndex = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      return Left(ServerFailure('Session not found'));
    }
    
    final session = _mockSessions[sessionIndex];
    final presentList = List<String>.from(session.presentMemberIds);
    final absentList = List<String>.from(session.absentMemberIds);
    
    // Retirer le membre des deux listes
    presentList.remove(memberId);
    absentList.remove(memberId);
    
    // Ajouter dans la bonne liste
    if (isPresent) {
      presentList.add(memberId);
    } else {
      absentList.add(memberId);
    }
    
    final updatedSession = Attendance(
      id: session.id,
      date: session.date,
      type: session.type,
      branchId: session.branchId,
      presentMemberIds: presentList,
      absentMemberIds: absentList,
      lastSync: DateTime.now(),
    );
    
    _mockSessions[sessionIndex] = updatedSession;
    return Right(updatedSession);
  }

  @override
  Future<Either<Failure, void>> syncAttendance() async {
    // Simuler une synchronisation
    await Future.delayed(const Duration(milliseconds: 1000));
    return const Right(null);
  }
}
