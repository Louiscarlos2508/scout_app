import 'package:flutter/foundation.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/usecases/attendance/get_attendance_sessions.dart';
import '../../domain/usecases/attendance/create_attendance_session.dart';
import '../../domain/usecases/attendance/mark_attendance.dart';
import '../../domain/usecases/attendance/sync_attendance.dart';

/// Provider pour la gestion de l'état des présences.
class AttendanceProvider with ChangeNotifier {
  final GetAttendanceSessions getAttendanceSessions;
  final CreateAttendanceSession createAttendanceSession;
  final MarkAttendance markAttendance;
  final SyncAttendance syncAttendance;

  AttendanceProvider({
    required this.getAttendanceSessions,
    required this.createAttendanceSession,
    required this.markAttendance,
    required this.syncAttendance,
  });

  List<Attendance> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<Attendance> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSessionsByBranch(String branchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAttendanceSessions(branchId);
    result.fold(
      (failure) => _error = failure.message,
      (sessions) => _sessions = sessions,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addSession(Attendance attendance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createAttendanceSession(attendance);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (createdSession) {
        _sessions.add(createdSession);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> toggleMemberAttendance(
    String sessionId,
    String memberId,
    bool isPresent,
  ) async {
    final result = await markAttendance(sessionId, memberId, isPresent);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (updatedSession) {
        final index = _sessions.indexWhere((s) => s.id == updatedSession.id);
        if (index != -1) {
          _sessions[index] = updatedSession;
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> sync() async {
    _isLoading = true;
    notifyListeners();

    await syncAttendance();

    _isLoading = false;
    notifyListeners();
  }
}

