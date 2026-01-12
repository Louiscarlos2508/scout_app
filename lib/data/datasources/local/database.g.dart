// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentPhoneMeta = const VerificationMeta(
    'parentPhone',
  );
  @override
  late final GeneratedColumn<String> parentPhone = GeneratedColumn<String>(
    'parent_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncMeta = const VerificationMeta(
    'lastSync',
  );
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
    'last_sync',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalInfoJsonMeta = const VerificationMeta(
    'medicalInfoJson',
  );
  @override
  late final GeneratedColumn<String> medicalInfoJson = GeneratedColumn<String>(
    'medical_info_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletionReasonMeta = const VerificationMeta(
    'deletionReason',
  );
  @override
  late final GeneratedColumn<String> deletionReason = GeneratedColumn<String>(
    'deletion_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    memberId,
    firstName,
    lastName,
    dateOfBirth,
    branchId,
    parentPhone,
    lastSync,
    medicalInfoJson,
    deletedAt,
    deletionReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('parent_phone')) {
      context.handle(
        _parentPhoneMeta,
        parentPhone.isAcceptableOrUnknown(
          data['parent_phone']!,
          _parentPhoneMeta,
        ),
      );
    }
    if (data.containsKey('last_sync')) {
      context.handle(
        _lastSyncMeta,
        lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta),
      );
    }
    if (data.containsKey('medical_info_json')) {
      context.handle(
        _medicalInfoJsonMeta,
        medicalInfoJson.isAcceptableOrUnknown(
          data['medical_info_json']!,
          _medicalInfoJsonMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('deletion_reason')) {
      context.handle(
        _deletionReasonMeta,
        deletionReason.isAcceptableOrUnknown(
          data['deletion_reason']!,
          _deletionReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      parentPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_phone'],
      ),
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      ),
      medicalInfoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_info_json'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deletionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deletion_reason'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String memberId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String branchId;
  final String? parentPhone;
  final DateTime? lastSync;
  final String? medicalInfoJson;
  final DateTime? deletedAt;
  final String? deletionReason;
  const Member({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.branchId,
    this.parentPhone,
    this.lastSync,
    this.medicalInfoJson,
    this.deletedAt,
    this.deletionReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['branch_id'] = Variable<String>(branchId);
    if (!nullToAbsent || parentPhone != null) {
      map['parent_phone'] = Variable<String>(parentPhone);
    }
    if (!nullToAbsent || lastSync != null) {
      map['last_sync'] = Variable<DateTime>(lastSync);
    }
    if (!nullToAbsent || medicalInfoJson != null) {
      map['medical_info_json'] = Variable<String>(medicalInfoJson);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletionReason != null) {
      map['deletion_reason'] = Variable<String>(deletionReason);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      memberId: Value(memberId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      dateOfBirth: Value(dateOfBirth),
      branchId: Value(branchId),
      parentPhone: parentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPhone),
      lastSync: lastSync == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSync),
      medicalInfoJson: medicalInfoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalInfoJson),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletionReason: deletionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(deletionReason),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      memberId: serializer.fromJson<String>(json['memberId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      branchId: serializer.fromJson<String>(json['branchId']),
      parentPhone: serializer.fromJson<String?>(json['parentPhone']),
      lastSync: serializer.fromJson<DateTime?>(json['lastSync']),
      medicalInfoJson: serializer.fromJson<String?>(json['medicalInfoJson']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletionReason: serializer.fromJson<String?>(json['deletionReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'branchId': serializer.toJson<String>(branchId),
      'parentPhone': serializer.toJson<String?>(parentPhone),
      'lastSync': serializer.toJson<DateTime?>(lastSync),
      'medicalInfoJson': serializer.toJson<String?>(medicalInfoJson),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletionReason': serializer.toJson<String?>(deletionReason),
    };
  }

  Member copyWith({
    String? memberId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? branchId,
    Value<String?> parentPhone = const Value.absent(),
    Value<DateTime?> lastSync = const Value.absent(),
    Value<String?> medicalInfoJson = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deletionReason = const Value.absent(),
  }) => Member(
    memberId: memberId ?? this.memberId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    branchId: branchId ?? this.branchId,
    parentPhone: parentPhone.present ? parentPhone.value : this.parentPhone,
    lastSync: lastSync.present ? lastSync.value : this.lastSync,
    medicalInfoJson: medicalInfoJson.present
        ? medicalInfoJson.value
        : this.medicalInfoJson,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deletionReason: deletionReason.present
        ? deletionReason.value
        : this.deletionReason,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      parentPhone: data.parentPhone.present
          ? data.parentPhone.value
          : this.parentPhone,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
      medicalInfoJson: data.medicalInfoJson.present
          ? data.medicalInfoJson.value
          : this.medicalInfoJson,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletionReason: data.deletionReason.present
          ? data.deletionReason.value
          : this.deletionReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('memberId: $memberId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('branchId: $branchId, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('lastSync: $lastSync, ')
          ..write('medicalInfoJson: $medicalInfoJson, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletionReason: $deletionReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    memberId,
    firstName,
    lastName,
    dateOfBirth,
    branchId,
    parentPhone,
    lastSync,
    medicalInfoJson,
    deletedAt,
    deletionReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.memberId == this.memberId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.branchId == this.branchId &&
          other.parentPhone == this.parentPhone &&
          other.lastSync == this.lastSync &&
          other.medicalInfoJson == this.medicalInfoJson &&
          other.deletedAt == this.deletedAt &&
          other.deletionReason == this.deletionReason);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> memberId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<DateTime> dateOfBirth;
  final Value<String> branchId;
  final Value<String?> parentPhone;
  final Value<DateTime?> lastSync;
  final Value<String?> medicalInfoJson;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletionReason;
  final Value<int> rowid;
  const MembersCompanion({
    this.memberId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.branchId = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.medicalInfoJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String memberId,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String branchId,
    this.parentPhone = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.medicalInfoJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : memberId = Value(memberId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       dateOfBirth = Value(dateOfBirth),
       branchId = Value(branchId);
  static Insertable<Member> custom({
    Expression<String>? memberId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? branchId,
    Expression<String>? parentPhone,
    Expression<DateTime>? lastSync,
    Expression<String>? medicalInfoJson,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletionReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (branchId != null) 'branch_id': branchId,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (lastSync != null) 'last_sync': lastSync,
      if (medicalInfoJson != null) 'medical_info_json': medicalInfoJson,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletionReason != null) 'deletion_reason': deletionReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? memberId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<DateTime>? dateOfBirth,
    Value<String>? branchId,
    Value<String?>? parentPhone,
    Value<DateTime?>? lastSync,
    Value<String?>? medicalInfoJson,
    Value<DateTime?>? deletedAt,
    Value<String?>? deletionReason,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      memberId: memberId ?? this.memberId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      branchId: branchId ?? this.branchId,
      parentPhone: parentPhone ?? this.parentPhone,
      lastSync: lastSync ?? this.lastSync,
      medicalInfoJson: medicalInfoJson ?? this.medicalInfoJson,
      deletedAt: deletedAt ?? this.deletedAt,
      deletionReason: deletionReason ?? this.deletionReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (parentPhone.present) {
      map['parent_phone'] = Variable<String>(parentPhone.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    if (medicalInfoJson.present) {
      map['medical_info_json'] = Variable<String>(medicalInfoJson.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletionReason.present) {
      map['deletion_reason'] = Variable<String>(deletionReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('memberId: $memberId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('branchId: $branchId, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('lastSync: $lastSync, ')
          ..write('medicalInfoJson: $medicalInfoJson, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletionReason: $deletionReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attendanceIdMeta = const VerificationMeta(
    'attendanceId',
  );
  @override
  late final GeneratedColumn<String> attendanceId = GeneratedColumn<String>(
    'attendance_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentMemberIdsMeta = const VerificationMeta(
    'presentMemberIds',
  );
  @override
  late final GeneratedColumn<String> presentMemberIds = GeneratedColumn<String>(
    'present_member_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _absentMemberIdsMeta = const VerificationMeta(
    'absentMemberIds',
  );
  @override
  late final GeneratedColumn<String> absentMemberIds = GeneratedColumn<String>(
    'absent_member_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncMeta = const VerificationMeta(
    'lastSync',
  );
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
    'last_sync',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attendanceId,
    date,
    type,
    branchId,
    presentMemberIds,
    absentMemberIds,
    lastSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attendance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attendance_id')) {
      context.handle(
        _attendanceIdMeta,
        attendanceId.isAcceptableOrUnknown(
          data['attendance_id']!,
          _attendanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('present_member_ids')) {
      context.handle(
        _presentMemberIdsMeta,
        presentMemberIds.isAcceptableOrUnknown(
          data['present_member_ids']!,
          _presentMemberIdsMeta,
        ),
      );
    }
    if (data.containsKey('absent_member_ids')) {
      context.handle(
        _absentMemberIdsMeta,
        absentMemberIds.isAcceptableOrUnknown(
          data['absent_member_ids']!,
          _absentMemberIdsMeta,
        ),
      );
    }
    if (data.containsKey('last_sync')) {
      context.handle(
        _lastSyncMeta,
        lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attendanceId};
  @override
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      attendanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      presentMemberIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}present_member_ids'],
      ),
      absentMemberIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absent_member_ids'],
      ),
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      ),
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final String attendanceId;
  final DateTime date;
  final int type;
  final String branchId;
  final String? presentMemberIds;
  final String? absentMemberIds;
  final DateTime? lastSync;
  const Attendance({
    required this.attendanceId,
    required this.date,
    required this.type,
    required this.branchId,
    this.presentMemberIds,
    this.absentMemberIds,
    this.lastSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attendance_id'] = Variable<String>(attendanceId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<int>(type);
    map['branch_id'] = Variable<String>(branchId);
    if (!nullToAbsent || presentMemberIds != null) {
      map['present_member_ids'] = Variable<String>(presentMemberIds);
    }
    if (!nullToAbsent || absentMemberIds != null) {
      map['absent_member_ids'] = Variable<String>(absentMemberIds);
    }
    if (!nullToAbsent || lastSync != null) {
      map['last_sync'] = Variable<DateTime>(lastSync);
    }
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      attendanceId: Value(attendanceId),
      date: Value(date),
      type: Value(type),
      branchId: Value(branchId),
      presentMemberIds: presentMemberIds == null && nullToAbsent
          ? const Value.absent()
          : Value(presentMemberIds),
      absentMemberIds: absentMemberIds == null && nullToAbsent
          ? const Value.absent()
          : Value(absentMemberIds),
      lastSync: lastSync == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSync),
    );
  }

  factory Attendance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      attendanceId: serializer.fromJson<String>(json['attendanceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<int>(json['type']),
      branchId: serializer.fromJson<String>(json['branchId']),
      presentMemberIds: serializer.fromJson<String?>(json['presentMemberIds']),
      absentMemberIds: serializer.fromJson<String?>(json['absentMemberIds']),
      lastSync: serializer.fromJson<DateTime?>(json['lastSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attendanceId': serializer.toJson<String>(attendanceId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<int>(type),
      'branchId': serializer.toJson<String>(branchId),
      'presentMemberIds': serializer.toJson<String?>(presentMemberIds),
      'absentMemberIds': serializer.toJson<String?>(absentMemberIds),
      'lastSync': serializer.toJson<DateTime?>(lastSync),
    };
  }

  Attendance copyWith({
    String? attendanceId,
    DateTime? date,
    int? type,
    String? branchId,
    Value<String?> presentMemberIds = const Value.absent(),
    Value<String?> absentMemberIds = const Value.absent(),
    Value<DateTime?> lastSync = const Value.absent(),
  }) => Attendance(
    attendanceId: attendanceId ?? this.attendanceId,
    date: date ?? this.date,
    type: type ?? this.type,
    branchId: branchId ?? this.branchId,
    presentMemberIds: presentMemberIds.present
        ? presentMemberIds.value
        : this.presentMemberIds,
    absentMemberIds: absentMemberIds.present
        ? absentMemberIds.value
        : this.absentMemberIds,
    lastSync: lastSync.present ? lastSync.value : this.lastSync,
  );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      attendanceId: data.attendanceId.present
          ? data.attendanceId.value
          : this.attendanceId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      presentMemberIds: data.presentMemberIds.present
          ? data.presentMemberIds.value
          : this.presentMemberIds,
      absentMemberIds: data.absentMemberIds.present
          ? data.absentMemberIds.value
          : this.absentMemberIds,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('attendanceId: $attendanceId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('branchId: $branchId, ')
          ..write('presentMemberIds: $presentMemberIds, ')
          ..write('absentMemberIds: $absentMemberIds, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attendanceId,
    date,
    type,
    branchId,
    presentMemberIds,
    absentMemberIds,
    lastSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.attendanceId == this.attendanceId &&
          other.date == this.date &&
          other.type == this.type &&
          other.branchId == this.branchId &&
          other.presentMemberIds == this.presentMemberIds &&
          other.absentMemberIds == this.absentMemberIds &&
          other.lastSync == this.lastSync);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<String> attendanceId;
  final Value<DateTime> date;
  final Value<int> type;
  final Value<String> branchId;
  final Value<String?> presentMemberIds;
  final Value<String?> absentMemberIds;
  final Value<DateTime?> lastSync;
  final Value<int> rowid;
  const AttendancesCompanion({
    this.attendanceId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.branchId = const Value.absent(),
    this.presentMemberIds = const Value.absent(),
    this.absentMemberIds = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendancesCompanion.insert({
    required String attendanceId,
    required DateTime date,
    required int type,
    required String branchId,
    this.presentMemberIds = const Value.absent(),
    this.absentMemberIds = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : attendanceId = Value(attendanceId),
       date = Value(date),
       type = Value(type),
       branchId = Value(branchId);
  static Insertable<Attendance> custom({
    Expression<String>? attendanceId,
    Expression<DateTime>? date,
    Expression<int>? type,
    Expression<String>? branchId,
    Expression<String>? presentMemberIds,
    Expression<String>? absentMemberIds,
    Expression<DateTime>? lastSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attendanceId != null) 'attendance_id': attendanceId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (branchId != null) 'branch_id': branchId,
      if (presentMemberIds != null) 'present_member_ids': presentMemberIds,
      if (absentMemberIds != null) 'absent_member_ids': absentMemberIds,
      if (lastSync != null) 'last_sync': lastSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendancesCompanion copyWith({
    Value<String>? attendanceId,
    Value<DateTime>? date,
    Value<int>? type,
    Value<String>? branchId,
    Value<String?>? presentMemberIds,
    Value<String?>? absentMemberIds,
    Value<DateTime?>? lastSync,
    Value<int>? rowid,
  }) {
    return AttendancesCompanion(
      attendanceId: attendanceId ?? this.attendanceId,
      date: date ?? this.date,
      type: type ?? this.type,
      branchId: branchId ?? this.branchId,
      presentMemberIds: presentMemberIds ?? this.presentMemberIds,
      absentMemberIds: absentMemberIds ?? this.absentMemberIds,
      lastSync: lastSync ?? this.lastSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attendanceId.present) {
      map['attendance_id'] = Variable<String>(attendanceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (presentMemberIds.present) {
      map['present_member_ids'] = Variable<String>(presentMemberIds.value);
    }
    if (absentMemberIds.present) {
      map['absent_member_ids'] = Variable<String>(absentMemberIds.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('attendanceId: $attendanceId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('branchId: $branchId, ')
          ..write('presentMemberIds: $presentMemberIds, ')
          ..write('absentMemberIds: $absentMemberIds, ')
          ..write('lastSync: $lastSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minAgeMeta = const VerificationMeta('minAge');
  @override
  late final GeneratedColumn<int> minAge = GeneratedColumn<int>(
    'min_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxAgeMeta = const VerificationMeta('maxAge');
  @override
  late final GeneratedColumn<int> maxAge = GeneratedColumn<int>(
    'max_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [branchId, name, color, minAge, maxAge];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Branche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('min_age')) {
      context.handle(
        _minAgeMeta,
        minAge.isAcceptableOrUnknown(data['min_age']!, _minAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_minAgeMeta);
    }
    if (data.containsKey('max_age')) {
      context.handle(
        _maxAgeMeta,
        maxAge.isAcceptableOrUnknown(data['max_age']!, _maxAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_maxAgeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {branchId};
  @override
  Branche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branche(
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      minAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_age'],
      )!,
      maxAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_age'],
      )!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class Branche extends DataClass implements Insertable<Branche> {
  final String branchId;
  final String name;
  final String color;
  final int minAge;
  final int maxAge;
  const Branche({
    required this.branchId,
    required this.name,
    required this.color,
    required this.minAge,
    required this.maxAge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['branch_id'] = Variable<String>(branchId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['min_age'] = Variable<int>(minAge);
    map['max_age'] = Variable<int>(maxAge);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      branchId: Value(branchId),
      name: Value(name),
      color: Value(color),
      minAge: Value(minAge),
      maxAge: Value(maxAge),
    );
  }

  factory Branche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branche(
      branchId: serializer.fromJson<String>(json['branchId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      minAge: serializer.fromJson<int>(json['minAge']),
      maxAge: serializer.fromJson<int>(json['maxAge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'branchId': serializer.toJson<String>(branchId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'minAge': serializer.toJson<int>(minAge),
      'maxAge': serializer.toJson<int>(maxAge),
    };
  }

  Branche copyWith({
    String? branchId,
    String? name,
    String? color,
    int? minAge,
    int? maxAge,
  }) => Branche(
    branchId: branchId ?? this.branchId,
    name: name ?? this.name,
    color: color ?? this.color,
    minAge: minAge ?? this.minAge,
    maxAge: maxAge ?? this.maxAge,
  );
  Branche copyWithCompanion(BranchesCompanion data) {
    return Branche(
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      minAge: data.minAge.present ? data.minAge.value : this.minAge,
      maxAge: data.maxAge.present ? data.maxAge.value : this.maxAge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branche(')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('minAge: $minAge, ')
          ..write('maxAge: $maxAge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(branchId, name, color, minAge, maxAge);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branche &&
          other.branchId == this.branchId &&
          other.name == this.name &&
          other.color == this.color &&
          other.minAge == this.minAge &&
          other.maxAge == this.maxAge);
}

class BranchesCompanion extends UpdateCompanion<Branche> {
  final Value<String> branchId;
  final Value<String> name;
  final Value<String> color;
  final Value<int> minAge;
  final Value<int> maxAge;
  final Value<int> rowid;
  const BranchesCompanion({
    this.branchId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.minAge = const Value.absent(),
    this.maxAge = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String branchId,
    required String name,
    required String color,
    required int minAge,
    required int maxAge,
    this.rowid = const Value.absent(),
  }) : branchId = Value(branchId),
       name = Value(name),
       color = Value(color),
       minAge = Value(minAge),
       maxAge = Value(maxAge);
  static Insertable<Branche> custom({
    Expression<String>? branchId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? minAge,
    Expression<int>? maxAge,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (branchId != null) 'branch_id': branchId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (minAge != null) 'min_age': minAge,
      if (maxAge != null) 'max_age': maxAge,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith({
    Value<String>? branchId,
    Value<String>? name,
    Value<String>? color,
    Value<int>? minAge,
    Value<int>? maxAge,
    Value<int>? rowid,
  }) {
    return BranchesCompanion(
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      color: color ?? this.color,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (minAge.present) {
      map['min_age'] = Variable<int>(minAge.value);
    }
    if (maxAge.present) {
      map['max_age'] = Variable<int>(maxAge.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('minAge: $minAge, ')
          ..write('maxAge: $maxAge, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdsMeta = const VerificationMeta(
    'branchIds',
  );
  @override
  late final GeneratedColumn<String> branchIds = GeneratedColumn<String>(
    'branch_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [unitId, name, groupId, branchIds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('branch_ids')) {
      context.handle(
        _branchIdsMeta,
        branchIds.isAcceptableOrUnknown(data['branch_ids']!, _branchIdsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {unitId};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      branchIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_ids'],
      ),
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String unitId;
  final String name;
  final String groupId;
  final String? branchIds;
  const Unit({
    required this.unitId,
    required this.name,
    required this.groupId,
    this.branchIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['unit_id'] = Variable<String>(unitId);
    map['name'] = Variable<String>(name);
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || branchIds != null) {
      map['branch_ids'] = Variable<String>(branchIds);
    }
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      unitId: Value(unitId),
      name: Value(name),
      groupId: Value(groupId),
      branchIds: branchIds == null && nullToAbsent
          ? const Value.absent()
          : Value(branchIds),
    );
  }

  factory Unit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      unitId: serializer.fromJson<String>(json['unitId']),
      name: serializer.fromJson<String>(json['name']),
      groupId: serializer.fromJson<String>(json['groupId']),
      branchIds: serializer.fromJson<String?>(json['branchIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'unitId': serializer.toJson<String>(unitId),
      'name': serializer.toJson<String>(name),
      'groupId': serializer.toJson<String>(groupId),
      'branchIds': serializer.toJson<String?>(branchIds),
    };
  }

  Unit copyWith({
    String? unitId,
    String? name,
    String? groupId,
    Value<String?> branchIds = const Value.absent(),
  }) => Unit(
    unitId: unitId ?? this.unitId,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    branchIds: branchIds.present ? branchIds.value : this.branchIds,
  );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      branchIds: data.branchIds.present ? data.branchIds.value : this.branchIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('unitId: $unitId, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('branchIds: $branchIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(unitId, name, groupId, branchIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.unitId == this.unitId &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.branchIds == this.branchIds);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> unitId;
  final Value<String> name;
  final Value<String> groupId;
  final Value<String?> branchIds;
  final Value<int> rowid;
  const UnitsCompanion({
    this.unitId = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.branchIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    required String unitId,
    required String name,
    required String groupId,
    this.branchIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : unitId = Value(unitId),
       name = Value(name),
       groupId = Value(groupId);
  static Insertable<Unit> custom({
    Expression<String>? unitId,
    Expression<String>? name,
    Expression<String>? groupId,
    Expression<String>? branchIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (unitId != null) 'unit_id': unitId,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (branchIds != null) 'branch_ids': branchIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith({
    Value<String>? unitId,
    Value<String>? name,
    Value<String>? groupId,
    Value<String?>? branchIds,
    Value<int>? rowid,
  }) {
    return UnitsCompanion(
      unitId: unitId ?? this.unitId,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      branchIds: branchIds ?? this.branchIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (branchIds.present) {
      map['branch_ids'] = Variable<String>(branchIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('unitId: $unitId, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('branchIds: $branchIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdsMeta = const VerificationMeta(
    'unitIds',
  );
  @override
  late final GeneratedColumn<String> unitIds = GeneratedColumn<String>(
    'unit_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, name, description, unitIds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('unit_ids')) {
      context.handle(
        _unitIdsMeta,
        unitIds.isAcceptableOrUnknown(data['unit_ids']!, _unitIdsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      unitIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_ids'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String groupId;
  final String name;
  final String? description;
  final String? unitIds;
  const Group({
    required this.groupId,
    required this.name,
    this.description,
    this.unitIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || unitIds != null) {
      map['unit_ids'] = Variable<String>(unitIds);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      groupId: Value(groupId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      unitIds: unitIds == null && nullToAbsent
          ? const Value.absent()
          : Value(unitIds),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      unitIds: serializer.fromJson<String?>(json['unitIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'unitIds': serializer.toJson<String?>(unitIds),
    };
  }

  Group copyWith({
    String? groupId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> unitIds = const Value.absent(),
  }) => Group(
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    unitIds: unitIds.present ? unitIds.value : this.unitIds,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      unitIds: data.unitIds.present ? data.unitIds.value : this.unitIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('unitIds: $unitIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, name, description, unitIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.description == this.description &&
          other.unitIds == this.unitIds);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> groupId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> unitIds;
  final Value<int> rowid;
  const GroupsCompanion({
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.unitIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String groupId,
    required String name,
    this.description = const Value.absent(),
    this.unitIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       name = Value(name);
  static Insertable<Group> custom({
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? unitIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (unitIds != null) 'unit_ids': unitIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? groupId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? unitIds,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      unitIds: unitIds ?? this.unitIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (unitIds.present) {
      map['unit_ids'] = Variable<String>(unitIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('unitIds: $unitIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    members,
    attendances,
    branches,
    units,
    groups,
  ];
}

typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      required String memberId,
      required String firstName,
      required String lastName,
      required DateTime dateOfBirth,
      required String branchId,
      Value<String?> parentPhone,
      Value<DateTime?> lastSync,
      Value<String?> medicalInfoJson,
      Value<DateTime?> deletedAt,
      Value<String?> deletionReason,
      Value<int> rowid,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<String> memberId,
      Value<String> firstName,
      Value<String> lastName,
      Value<DateTime> dateOfBirth,
      Value<String> branchId,
      Value<String?> parentPhone,
      Value<DateTime?> lastSync,
      Value<String?> medicalInfoJson,
      Value<DateTime?> deletedAt,
      Value<String?> deletionReason,
      Value<int> rowid,
    });

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalInfoJson => $composableBuilder(
    column: $table.medicalInfoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletionReason => $composableBuilder(
    column: $table.deletionReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalInfoJson => $composableBuilder(
    column: $table.medicalInfoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletionReason => $composableBuilder(
    column: $table.deletionReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);

  GeneratedColumn<String> get medicalInfoJson => $composableBuilder(
    column: $table.medicalInfoJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletionReason => $composableBuilder(
    column: $table.deletionReason,
    builder: (column) => column,
  );
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> memberId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<DateTime> dateOfBirth = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String?> parentPhone = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<String?> medicalInfoJson = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deletionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                memberId: memberId,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                branchId: branchId,
                parentPhone: parentPhone,
                lastSync: lastSync,
                medicalInfoJson: medicalInfoJson,
                deletedAt: deletedAt,
                deletionReason: deletionReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String memberId,
                required String firstName,
                required String lastName,
                required DateTime dateOfBirth,
                required String branchId,
                Value<String?> parentPhone = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<String?> medicalInfoJson = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deletionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                memberId: memberId,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                branchId: branchId,
                parentPhone: parentPhone,
                lastSync: lastSync,
                medicalInfoJson: medicalInfoJson,
                deletedAt: deletedAt,
                deletionReason: deletionReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$AttendancesTableCreateCompanionBuilder =
    AttendancesCompanion Function({
      required String attendanceId,
      required DateTime date,
      required int type,
      required String branchId,
      Value<String?> presentMemberIds,
      Value<String?> absentMemberIds,
      Value<DateTime?> lastSync,
      Value<int> rowid,
    });
typedef $$AttendancesTableUpdateCompanionBuilder =
    AttendancesCompanion Function({
      Value<String> attendanceId,
      Value<DateTime> date,
      Value<int> type,
      Value<String> branchId,
      Value<String?> presentMemberIds,
      Value<String?> absentMemberIds,
      Value<DateTime?> lastSync,
      Value<int> rowid,
    });

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attendanceId => $composableBuilder(
    column: $table.attendanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presentMemberIds => $composableBuilder(
    column: $table.presentMemberIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absentMemberIds => $composableBuilder(
    column: $table.absentMemberIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attendanceId => $composableBuilder(
    column: $table.attendanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentMemberIds => $composableBuilder(
    column: $table.presentMemberIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absentMemberIds => $composableBuilder(
    column: $table.absentMemberIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attendanceId => $composableBuilder(
    column: $table.attendanceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get presentMemberIds => $composableBuilder(
    column: $table.presentMemberIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absentMemberIds => $composableBuilder(
    column: $table.absentMemberIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);
}

class $$AttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendancesTable,
          Attendance,
          $$AttendancesTableFilterComposer,
          $$AttendancesTableOrderingComposer,
          $$AttendancesTableAnnotationComposer,
          $$AttendancesTableCreateCompanionBuilder,
          $$AttendancesTableUpdateCompanionBuilder,
          (
            Attendance,
            BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>,
          ),
          Attendance,
          PrefetchHooks Function()
        > {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attendanceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String?> presentMemberIds = const Value.absent(),
                Value<String?> absentMemberIds = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendancesCompanion(
                attendanceId: attendanceId,
                date: date,
                type: type,
                branchId: branchId,
                presentMemberIds: presentMemberIds,
                absentMemberIds: absentMemberIds,
                lastSync: lastSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attendanceId,
                required DateTime date,
                required int type,
                required String branchId,
                Value<String?> presentMemberIds = const Value.absent(),
                Value<String?> absentMemberIds = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendancesCompanion.insert(
                attendanceId: attendanceId,
                date: date,
                type: type,
                branchId: branchId,
                presentMemberIds: presentMemberIds,
                absentMemberIds: absentMemberIds,
                lastSync: lastSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendancesTable,
      Attendance,
      $$AttendancesTableFilterComposer,
      $$AttendancesTableOrderingComposer,
      $$AttendancesTableAnnotationComposer,
      $$AttendancesTableCreateCompanionBuilder,
      $$AttendancesTableUpdateCompanionBuilder,
      (
        Attendance,
        BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>,
      ),
      Attendance,
      PrefetchHooks Function()
    >;
typedef $$BranchesTableCreateCompanionBuilder =
    BranchesCompanion Function({
      required String branchId,
      required String name,
      required String color,
      required int minAge,
      required int maxAge,
      Value<int> rowid,
    });
typedef $$BranchesTableUpdateCompanionBuilder =
    BranchesCompanion Function({
      Value<String> branchId,
      Value<String> name,
      Value<String> color,
      Value<int> minAge,
      Value<int> maxAge,
      Value<int> rowid,
    });

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxAge => $composableBuilder(
    column: $table.maxAge,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxAge => $composableBuilder(
    column: $table.maxAge,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get minAge =>
      $composableBuilder(column: $table.minAge, builder: (column) => column);

  GeneratedColumn<int> get maxAge =>
      $composableBuilder(column: $table.maxAge, builder: (column) => column);
}

class $$BranchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchesTable,
          Branche,
          $$BranchesTableFilterComposer,
          $$BranchesTableOrderingComposer,
          $$BranchesTableAnnotationComposer,
          $$BranchesTableCreateCompanionBuilder,
          $$BranchesTableUpdateCompanionBuilder,
          (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
          Branche,
          PrefetchHooks Function()
        > {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> branchId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> minAge = const Value.absent(),
                Value<int> maxAge = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion(
                branchId: branchId,
                name: name,
                color: color,
                minAge: minAge,
                maxAge: maxAge,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String branchId,
                required String name,
                required String color,
                required int minAge,
                required int maxAge,
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion.insert(
                branchId: branchId,
                name: name,
                color: color,
                minAge: minAge,
                maxAge: maxAge,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BranchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchesTable,
      Branche,
      $$BranchesTableFilterComposer,
      $$BranchesTableOrderingComposer,
      $$BranchesTableAnnotationComposer,
      $$BranchesTableCreateCompanionBuilder,
      $$BranchesTableUpdateCompanionBuilder,
      (Branche, BaseReferences<_$AppDatabase, $BranchesTable, Branche>),
      Branche,
      PrefetchHooks Function()
    >;
typedef $$UnitsTableCreateCompanionBuilder =
    UnitsCompanion Function({
      required String unitId,
      required String name,
      required String groupId,
      Value<String?> branchIds,
      Value<int> rowid,
    });
typedef $$UnitsTableUpdateCompanionBuilder =
    UnitsCompanion Function({
      Value<String> unitId,
      Value<String> name,
      Value<String> groupId,
      Value<String?> branchIds,
      Value<int> rowid,
    });

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchIds => $composableBuilder(
    column: $table.branchIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchIds => $composableBuilder(
    column: $table.branchIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get branchIds =>
      $composableBuilder(column: $table.branchIds, builder: (column) => column);
}

class $$UnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsTable,
          Unit,
          $$UnitsTableFilterComposer,
          $$UnitsTableOrderingComposer,
          $$UnitsTableAnnotationComposer,
          $$UnitsTableCreateCompanionBuilder,
          $$UnitsTableUpdateCompanionBuilder,
          (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
          Unit,
          PrefetchHooks Function()
        > {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> unitId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String?> branchIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion(
                unitId: unitId,
                name: name,
                groupId: groupId,
                branchIds: branchIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String unitId,
                required String name,
                required String groupId,
                Value<String?> branchIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion.insert(
                unitId: unitId,
                name: name,
                groupId: groupId,
                branchIds: branchIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsTable,
      Unit,
      $$UnitsTableFilterComposer,
      $$UnitsTableOrderingComposer,
      $$UnitsTableAnnotationComposer,
      $$UnitsTableCreateCompanionBuilder,
      $$UnitsTableUpdateCompanionBuilder,
      (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
      Unit,
      PrefetchHooks Function()
    >;
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      required String groupId,
      required String name,
      Value<String?> description,
      Value<String?> unitIds,
      Value<int> rowid,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<String> groupId,
      Value<String> name,
      Value<String?> description,
      Value<String?> unitIds,
      Value<int> rowid,
    });

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitIds => $composableBuilder(
    column: $table.unitIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitIds => $composableBuilder(
    column: $table.unitIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitIds =>
      $composableBuilder(column: $table.unitIds, builder: (column) => column);
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
          Group,
          PrefetchHooks Function()
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> unitIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                groupId: groupId,
                name: name,
                description: description,
                unitIds: unitIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> unitIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                groupId: groupId,
                name: name,
                description: description,
                unitIds: unitIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
      Group,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
}
