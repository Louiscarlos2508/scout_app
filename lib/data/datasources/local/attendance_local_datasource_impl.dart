import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../domain/entities/attendance.dart' as entities;
import '../../models/attendance_model.dart';
import 'drift_database.dart' as drift_db;
import 'database.dart' as db;
import 'attendance_local_datasource.dart';

/// Implémentation utilisant Drift sur mobile/desktop.
/// Sur le web, retourne des listes vides (Firebase est utilisé directement).
class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  db.AppDatabase? get _db {
    if (kIsWeb) return null;
    return drift_db.DriftDatabase.database;
  }

  @override
  Future<List<AttendanceModel>> getAttendanceByBranch(String branchId) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return [];
    }
    
    final attendances = await (_db!.select(_db!.attendances)
          ..where((a) => a.branchId.equals(branchId))
          ..orderBy([(a) => OrderingTerm(expression: a.date, mode: OrderingMode.desc)]))
        .get();

    return attendances.map((row) => _attendanceRowToModel(row)).toList();
  }

  @override
  Future<AttendanceModel?> getAttendanceById(String id) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return null;
    }
    
    final attendance = await (_db!.select(_db!.attendances)
          ..where((a) => a.attendanceId.equals(id))
          ..limit(1))
        .getSingleOrNull();

    if (attendance == null) return null;

    return _attendanceRowToModel(attendance);
  }

  @override
  Future<void> cacheAttendance(AttendanceModel attendance) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.into(_db!.attendances).insertOnConflictUpdate(_attendanceModelToRow(attendance));
  }

  @override
  Future<void> cacheAttendanceList(List<AttendanceModel> attendanceList) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.batch((batch) {
      for (final attendance in attendanceList) {
        batch.insert(_db!.attendances, _attendanceModelToRow(attendance), mode: InsertMode.replace);
      }
    });
  }

  @override
  Future<void> deleteAttendance(String id) async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await (_db!.delete(_db!.attendances)..where((a) => a.attendanceId.equals(id))).go();
  }

  @override
  Future<void> clearCache() async {
    if (kIsWeb || _db == null) {
      // Sur le web, on n'utilise pas de cache local
      return;
    }
    
    await _db!.delete(_db!.attendances).go();
  }

  /// Convertit un AttendanceRow en AttendanceModel
  AttendanceModel _attendanceRowToModel(db.Attendance row) {
    final presentMemberIds = row.presentMemberIds != null
        ? jsonDecode(row.presentMemberIds!) as List<dynamic>
        : <dynamic>[];
    final absentMemberIds = row.absentMemberIds != null
        ? jsonDecode(row.absentMemberIds!) as List<dynamic>
        : <dynamic>[];

    final attendance = entities.Attendance(
      id: row.attendanceId,
      date: row.date,
      type: entities.SessionType.values[row.type],
      branchId: row.branchId,
      presentMemberIds: presentMemberIds.map((e) => e.toString()).toList(),
      absentMemberIds: absentMemberIds.map((e) => e.toString()).toList(),
      lastSync: row.lastSync,
    );

    return AttendanceModel.fromEntity(attendance);
  }

  /// Convertit un AttendanceModel en AttendancesCompanion pour insertion
  db.AttendancesCompanion _attendanceModelToRow(AttendanceModel attendance) {
    return db.AttendancesCompanion.insert(
      attendanceId: attendance.id,
      date: attendance.date,
      type: attendance.type.index,
      branchId: attendance.branchId,
      presentMemberIds: Value(jsonEncode(attendance.presentMemberIds)),
      absentMemberIds: Value(jsonEncode(attendance.absentMemberIds)),
      lastSync: Value(attendance.lastSync),
    );
  }
}
