import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import for WASM (web only)
import 'package:drift/wasm.dart' if (dart.library.io) 'database_wasm_stub.dart';

part 'database.g.dart';

/// Table pour les membres (scouts)
class Members extends Table {
  TextColumn get memberId => text().withLength(min: 1, max: 255)();
  TextColumn get firstName => text().withLength(min: 1, max: 255)();
  TextColumn get lastName => text().withLength(min: 1, max: 255)();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get branchId => text().withLength(min: 1, max: 255)();
  TextColumn get parentPhone => text().nullable()();
  DateTimeColumn get lastSync => dateTime().nullable()();
  TextColumn get medicalInfoJson => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete
  TextColumn get deletionReason => text().nullable()(); // Motif de suppression

  @override
  Set<Column> get primaryKey => {memberId};
}

/// Table pour les présences
class Attendances extends Table {
  TextColumn get attendanceId => text().withLength(min: 1, max: 255)();
  DateTimeColumn get date => dateTime()();
  IntColumn get type => integer()(); // 0 = weekly, 1 = monthly, 2 = special
  TextColumn get branchId => text().withLength(min: 1, max: 255)();
  TextColumn get presentMemberIds => text().nullable()(); // JSON array as string
  TextColumn get absentMemberIds => text().nullable()(); // JSON array as string
  DateTimeColumn get lastSync => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {attendanceId};
}

/// Table pour les branches
class Branches extends Table {
  TextColumn get branchId => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get color => text().withLength(min: 1, max: 50)();
  IntColumn get minAge => integer()();
  IntColumn get maxAge => integer()();

  @override
  Set<Column> get primaryKey => {branchId};
}

/// Table pour les unités
class Units extends Table {
  TextColumn get unitId => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get groupId => text().withLength(min: 1, max: 255)();
  TextColumn get branchIds => text().nullable()(); // JSON array as string

  @override
  Set<Column> get primaryKey => {unitId};
}

/// Table pour les groupes
class Groups extends Table {
  TextColumn get groupId => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get unitIds => text().nullable()(); // JSON array as string

  @override
  Set<Column> get primaryKey => {groupId};
}

@DriftDatabase(tables: [Members, Attendances, Branches, Units, Groups])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() {
    if (kIsWeb) {
      return LazyDatabase(() async {
        final result = await WasmDatabase.open(
          databaseName: 'scout_app_db',
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.js'),
        );
        return result.resolvedExecutor;
      });
    } else {
      return driftDatabase(name: 'scout_app_db');
    }
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration vers version 2 : ajout des champs deletedAt et deletionReason
          await m.addColumn(this.members, this.members.deletedAt);
          await m.addColumn(this.members, this.members.deletionReason);
        }
      },
    );
  }
}


