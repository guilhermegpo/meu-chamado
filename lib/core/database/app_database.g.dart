// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, WorkspaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
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
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class WorkspaceRow extends DataClass implements Insertable<WorkspaceRow> {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  const WorkspaceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory WorkspaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkspaceRow copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? createdAt,
  }) => WorkspaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkspaceRow copyWithCompanion(WorkspacesCompanion data) {
    return WorkspaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class WorkspacesCompanion extends UpdateCompanion<WorkspaceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<WorkspaceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, AppUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
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
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, photoPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class AppUserRow extends DataClass implements Insertable<AppUserRow> {
  final String id;
  final String name;
  final String? photoPath;
  final DateTime createdAt;
  const AppUserRow({
    required this.id,
    required this.name,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory AppUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppUserRow copyWith({
    String? id,
    String? name,
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
  }) => AppUserRow(
    id: id ?? this.id,
    name: name ?? this.name,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  AppUserRow copyWithCompanion(UsersCompanion data) {
    return AppUserRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<AppUserRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    this.photoPath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<AppUserRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipsTable extends Memberships
    with TableInfo<$MembershipsTable, MembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [workspaceId, userId, role, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembershipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId, userId};
  @override
  MembershipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipRow(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MembershipsTable createAlias(String alias) {
    return $MembershipsTable(attachedDatabase, alias);
  }
}

class MembershipRow extends DataClass implements Insertable<MembershipRow> {
  final String workspaceId;
  final String userId;
  final String role;
  final DateTime createdAt;
  const MembershipRow({
    required this.workspaceId,
    required this.userId,
    required this.role,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MembershipsCompanion toCompanion(bool nullToAbsent) {
    return MembershipsCompanion(
      workspaceId: Value(workspaceId),
      userId: Value(userId),
      role: Value(role),
      createdAt: Value(createdAt),
    );
  }

  factory MembershipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipRow(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MembershipRow copyWith({
    String? workspaceId,
    String? userId,
    String? role,
    DateTime? createdAt,
  }) => MembershipRow(
    workspaceId: workspaceId ?? this.workspaceId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
  MembershipRow copyWithCompanion(MembershipsCompanion data) {
    return MembershipRow(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembershipRow(')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, userId, role, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipRow &&
          other.workspaceId == this.workspaceId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.createdAt == this.createdAt);
}

class MembershipsCompanion extends UpdateCompanion<MembershipRow> {
  final Value<String> workspaceId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MembershipsCompanion({
    this.workspaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipsCompanion.insert({
    required String workspaceId,
    required String userId,
    required String role,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       userId = Value(userId),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<MembershipRow> custom({
    Expression<String>? workspaceId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipsCompanion copyWith({
    Value<String>? workspaceId,
    Value<String>? userId,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MembershipsCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipsCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallingsTable extends Callings
    with TableInfo<$CallingsTable, CallingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleKeyMeta = const VerificationMeta(
    'moduleKey',
  );
  @override
  late final GeneratedColumn<String> moduleKey = GeneratedColumn<String>(
    'module_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    userId,
    title,
    moduleKey,
    status,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'callings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('module_key')) {
      context.handle(
        _moduleKeyMeta,
        moduleKey.isAcceptableOrUnknown(data['module_key']!, _moduleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      moduleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $CallingsTable createAlias(String alias) {
    return $CallingsTable(attachedDatabase, alias);
  }
}

class CallingRow extends DataClass implements Insertable<CallingRow> {
  final String id;
  final String workspaceId;
  final String userId;
  final String title;
  final String moduleKey;
  final String status;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const CallingRow({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.title,
    required this.moduleKey,
    required this.status,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['module_key'] = Variable<String>(moduleKey);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  CallingsCompanion toCompanion(bool nullToAbsent) {
    return CallingsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      userId: Value(userId),
      title: Value(title),
      moduleKey: Value(moduleKey),
      status: Value(status),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CallingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallingRow(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      moduleKey: serializer.fromJson<String>(json['moduleKey']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'moduleKey': serializer.toJson<String>(moduleKey),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CallingRow copyWith({
    String? id,
    String? workspaceId,
    String? userId,
    String? title,
    String? moduleKey,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CallingRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    moduleKey: moduleKey ?? this.moduleKey,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CallingRow copyWithCompanion(CallingsCompanion data) {
    return CallingRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      moduleKey: data.moduleKey.present ? data.moduleKey.value : this.moduleKey,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallingRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('moduleKey: $moduleKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    userId,
    title,
    moduleKey,
    status,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallingRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.moduleKey == this.moduleKey &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class CallingsCompanion extends UpdateCompanion<CallingRow> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> moduleKey;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CallingsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.moduleKey = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallingsCompanion.insert({
    required String id,
    required String workspaceId,
    required String userId,
    required String title,
    required String moduleKey,
    required String status,
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       userId = Value(userId),
       title = Value(title),
       moduleKey = Value(moduleKey),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<CallingRow> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? moduleKey,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (moduleKey != null) 'module_key': moduleKey,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallingsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? moduleKey,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CallingsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      moduleKey: moduleKey ?? this.moduleKey,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (moduleKey.present) {
      map['module_key'] = Variable<String>(moduleKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallingsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('moduleKey: $moduleKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppPreferenceRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppPreferenceRow copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppPreferenceRow(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringBrothersTable extends MinisteringBrothers
    with TableInfo<$MinisteringBrothersTable, MinisteringBrotherRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringBrothersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES callings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callingId,
    displayLabel,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_brothers';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringBrotherRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayLabelMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinisteringBrotherRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringBrotherRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinisteringBrothersTable createAlias(String alias) {
    return $MinisteringBrothersTable(attachedDatabase, alias);
  }
}

class MinisteringBrotherRow extends DataClass
    implements Insertable<MinisteringBrotherRow> {
  final String id;
  final String callingId;
  final String displayLabel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MinisteringBrotherRow({
    required this.id,
    required this.callingId,
    required this.displayLabel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['calling_id'] = Variable<String>(callingId);
    map['display_label'] = Variable<String>(displayLabel);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MinisteringBrothersCompanion toCompanion(bool nullToAbsent) {
    return MinisteringBrothersCompanion(
      id: Value(id),
      callingId: Value(callingId),
      displayLabel: Value(displayLabel),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinisteringBrotherRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringBrotherRow(
      id: serializer.fromJson<String>(json['id']),
      callingId: serializer.fromJson<String>(json['callingId']),
      displayLabel: serializer.fromJson<String>(json['displayLabel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callingId': serializer.toJson<String>(callingId),
      'displayLabel': serializer.toJson<String>(displayLabel),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MinisteringBrotherRow copyWith({
    String? id,
    String? callingId,
    String? displayLabel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MinisteringBrotherRow(
    id: id ?? this.id,
    callingId: callingId ?? this.callingId,
    displayLabel: displayLabel ?? this.displayLabel,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinisteringBrotherRow copyWithCompanion(MinisteringBrothersCompanion data) {
    return MinisteringBrotherRow(
      id: data.id.present ? data.id.value : this.id,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringBrotherRow(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, callingId, displayLabel, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringBrotherRow &&
          other.id == this.id &&
          other.callingId == this.callingId &&
          other.displayLabel == this.displayLabel &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinisteringBrothersCompanion
    extends UpdateCompanion<MinisteringBrotherRow> {
  final Value<String> id;
  final Value<String> callingId;
  final Value<String> displayLabel;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MinisteringBrothersCompanion({
    this.id = const Value.absent(),
    this.callingId = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringBrothersCompanion.insert({
    required String id,
    required String callingId,
    required String displayLabel,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callingId = Value(callingId),
       displayLabel = Value(displayLabel),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinisteringBrotherRow> custom({
    Expression<String>? id,
    Expression<String>? callingId,
    Expression<String>? displayLabel,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callingId != null) 'calling_id': callingId,
      if (displayLabel != null) 'display_label': displayLabel,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringBrothersCompanion copyWith({
    Value<String>? id,
    Value<String>? callingId,
    Value<String>? displayLabel,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinisteringBrothersCompanion(
      id: id ?? this.id,
      callingId: callingId ?? this.callingId,
      displayLabel: displayLabel ?? this.displayLabel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringBrothersCompanion(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringLeadersTable extends MinisteringLeaders
    with TableInfo<$MinisteringLeadersTable, MinisteringLeaderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringLeadersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES callings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callingId,
    displayLabel,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_leaders';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringLeaderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayLabelMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinisteringLeaderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringLeaderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinisteringLeadersTable createAlias(String alias) {
    return $MinisteringLeadersTable(attachedDatabase, alias);
  }
}

class MinisteringLeaderRow extends DataClass
    implements Insertable<MinisteringLeaderRow> {
  final String id;
  final String callingId;
  final String displayLabel;

  /// `QUORUM_PRESIDENT`, `FIRST_COUNSELOR` ou `SECOND_COUNSELOR`. Guardado como
  /// texto pela mesma razão dos outros enums do app: a coluna descreve um cargo,
  /// e novos cargos entram sem migração de tipo.
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MinisteringLeaderRow({
    required this.id,
    required this.callingId,
    required this.displayLabel,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['calling_id'] = Variable<String>(callingId);
    map['display_label'] = Variable<String>(displayLabel);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MinisteringLeadersCompanion toCompanion(bool nullToAbsent) {
    return MinisteringLeadersCompanion(
      id: Value(id),
      callingId: Value(callingId),
      displayLabel: Value(displayLabel),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinisteringLeaderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringLeaderRow(
      id: serializer.fromJson<String>(json['id']),
      callingId: serializer.fromJson<String>(json['callingId']),
      displayLabel: serializer.fromJson<String>(json['displayLabel']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callingId': serializer.toJson<String>(callingId),
      'displayLabel': serializer.toJson<String>(displayLabel),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MinisteringLeaderRow copyWith({
    String? id,
    String? callingId,
    String? displayLabel,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MinisteringLeaderRow(
    id: id ?? this.id,
    callingId: callingId ?? this.callingId,
    displayLabel: displayLabel ?? this.displayLabel,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinisteringLeaderRow copyWithCompanion(MinisteringLeadersCompanion data) {
    return MinisteringLeaderRow(
      id: data.id.present ? data.id.value : this.id,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringLeaderRow(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    callingId,
    displayLabel,
    role,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringLeaderRow &&
          other.id == this.id &&
          other.callingId == this.callingId &&
          other.displayLabel == this.displayLabel &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinisteringLeadersCompanion
    extends UpdateCompanion<MinisteringLeaderRow> {
  final Value<String> id;
  final Value<String> callingId;
  final Value<String> displayLabel;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MinisteringLeadersCompanion({
    this.id = const Value.absent(),
    this.callingId = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringLeadersCompanion.insert({
    required String id,
    required String callingId,
    required String displayLabel,
    required String role,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callingId = Value(callingId),
       displayLabel = Value(displayLabel),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinisteringLeaderRow> custom({
    Expression<String>? id,
    Expression<String>? callingId,
    Expression<String>? displayLabel,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callingId != null) 'calling_id': callingId,
      if (displayLabel != null) 'display_label': displayLabel,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringLeadersCompanion copyWith({
    Value<String>? id,
    Value<String>? callingId,
    Value<String>? displayLabel,
    Value<String>? role,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinisteringLeadersCompanion(
      id: id ?? this.id,
      callingId: callingId ?? this.callingId,
      displayLabel: displayLabel ?? this.displayLabel,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringLeadersCompanion(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringCompanionshipsTable extends MinisteringCompanionships
    with
        TableInfo<
          $MinisteringCompanionshipsTable,
          MinisteringCompanionshipRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringCompanionshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES callings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callingId,
    displayLabel,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_companionships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringCompanionshipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinisteringCompanionshipRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringCompanionshipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinisteringCompanionshipsTable createAlias(String alias) {
    return $MinisteringCompanionshipsTable(attachedDatabase, alias);
  }
}

class MinisteringCompanionshipRow extends DataClass
    implements Insertable<MinisteringCompanionshipRow> {
  final String id;
  final String callingId;

  /// Rótulo opcional. Quando nulo, a interface compõe o nome pelos integrantes.
  final String? displayLabel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MinisteringCompanionshipRow({
    required this.id,
    required this.callingId,
    this.displayLabel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['calling_id'] = Variable<String>(callingId);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MinisteringCompanionshipsCompanion toCompanion(bool nullToAbsent) {
    return MinisteringCompanionshipsCompanion(
      id: Value(id),
      callingId: Value(callingId),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinisteringCompanionshipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringCompanionshipRow(
      id: serializer.fromJson<String>(json['id']),
      callingId: serializer.fromJson<String>(json['callingId']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callingId': serializer.toJson<String>(callingId),
      'displayLabel': serializer.toJson<String?>(displayLabel),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MinisteringCompanionshipRow copyWith({
    String? id,
    String? callingId,
    Value<String?> displayLabel = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MinisteringCompanionshipRow(
    id: id ?? this.id,
    callingId: callingId ?? this.callingId,
    displayLabel: displayLabel.present ? displayLabel.value : this.displayLabel,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinisteringCompanionshipRow copyWithCompanion(
    MinisteringCompanionshipsCompanion data,
  ) {
    return MinisteringCompanionshipRow(
      id: data.id.present ? data.id.value : this.id,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringCompanionshipRow(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, callingId, displayLabel, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringCompanionshipRow &&
          other.id == this.id &&
          other.callingId == this.callingId &&
          other.displayLabel == this.displayLabel &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinisteringCompanionshipsCompanion
    extends UpdateCompanion<MinisteringCompanionshipRow> {
  final Value<String> id;
  final Value<String> callingId;
  final Value<String?> displayLabel;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MinisteringCompanionshipsCompanion({
    this.id = const Value.absent(),
    this.callingId = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringCompanionshipsCompanion.insert({
    required String id,
    required String callingId,
    this.displayLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callingId = Value(callingId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinisteringCompanionshipRow> custom({
    Expression<String>? id,
    Expression<String>? callingId,
    Expression<String>? displayLabel,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callingId != null) 'calling_id': callingId,
      if (displayLabel != null) 'display_label': displayLabel,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringCompanionshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? callingId,
    Value<String?>? displayLabel,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinisteringCompanionshipsCompanion(
      id: id ?? this.id,
      callingId: callingId ?? this.callingId,
      displayLabel: displayLabel ?? this.displayLabel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringCompanionshipsCompanion(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringCompanionshipMembersTable
    extends MinisteringCompanionshipMembers
    with
        TableInfo<
          $MinisteringCompanionshipMembersTable,
          MinisteringCompanionshipMemberRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringCompanionshipMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companionshipIdMeta = const VerificationMeta(
    'companionshipId',
  );
  @override
  late final GeneratedColumn<String> companionshipId = GeneratedColumn<String>(
    'companionship_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherIdMeta = const VerificationMeta(
    'brotherId',
  );
  @override
  late final GeneratedColumn<String> brotherId = GeneratedColumn<String>(
    'brother_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    companionshipId,
    brotherId,
    callingId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_companionship_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringCompanionshipMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('companionship_id')) {
      context.handle(
        _companionshipIdMeta,
        companionshipId.isAcceptableOrUnknown(
          data['companionship_id']!,
          _companionshipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companionshipIdMeta);
    }
    if (data.containsKey('brother_id')) {
      context.handle(
        _brotherIdMeta,
        brotherId.isAcceptableOrUnknown(data['brother_id']!, _brotherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_brotherIdMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {companionshipId, brotherId};
  @override
  MinisteringCompanionshipMemberRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringCompanionshipMemberRow(
      companionshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companionship_id'],
      )!,
      brotherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brother_id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MinisteringCompanionshipMembersTable createAlias(String alias) {
    return $MinisteringCompanionshipMembersTable(attachedDatabase, alias);
  }
}

class MinisteringCompanionshipMemberRow extends DataClass
    implements Insertable<MinisteringCompanionshipMemberRow> {
  final String companionshipId;
  final String brotherId;

  /// Redundante de propósito: é o que torna possível a FK composta abaixo.
  final String callingId;
  final DateTime createdAt;
  const MinisteringCompanionshipMemberRow({
    required this.companionshipId,
    required this.brotherId,
    required this.callingId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['companionship_id'] = Variable<String>(companionshipId);
    map['brother_id'] = Variable<String>(brotherId);
    map['calling_id'] = Variable<String>(callingId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MinisteringCompanionshipMembersCompanion toCompanion(bool nullToAbsent) {
    return MinisteringCompanionshipMembersCompanion(
      companionshipId: Value(companionshipId),
      brotherId: Value(brotherId),
      callingId: Value(callingId),
      createdAt: Value(createdAt),
    );
  }

  factory MinisteringCompanionshipMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringCompanionshipMemberRow(
      companionshipId: serializer.fromJson<String>(json['companionshipId']),
      brotherId: serializer.fromJson<String>(json['brotherId']),
      callingId: serializer.fromJson<String>(json['callingId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companionshipId': serializer.toJson<String>(companionshipId),
      'brotherId': serializer.toJson<String>(brotherId),
      'callingId': serializer.toJson<String>(callingId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MinisteringCompanionshipMemberRow copyWith({
    String? companionshipId,
    String? brotherId,
    String? callingId,
    DateTime? createdAt,
  }) => MinisteringCompanionshipMemberRow(
    companionshipId: companionshipId ?? this.companionshipId,
    brotherId: brotherId ?? this.brotherId,
    callingId: callingId ?? this.callingId,
    createdAt: createdAt ?? this.createdAt,
  );
  MinisteringCompanionshipMemberRow copyWithCompanion(
    MinisteringCompanionshipMembersCompanion data,
  ) {
    return MinisteringCompanionshipMemberRow(
      companionshipId: data.companionshipId.present
          ? data.companionshipId.value
          : this.companionshipId,
      brotherId: data.brotherId.present ? data.brotherId.value : this.brotherId,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringCompanionshipMemberRow(')
          ..write('companionshipId: $companionshipId, ')
          ..write('brotherId: $brotherId, ')
          ..write('callingId: $callingId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(companionshipId, brotherId, callingId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringCompanionshipMemberRow &&
          other.companionshipId == this.companionshipId &&
          other.brotherId == this.brotherId &&
          other.callingId == this.callingId &&
          other.createdAt == this.createdAt);
}

class MinisteringCompanionshipMembersCompanion
    extends UpdateCompanion<MinisteringCompanionshipMemberRow> {
  final Value<String> companionshipId;
  final Value<String> brotherId;
  final Value<String> callingId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MinisteringCompanionshipMembersCompanion({
    this.companionshipId = const Value.absent(),
    this.brotherId = const Value.absent(),
    this.callingId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringCompanionshipMembersCompanion.insert({
    required String companionshipId,
    required String brotherId,
    required String callingId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : companionshipId = Value(companionshipId),
       brotherId = Value(brotherId),
       callingId = Value(callingId),
       createdAt = Value(createdAt);
  static Insertable<MinisteringCompanionshipMemberRow> custom({
    Expression<String>? companionshipId,
    Expression<String>? brotherId,
    Expression<String>? callingId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (companionshipId != null) 'companionship_id': companionshipId,
      if (brotherId != null) 'brother_id': brotherId,
      if (callingId != null) 'calling_id': callingId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringCompanionshipMembersCompanion copyWith({
    Value<String>? companionshipId,
    Value<String>? brotherId,
    Value<String>? callingId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MinisteringCompanionshipMembersCompanion(
      companionshipId: companionshipId ?? this.companionshipId,
      brotherId: brotherId ?? this.brotherId,
      callingId: callingId ?? this.callingId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companionshipId.present) {
      map['companionship_id'] = Variable<String>(companionshipId.value);
    }
    if (brotherId.present) {
      map['brother_id'] = Variable<String>(brotherId.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringCompanionshipMembersCompanion(')
          ..write('companionshipId: $companionshipId, ')
          ..write('brotherId: $brotherId, ')
          ..write('callingId: $callingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringInterviewsTable extends MinisteringInterviews
    with TableInfo<$MinisteringInterviewsTable, MinisteringInterviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringInterviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES callings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _companionshipIdMeta = const VerificationMeta(
    'companionshipId',
  );
  @override
  late final GeneratedColumn<String> companionshipId = GeneratedColumn<String>(
    'companionship_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interviewerIdMeta = const VerificationMeta(
    'interviewerId',
  );
  @override
  late final GeneratedColumn<String> interviewerId = GeneratedColumn<String>(
    'interviewer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ministering_leaders (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callingId,
    companionshipId,
    interviewerId,
    completedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_interviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringInterviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('companionship_id')) {
      context.handle(
        _companionshipIdMeta,
        companionshipId.isAcceptableOrUnknown(
          data['companionship_id']!,
          _companionshipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companionshipIdMeta);
    }
    if (data.containsKey('interviewer_id')) {
      context.handle(
        _interviewerIdMeta,
        interviewerId.isAcceptableOrUnknown(
          data['interviewer_id']!,
          _interviewerIdMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinisteringInterviewRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringInterviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      companionshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companionship_id'],
      )!,
      interviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interviewer_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MinisteringInterviewsTable createAlias(String alias) {
    return $MinisteringInterviewsTable(attachedDatabase, alias);
  }
}

class MinisteringInterviewRow extends DataClass
    implements Insertable<MinisteringInterviewRow> {
  final String id;
  final String callingId;
  final String companionshipId;

  /// Líder que conduziu a entrevista. Ver nota da classe sobre a nulabilidade.
  final String? interviewerId;
  final DateTime completedAt;
  final DateTime createdAt;
  const MinisteringInterviewRow({
    required this.id,
    required this.callingId,
    required this.companionshipId,
    this.interviewerId,
    required this.completedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['calling_id'] = Variable<String>(callingId);
    map['companionship_id'] = Variable<String>(companionshipId);
    if (!nullToAbsent || interviewerId != null) {
      map['interviewer_id'] = Variable<String>(interviewerId);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MinisteringInterviewsCompanion toCompanion(bool nullToAbsent) {
    return MinisteringInterviewsCompanion(
      id: Value(id),
      callingId: Value(callingId),
      companionshipId: Value(companionshipId),
      interviewerId: interviewerId == null && nullToAbsent
          ? const Value.absent()
          : Value(interviewerId),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory MinisteringInterviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringInterviewRow(
      id: serializer.fromJson<String>(json['id']),
      callingId: serializer.fromJson<String>(json['callingId']),
      companionshipId: serializer.fromJson<String>(json['companionshipId']),
      interviewerId: serializer.fromJson<String?>(json['interviewerId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callingId': serializer.toJson<String>(callingId),
      'companionshipId': serializer.toJson<String>(companionshipId),
      'interviewerId': serializer.toJson<String?>(interviewerId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MinisteringInterviewRow copyWith({
    String? id,
    String? callingId,
    String? companionshipId,
    Value<String?> interviewerId = const Value.absent(),
    DateTime? completedAt,
    DateTime? createdAt,
  }) => MinisteringInterviewRow(
    id: id ?? this.id,
    callingId: callingId ?? this.callingId,
    companionshipId: companionshipId ?? this.companionshipId,
    interviewerId: interviewerId.present
        ? interviewerId.value
        : this.interviewerId,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  MinisteringInterviewRow copyWithCompanion(
    MinisteringInterviewsCompanion data,
  ) {
    return MinisteringInterviewRow(
      id: data.id.present ? data.id.value : this.id,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      companionshipId: data.companionshipId.present
          ? data.companionshipId.value
          : this.companionshipId,
      interviewerId: data.interviewerId.present
          ? data.interviewerId.value
          : this.interviewerId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringInterviewRow(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId, ')
          ..write('interviewerId: $interviewerId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    callingId,
    companionshipId,
    interviewerId,
    completedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringInterviewRow &&
          other.id == this.id &&
          other.callingId == this.callingId &&
          other.companionshipId == this.companionshipId &&
          other.interviewerId == this.interviewerId &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class MinisteringInterviewsCompanion
    extends UpdateCompanion<MinisteringInterviewRow> {
  final Value<String> id;
  final Value<String> callingId;
  final Value<String> companionshipId;
  final Value<String?> interviewerId;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MinisteringInterviewsCompanion({
    this.id = const Value.absent(),
    this.callingId = const Value.absent(),
    this.companionshipId = const Value.absent(),
    this.interviewerId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringInterviewsCompanion.insert({
    required String id,
    required String callingId,
    required String companionshipId,
    this.interviewerId = const Value.absent(),
    required DateTime completedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callingId = Value(callingId),
       companionshipId = Value(companionshipId),
       completedAt = Value(completedAt),
       createdAt = Value(createdAt);
  static Insertable<MinisteringInterviewRow> custom({
    Expression<String>? id,
    Expression<String>? callingId,
    Expression<String>? companionshipId,
    Expression<String>? interviewerId,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callingId != null) 'calling_id': callingId,
      if (companionshipId != null) 'companionship_id': companionshipId,
      if (interviewerId != null) 'interviewer_id': interviewerId,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringInterviewsCompanion copyWith({
    Value<String>? id,
    Value<String>? callingId,
    Value<String>? companionshipId,
    Value<String?>? interviewerId,
    Value<DateTime>? completedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MinisteringInterviewsCompanion(
      id: id ?? this.id,
      callingId: callingId ?? this.callingId,
      companionshipId: companionshipId ?? this.companionshipId,
      interviewerId: interviewerId ?? this.interviewerId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (companionshipId.present) {
      map['companionship_id'] = Variable<String>(companionshipId.value);
    }
    if (interviewerId.present) {
      map['interviewer_id'] = Variable<String>(interviewerId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringInterviewsCompanion(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId, ')
          ..write('interviewerId: $interviewerId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringInterviewParticipantsTable
    extends MinisteringInterviewParticipants
    with
        TableInfo<
          $MinisteringInterviewParticipantsTable,
          MinisteringInterviewParticipantRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringInterviewParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _interviewIdMeta = const VerificationMeta(
    'interviewId',
  );
  @override
  late final GeneratedColumn<String> interviewId = GeneratedColumn<String>(
    'interview_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherIdMeta = const VerificationMeta(
    'brotherId',
  );
  @override
  late final GeneratedColumn<String> brotherId = GeneratedColumn<String>(
    'brother_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companionshipIdMeta = const VerificationMeta(
    'companionshipId',
  );
  @override
  late final GeneratedColumn<String> companionshipId = GeneratedColumn<String>(
    'companionship_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    interviewId,
    brotherId,
    callingId,
    companionshipId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_interview_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringInterviewParticipantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('interview_id')) {
      context.handle(
        _interviewIdMeta,
        interviewId.isAcceptableOrUnknown(
          data['interview_id']!,
          _interviewIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interviewIdMeta);
    }
    if (data.containsKey('brother_id')) {
      context.handle(
        _brotherIdMeta,
        brotherId.isAcceptableOrUnknown(data['brother_id']!, _brotherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_brotherIdMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('companionship_id')) {
      context.handle(
        _companionshipIdMeta,
        companionshipId.isAcceptableOrUnknown(
          data['companionship_id']!,
          _companionshipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companionshipIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {interviewId, brotherId};
  @override
  MinisteringInterviewParticipantRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringInterviewParticipantRow(
      interviewId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interview_id'],
      )!,
      brotherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brother_id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      companionshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companionship_id'],
      )!,
    );
  }

  @override
  $MinisteringInterviewParticipantsTable createAlias(String alias) {
    return $MinisteringInterviewParticipantsTable(attachedDatabase, alias);
  }
}

class MinisteringInterviewParticipantRow extends DataClass
    implements Insertable<MinisteringInterviewParticipantRow> {
  final String interviewId;
  final String brotherId;
  final String callingId;

  /// Redundante: permite validar que o participante pertence à dupla da
  /// entrevista sem um join extra.
  final String companionshipId;
  const MinisteringInterviewParticipantRow({
    required this.interviewId,
    required this.brotherId,
    required this.callingId,
    required this.companionshipId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['interview_id'] = Variable<String>(interviewId);
    map['brother_id'] = Variable<String>(brotherId);
    map['calling_id'] = Variable<String>(callingId);
    map['companionship_id'] = Variable<String>(companionshipId);
    return map;
  }

  MinisteringInterviewParticipantsCompanion toCompanion(bool nullToAbsent) {
    return MinisteringInterviewParticipantsCompanion(
      interviewId: Value(interviewId),
      brotherId: Value(brotherId),
      callingId: Value(callingId),
      companionshipId: Value(companionshipId),
    );
  }

  factory MinisteringInterviewParticipantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringInterviewParticipantRow(
      interviewId: serializer.fromJson<String>(json['interviewId']),
      brotherId: serializer.fromJson<String>(json['brotherId']),
      callingId: serializer.fromJson<String>(json['callingId']),
      companionshipId: serializer.fromJson<String>(json['companionshipId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'interviewId': serializer.toJson<String>(interviewId),
      'brotherId': serializer.toJson<String>(brotherId),
      'callingId': serializer.toJson<String>(callingId),
      'companionshipId': serializer.toJson<String>(companionshipId),
    };
  }

  MinisteringInterviewParticipantRow copyWith({
    String? interviewId,
    String? brotherId,
    String? callingId,
    String? companionshipId,
  }) => MinisteringInterviewParticipantRow(
    interviewId: interviewId ?? this.interviewId,
    brotherId: brotherId ?? this.brotherId,
    callingId: callingId ?? this.callingId,
    companionshipId: companionshipId ?? this.companionshipId,
  );
  MinisteringInterviewParticipantRow copyWithCompanion(
    MinisteringInterviewParticipantsCompanion data,
  ) {
    return MinisteringInterviewParticipantRow(
      interviewId: data.interviewId.present
          ? data.interviewId.value
          : this.interviewId,
      brotherId: data.brotherId.present ? data.brotherId.value : this.brotherId,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      companionshipId: data.companionshipId.present
          ? data.companionshipId.value
          : this.companionshipId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringInterviewParticipantRow(')
          ..write('interviewId: $interviewId, ')
          ..write('brotherId: $brotherId, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(interviewId, brotherId, callingId, companionshipId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringInterviewParticipantRow &&
          other.interviewId == this.interviewId &&
          other.brotherId == this.brotherId &&
          other.callingId == this.callingId &&
          other.companionshipId == this.companionshipId);
}

class MinisteringInterviewParticipantsCompanion
    extends UpdateCompanion<MinisteringInterviewParticipantRow> {
  final Value<String> interviewId;
  final Value<String> brotherId;
  final Value<String> callingId;
  final Value<String> companionshipId;
  final Value<int> rowid;
  const MinisteringInterviewParticipantsCompanion({
    this.interviewId = const Value.absent(),
    this.brotherId = const Value.absent(),
    this.callingId = const Value.absent(),
    this.companionshipId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringInterviewParticipantsCompanion.insert({
    required String interviewId,
    required String brotherId,
    required String callingId,
    required String companionshipId,
    this.rowid = const Value.absent(),
  }) : interviewId = Value(interviewId),
       brotherId = Value(brotherId),
       callingId = Value(callingId),
       companionshipId = Value(companionshipId);
  static Insertable<MinisteringInterviewParticipantRow> custom({
    Expression<String>? interviewId,
    Expression<String>? brotherId,
    Expression<String>? callingId,
    Expression<String>? companionshipId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (interviewId != null) 'interview_id': interviewId,
      if (brotherId != null) 'brother_id': brotherId,
      if (callingId != null) 'calling_id': callingId,
      if (companionshipId != null) 'companionship_id': companionshipId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringInterviewParticipantsCompanion copyWith({
    Value<String>? interviewId,
    Value<String>? brotherId,
    Value<String>? callingId,
    Value<String>? companionshipId,
    Value<int>? rowid,
  }) {
    return MinisteringInterviewParticipantsCompanion(
      interviewId: interviewId ?? this.interviewId,
      brotherId: brotherId ?? this.brotherId,
      callingId: callingId ?? this.callingId,
      companionshipId: companionshipId ?? this.companionshipId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (interviewId.present) {
      map['interview_id'] = Variable<String>(interviewId.value);
    }
    if (brotherId.present) {
      map['brother_id'] = Variable<String>(brotherId.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (companionshipId.present) {
      map['companionship_id'] = Variable<String>(companionshipId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringInterviewParticipantsCompanion(')
          ..write('interviewId: $interviewId, ')
          ..write('brotherId: $brotherId, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinisteringAppointmentsTable extends MinisteringAppointments
    with TableInfo<$MinisteringAppointmentsTable, MinisteringAppointmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinisteringAppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callingIdMeta = const VerificationMeta(
    'callingId',
  );
  @override
  late final GeneratedColumn<String> callingId = GeneratedColumn<String>(
    'calling_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES callings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _companionshipIdMeta = const VerificationMeta(
    'companionshipId',
  );
  @override
  late final GeneratedColumn<String> companionshipId = GeneratedColumn<String>(
    'companionship_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interviewerIdMeta = const VerificationMeta(
    'interviewerId',
  );
  @override
  late final GeneratedColumn<String> interviewerId = GeneratedColumn<String>(
    'interviewer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callingId,
    companionshipId,
    interviewerId,
    scheduledAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ministering_appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinisteringAppointmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calling_id')) {
      context.handle(
        _callingIdMeta,
        callingId.isAcceptableOrUnknown(data['calling_id']!, _callingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callingIdMeta);
    }
    if (data.containsKey('companionship_id')) {
      context.handle(
        _companionshipIdMeta,
        companionshipId.isAcceptableOrUnknown(
          data['companionship_id']!,
          _companionshipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companionshipIdMeta);
    }
    if (data.containsKey('interviewer_id')) {
      context.handle(
        _interviewerIdMeta,
        interviewerId.isAcceptableOrUnknown(
          data['interviewer_id']!,
          _interviewerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interviewerIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinisteringAppointmentRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinisteringAppointmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calling_id'],
      )!,
      companionshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companionship_id'],
      )!,
      interviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interviewer_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinisteringAppointmentsTable createAlias(String alias) {
    return $MinisteringAppointmentsTable(attachedDatabase, alias);
  }
}

class MinisteringAppointmentRow extends DataClass
    implements Insertable<MinisteringAppointmentRow> {
  final String id;
  final String callingId;
  final String companionshipId;
  final String interviewerId;

  /// Instante planejado, **com hora do dia** — ao contrário de
  /// `MinisteringInterviews.completedAt`, que é data de calendário. Um
  /// agendamento tem horário; uma entrevista aconteceu num dia.
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MinisteringAppointmentRow({
    required this.id,
    required this.callingId,
    required this.companionshipId,
    required this.interviewerId,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['calling_id'] = Variable<String>(callingId);
    map['companionship_id'] = Variable<String>(companionshipId);
    map['interviewer_id'] = Variable<String>(interviewerId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MinisteringAppointmentsCompanion toCompanion(bool nullToAbsent) {
    return MinisteringAppointmentsCompanion(
      id: Value(id),
      callingId: Value(callingId),
      companionshipId: Value(companionshipId),
      interviewerId: Value(interviewerId),
      scheduledAt: Value(scheduledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinisteringAppointmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinisteringAppointmentRow(
      id: serializer.fromJson<String>(json['id']),
      callingId: serializer.fromJson<String>(json['callingId']),
      companionshipId: serializer.fromJson<String>(json['companionshipId']),
      interviewerId: serializer.fromJson<String>(json['interviewerId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callingId': serializer.toJson<String>(callingId),
      'companionshipId': serializer.toJson<String>(companionshipId),
      'interviewerId': serializer.toJson<String>(interviewerId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MinisteringAppointmentRow copyWith({
    String? id,
    String? callingId,
    String? companionshipId,
    String? interviewerId,
    DateTime? scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MinisteringAppointmentRow(
    id: id ?? this.id,
    callingId: callingId ?? this.callingId,
    companionshipId: companionshipId ?? this.companionshipId,
    interviewerId: interviewerId ?? this.interviewerId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinisteringAppointmentRow copyWithCompanion(
    MinisteringAppointmentsCompanion data,
  ) {
    return MinisteringAppointmentRow(
      id: data.id.present ? data.id.value : this.id,
      callingId: data.callingId.present ? data.callingId.value : this.callingId,
      companionshipId: data.companionshipId.present
          ? data.companionshipId.value
          : this.companionshipId,
      interviewerId: data.interviewerId.present
          ? data.interviewerId.value
          : this.interviewerId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringAppointmentRow(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId, ')
          ..write('interviewerId: $interviewerId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    callingId,
    companionshipId,
    interviewerId,
    scheduledAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinisteringAppointmentRow &&
          other.id == this.id &&
          other.callingId == this.callingId &&
          other.companionshipId == this.companionshipId &&
          other.interviewerId == this.interviewerId &&
          other.scheduledAt == this.scheduledAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinisteringAppointmentsCompanion
    extends UpdateCompanion<MinisteringAppointmentRow> {
  final Value<String> id;
  final Value<String> callingId;
  final Value<String> companionshipId;
  final Value<String> interviewerId;
  final Value<DateTime> scheduledAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MinisteringAppointmentsCompanion({
    this.id = const Value.absent(),
    this.callingId = const Value.absent(),
    this.companionshipId = const Value.absent(),
    this.interviewerId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinisteringAppointmentsCompanion.insert({
    required String id,
    required String callingId,
    required String companionshipId,
    required String interviewerId,
    required DateTime scheduledAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callingId = Value(callingId),
       companionshipId = Value(companionshipId),
       interviewerId = Value(interviewerId),
       scheduledAt = Value(scheduledAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinisteringAppointmentRow> custom({
    Expression<String>? id,
    Expression<String>? callingId,
    Expression<String>? companionshipId,
    Expression<String>? interviewerId,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callingId != null) 'calling_id': callingId,
      if (companionshipId != null) 'companionship_id': companionshipId,
      if (interviewerId != null) 'interviewer_id': interviewerId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinisteringAppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? callingId,
    Value<String>? companionshipId,
    Value<String>? interviewerId,
    Value<DateTime>? scheduledAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinisteringAppointmentsCompanion(
      id: id ?? this.id,
      callingId: callingId ?? this.callingId,
      companionshipId: companionshipId ?? this.companionshipId,
      interviewerId: interviewerId ?? this.interviewerId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callingId.present) {
      map['calling_id'] = Variable<String>(callingId.value);
    }
    if (companionshipId.present) {
      map['companionship_id'] = Variable<String>(companionshipId.value);
    }
    if (interviewerId.present) {
      map['interviewer_id'] = Variable<String>(interviewerId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinisteringAppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('callingId: $callingId, ')
          ..write('companionshipId: $companionshipId, ')
          ..write('interviewerId: $interviewerId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MembershipsTable memberships = $MembershipsTable(this);
  late final $CallingsTable callings = $CallingsTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $MinisteringBrothersTable ministeringBrothers =
      $MinisteringBrothersTable(this);
  late final $MinisteringLeadersTable ministeringLeaders =
      $MinisteringLeadersTable(this);
  late final $MinisteringCompanionshipsTable ministeringCompanionships =
      $MinisteringCompanionshipsTable(this);
  late final $MinisteringCompanionshipMembersTable
  ministeringCompanionshipMembers = $MinisteringCompanionshipMembersTable(this);
  late final $MinisteringInterviewsTable ministeringInterviews =
      $MinisteringInterviewsTable(this);
  late final $MinisteringInterviewParticipantsTable
  ministeringInterviewParticipants = $MinisteringInterviewParticipantsTable(
    this,
  );
  late final $MinisteringAppointmentsTable ministeringAppointments =
      $MinisteringAppointmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaces,
    users,
    memberships,
    callings,
    appPreferences,
    ministeringBrothers,
    ministeringLeaders,
    ministeringCompanionships,
    ministeringCompanionshipMembers,
    ministeringInterviews,
    ministeringInterviewParticipants,
    ministeringAppointments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'callings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ministering_brothers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'callings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ministering_leaders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'callings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('ministering_companionships', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'callings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ministering_interviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'callings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('ministering_appointments', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$WorkspacesTableCreateCompanionBuilder = WorkspacesCompanion Function({
  required String id,
  required String name,
  required String type,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$WorkspacesTableUpdateCompanionBuilder = WorkspacesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$WorkspacesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow> {
  $$WorkspacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MembershipsTable, List<MembershipRow>>
  _membershipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memberships,
    aliasName: 'workspaces__id__memberships__workspace_id',
  );

  $$MembershipsTableProcessedTableManager get membershipsRefs {
    final manager = $$MembershipsTableTableManager(
      $_db,
      $_db.memberships,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_membershipsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CallingsTable, List<CallingRow>>
  _callingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.callings,
    aliasName: 'workspaces__id__callings__workspace_id',
  );

  $$CallingsTableProcessedTableManager get callingsRefs {
    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_callingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> membershipsRefs(
    Expression<bool> Function($$MembershipsTableFilterComposer f) f,
  ) {
    final $$MembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memberships,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembershipsTableFilterComposer(
            $db: $db,
            $table: $db.memberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> callingsRefs(
    Expression<bool> Function($$CallingsTableFilterComposer f) f,
  ) {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> membershipsRefs<T extends Object>(
    Expression<T> Function($$MembershipsTableAnnotationComposer a) f,
  ) {
    final $$MembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memberships,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.memberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> callingsRefs<T extends Object>(
    Expression<T> Function($$CallingsTableAnnotationComposer a) f,
  ) {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          WorkspaceRow,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (WorkspaceRow, $$WorkspacesTableReferences),
          WorkspaceRow,
          PrefetchHooks Function({bool membershipsRefs, bool callingsRefs})
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({membershipsRefs = false, callingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (membershipsRefs) db.memberships,
                    if (callingsRefs) db.callings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (membershipsRefs)
                        await $_getPrefetchedData<
                          WorkspaceRow,
                          $WorkspacesTable,
                          MembershipRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._membershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).membershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (callingsRefs)
                        await $_getPrefetchedData<
                          WorkspaceRow,
                          $WorkspacesTable,
                          CallingRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._callingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).callingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      WorkspaceRow,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (WorkspaceRow, $$WorkspacesTableReferences),
      WorkspaceRow,
      PrefetchHooks Function({bool membershipsRefs, bool callingsRefs})
    >;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String name,
  Value<String?> photoPath,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> photoPath,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, AppUserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MembershipsTable, List<MembershipRow>>
  _membershipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memberships,
    aliasName: 'users__id__memberships__user_id',
  );

  $$MembershipsTableProcessedTableManager get membershipsRefs {
    final manager = $$MembershipsTableTableManager(
      $_db,
      $_db.memberships,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_membershipsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CallingsTable, List<CallingRow>>
  _callingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.callings,
    aliasName: 'users__id__callings__user_id',
  );

  $$CallingsTableProcessedTableManager get callingsRefs {
    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_callingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> membershipsRefs(
    Expression<bool> Function($$MembershipsTableFilterComposer f) f,
  ) {
    final $$MembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memberships,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembershipsTableFilterComposer(
            $db: $db,
            $table: $db.memberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> callingsRefs(
    Expression<bool> Function($$CallingsTableFilterComposer f) f,
  ) {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> membershipsRefs<T extends Object>(
    Expression<T> Function($$MembershipsTableAnnotationComposer a) f,
  ) {
    final $$MembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memberships,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.memberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> callingsRefs<T extends Object>(
    Expression<T> Function($$CallingsTableAnnotationComposer a) f,
  ) {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          AppUserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (AppUserRow, $$UsersTableReferences),
          AppUserRow,
          PrefetchHooks Function({bool membershipsRefs, bool callingsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> photoPath = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({membershipsRefs = false, callingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (membershipsRefs) db.memberships,
                    if (callingsRefs) db.callings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (membershipsRefs)
                        await $_getPrefetchedData<
                          AppUserRow,
                          $UsersTable,
                          MembershipRow
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._membershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).membershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (callingsRefs)
                        await $_getPrefetchedData<
                          AppUserRow,
                          $UsersTable,
                          CallingRow
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._callingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).callingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      AppUserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (AppUserRow, $$UsersTableReferences),
      AppUserRow,
      PrefetchHooks Function({bool membershipsRefs, bool callingsRefs})
    >;
typedef $$MembershipsTableCreateCompanionBuilder =
    MembershipsCompanion Function({
      required String workspaceId,
      required String userId,
      required String role,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MembershipsTableUpdateCompanionBuilder =
    MembershipsCompanion Function({
      Value<String> workspaceId,
      Value<String> userId,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MembershipsTableReferences
    extends BaseReferences<_$AppDatabase, $MembershipsTable, MembershipRow> {
  $$MembershipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias('memberships__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('memberships__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembershipsTable,
          MembershipRow,
          $$MembershipsTableFilterComposer,
          $$MembershipsTableOrderingComposer,
          $$MembershipsTableAnnotationComposer,
          $$MembershipsTableCreateCompanionBuilder,
          $$MembershipsTableUpdateCompanionBuilder,
          (MembershipRow, $$MembershipsTableReferences),
          MembershipRow,
          PrefetchHooks Function({bool workspaceId, bool userId})
        > {
  $$MembershipsTableTableManager(_$AppDatabase db, $MembershipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembershipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembershipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion(
                workspaceId: workspaceId,
                userId: userId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required String userId,
                required String role,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion.insert(
                workspaceId: workspaceId,
                userId: userId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MembershipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workspaceId,
                        referencedTable: $$MembershipsTableReferences
                            ._workspaceIdTable(db),
                        referencedColumn: $$MembershipsTableReferences
                            ._workspaceIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$MembershipsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$MembershipsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembershipsTable,
      MembershipRow,
      $$MembershipsTableFilterComposer,
      $$MembershipsTableOrderingComposer,
      $$MembershipsTableAnnotationComposer,
      $$MembershipsTableCreateCompanionBuilder,
      $$MembershipsTableUpdateCompanionBuilder,
      (MembershipRow, $$MembershipsTableReferences),
      MembershipRow,
      PrefetchHooks Function({bool workspaceId, bool userId})
    >;
typedef $$CallingsTableCreateCompanionBuilder = CallingsCompanion Function({
  required String id,
  required String workspaceId,
  required String userId,
  required String title,
  required String moduleKey,
  required String status,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$CallingsTableUpdateCompanionBuilder = CallingsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String> userId,
  Value<String> title,
  Value<String> moduleKey,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$CallingsTableReferences
    extends BaseReferences<_$AppDatabase, $CallingsTable, CallingRow> {
  $$CallingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias('callings__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('callings__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MinisteringBrothersTable,
    List<MinisteringBrotherRow>
  >
  _ministeringBrothersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringBrothers,
        aliasName: 'callings__id__ministering_brothers__calling_id',
      );

  $$MinisteringBrothersTableProcessedTableManager get ministeringBrothersRefs {
    final manager = $$MinisteringBrothersTableTableManager(
      $_db,
      $_db.ministeringBrothers,
    ).filter((f) => f.callingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringBrothersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinisteringLeadersTable,
    List<MinisteringLeaderRow>
  >
  _ministeringLeadersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringLeaders,
        aliasName: 'callings__id__ministering_leaders__calling_id',
      );

  $$MinisteringLeadersTableProcessedTableManager get ministeringLeadersRefs {
    final manager = $$MinisteringLeadersTableTableManager(
      $_db,
      $_db.ministeringLeaders,
    ).filter((f) => f.callingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringLeadersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinisteringCompanionshipsTable,
    List<MinisteringCompanionshipRow>
  >
  _ministeringCompanionshipsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringCompanionships,
        aliasName: 'callings__id__ministering_companionships__calling_id',
      );

  $$MinisteringCompanionshipsTableProcessedTableManager
  get ministeringCompanionshipsRefs {
    final manager = $$MinisteringCompanionshipsTableTableManager(
      $_db,
      $_db.ministeringCompanionships,
    ).filter((f) => f.callingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringCompanionshipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinisteringInterviewsTable,
    List<MinisteringInterviewRow>
  >
  _ministeringInterviewsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringInterviews,
        aliasName: 'callings__id__ministering_interviews__calling_id',
      );

  $$MinisteringInterviewsTableProcessedTableManager
  get ministeringInterviewsRefs {
    final manager = $$MinisteringInterviewsTableTableManager(
      $_db,
      $_db.ministeringInterviews,
    ).filter((f) => f.callingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringInterviewsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinisteringAppointmentsTable,
    List<MinisteringAppointmentRow>
  >
  _ministeringAppointmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringAppointments,
        aliasName: 'callings__id__ministering_appointments__calling_id',
      );

  $$MinisteringAppointmentsTableProcessedTableManager
  get ministeringAppointmentsRefs {
    final manager = $$MinisteringAppointmentsTableTableManager(
      $_db,
      $_db.ministeringAppointments,
    ).filter((f) => f.callingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringAppointmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CallingsTableFilterComposer
    extends Composer<_$AppDatabase, $CallingsTable> {
  $$CallingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ministeringBrothersRefs(
    Expression<bool> Function($$MinisteringBrothersTableFilterComposer f) f,
  ) {
    final $$MinisteringBrothersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ministeringBrothers,
      getReferencedColumn: (t) => t.callingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinisteringBrothersTableFilterComposer(
            $db: $db,
            $table: $db.ministeringBrothers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ministeringLeadersRefs(
    Expression<bool> Function($$MinisteringLeadersTableFilterComposer f) f,
  ) {
    final $$MinisteringLeadersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ministeringLeaders,
      getReferencedColumn: (t) => t.callingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinisteringLeadersTableFilterComposer(
            $db: $db,
            $table: $db.ministeringLeaders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ministeringCompanionshipsRefs(
    Expression<bool> Function($$MinisteringCompanionshipsTableFilterComposer f)
    f,
  ) {
    final $$MinisteringCompanionshipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringCompanionships,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringCompanionshipsTableFilterComposer(
                $db: $db,
                $table: $db.ministeringCompanionships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ministeringInterviewsRefs(
    Expression<bool> Function($$MinisteringInterviewsTableFilterComposer f) f,
  ) {
    final $$MinisteringInterviewsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringInterviews,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringInterviewsTableFilterComposer(
                $db: $db,
                $table: $db.ministeringInterviews,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ministeringAppointmentsRefs(
    Expression<bool> Function($$MinisteringAppointmentsTableFilterComposer f) f,
  ) {
    final $$MinisteringAppointmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringAppointments,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringAppointmentsTableFilterComposer(
                $db: $db,
                $table: $db.ministeringAppointments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CallingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallingsTable> {
  $$CallingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallingsTable> {
  $$CallingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get moduleKey =>
      $composableBuilder(column: $table.moduleKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ministeringBrothersRefs<T extends Object>(
    Expression<T> Function($$MinisteringBrothersTableAnnotationComposer a) f,
  ) {
    final $$MinisteringBrothersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringBrothers,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringBrothersTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringBrothers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ministeringLeadersRefs<T extends Object>(
    Expression<T> Function($$MinisteringLeadersTableAnnotationComposer a) f,
  ) {
    final $$MinisteringLeadersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringLeaders,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringLeadersTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringLeaders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ministeringCompanionshipsRefs<T extends Object>(
    Expression<T> Function($$MinisteringCompanionshipsTableAnnotationComposer a)
    f,
  ) {
    final $$MinisteringCompanionshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringCompanionships,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringCompanionshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringCompanionships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ministeringInterviewsRefs<T extends Object>(
    Expression<T> Function($$MinisteringInterviewsTableAnnotationComposer a) f,
  ) {
    final $$MinisteringInterviewsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringInterviews,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringInterviewsTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringInterviews,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ministeringAppointmentsRefs<T extends Object>(
    Expression<T> Function($$MinisteringAppointmentsTableAnnotationComposer a)
    f,
  ) {
    final $$MinisteringAppointmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringAppointments,
          getReferencedColumn: (t) => t.callingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringAppointmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringAppointments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CallingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallingsTable,
          CallingRow,
          $$CallingsTableFilterComposer,
          $$CallingsTableOrderingComposer,
          $$CallingsTableAnnotationComposer,
          $$CallingsTableCreateCompanionBuilder,
          $$CallingsTableUpdateCompanionBuilder,
          (CallingRow, $$CallingsTableReferences),
          CallingRow,
          PrefetchHooks Function({
            bool workspaceId,
            bool userId,
            bool ministeringBrothersRefs,
            bool ministeringLeadersRefs,
            bool ministeringCompanionshipsRefs,
            bool ministeringInterviewsRefs,
            bool ministeringAppointmentsRefs,
          })
        > {
  $$CallingsTableTableManager(_$AppDatabase db, $CallingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> moduleKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallingsCompanion(
                id: id,
                workspaceId: workspaceId,
                userId: userId,
                title: title,
                moduleKey: moduleKey,
                status: status,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String userId,
                required String title,
                required String moduleKey,
                required String status,
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallingsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                userId: userId,
                title: title,
                moduleKey: moduleKey,
                status: status,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                userId = false,
                ministeringBrothersRefs = false,
                ministeringLeadersRefs = false,
                ministeringCompanionshipsRefs = false,
                ministeringInterviewsRefs = false,
                ministeringAppointmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ministeringBrothersRefs) db.ministeringBrothers,
                    if (ministeringLeadersRefs) db.ministeringLeaders,
                    if (ministeringCompanionshipsRefs)
                      db.ministeringCompanionships,
                    if (ministeringInterviewsRefs) db.ministeringInterviews,
                    if (ministeringAppointmentsRefs) db.ministeringAppointments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workspaceId,
                            referencedTable: $$CallingsTableReferences
                                ._workspaceIdTable(db),
                            referencedColumn: $$CallingsTableReferences
                                ._workspaceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (userId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.userId,
                            referencedTable: $$CallingsTableReferences
                                ._userIdTable(db),
                            referencedColumn: $$CallingsTableReferences
                                ._userIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ministeringBrothersRefs)
                        await $_getPrefetchedData<
                          CallingRow,
                          $CallingsTable,
                          MinisteringBrotherRow
                        >(
                          currentTable: table,
                          referencedTable: $$CallingsTableReferences
                              ._ministeringBrothersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallingsTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringBrothersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.callingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ministeringLeadersRefs)
                        await $_getPrefetchedData<
                          CallingRow,
                          $CallingsTable,
                          MinisteringLeaderRow
                        >(
                          currentTable: table,
                          referencedTable: $$CallingsTableReferences
                              ._ministeringLeadersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallingsTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringLeadersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.callingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ministeringCompanionshipsRefs)
                        await $_getPrefetchedData<
                          CallingRow,
                          $CallingsTable,
                          MinisteringCompanionshipRow
                        >(
                          currentTable: table,
                          referencedTable: $$CallingsTableReferences
                              ._ministeringCompanionshipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallingsTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringCompanionshipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.callingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ministeringInterviewsRefs)
                        await $_getPrefetchedData<
                          CallingRow,
                          $CallingsTable,
                          MinisteringInterviewRow
                        >(
                          currentTable: table,
                          referencedTable: $$CallingsTableReferences
                              ._ministeringInterviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallingsTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringInterviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.callingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ministeringAppointmentsRefs)
                        await $_getPrefetchedData<
                          CallingRow,
                          $CallingsTable,
                          MinisteringAppointmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$CallingsTableReferences
                              ._ministeringAppointmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallingsTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringAppointmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.callingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CallingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallingsTable,
      CallingRow,
      $$CallingsTableFilterComposer,
      $$CallingsTableOrderingComposer,
      $$CallingsTableAnnotationComposer,
      $$CallingsTableCreateCompanionBuilder,
      $$CallingsTableUpdateCompanionBuilder,
      (CallingRow, $$CallingsTableReferences),
      CallingRow,
      PrefetchHooks Function({
        bool workspaceId,
        bool userId,
        bool ministeringBrothersRefs,
        bool ministeringLeadersRefs,
        bool ministeringCompanionshipsRefs,
        bool ministeringInterviewsRefs,
        bool ministeringAppointmentsRefs,
      })
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreferenceRow,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $AppPreferencesTable,
              AppPreferenceRow
            >,
          ),
          AppPreferenceRow,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreferenceRow,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreferenceRow,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>,
      ),
      AppPreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$MinisteringBrothersTableCreateCompanionBuilder =
    MinisteringBrothersCompanion Function({
      required String id,
      required String callingId,
      required String displayLabel,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MinisteringBrothersTableUpdateCompanionBuilder =
    MinisteringBrothersCompanion Function({
      Value<String> id,
      Value<String> callingId,
      Value<String> displayLabel,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MinisteringBrothersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinisteringBrothersTable,
          MinisteringBrotherRow
        > {
  $$MinisteringBrothersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallingsTable _callingIdTable(_$AppDatabase db) =>
      db.callings.createAlias('ministering_brothers__calling_id__callings__id');

  $$CallingsTableProcessedTableManager get callingId {
    final $_column = $_itemColumn<String>('calling_id')!;

    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinisteringBrothersTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringBrothersTable> {
  $$MinisteringBrothersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallingsTableFilterComposer get callingId {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringBrothersTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringBrothersTable> {
  $$MinisteringBrothersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallingsTableOrderingComposer get callingId {
    final $$CallingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableOrderingComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringBrothersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringBrothersTable> {
  $$MinisteringBrothersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CallingsTableAnnotationComposer get callingId {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringBrothersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringBrothersTable,
          MinisteringBrotherRow,
          $$MinisteringBrothersTableFilterComposer,
          $$MinisteringBrothersTableOrderingComposer,
          $$MinisteringBrothersTableAnnotationComposer,
          $$MinisteringBrothersTableCreateCompanionBuilder,
          $$MinisteringBrothersTableUpdateCompanionBuilder,
          (MinisteringBrotherRow, $$MinisteringBrothersTableReferences),
          MinisteringBrotherRow,
          PrefetchHooks Function({bool callingId})
        > {
  $$MinisteringBrothersTableTableManager(
    _$AppDatabase db,
    $MinisteringBrothersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringBrothersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinisteringBrothersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringBrothersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String> displayLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringBrothersCompanion(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callingId,
                required String displayLabel,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringBrothersCompanion.insert(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinisteringBrothersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (callingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.callingId,
                        referencedTable: $$MinisteringBrothersTableReferences
                            ._callingIdTable(db),
                        referencedColumn: $$MinisteringBrothersTableReferences
                            ._callingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinisteringBrothersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringBrothersTable,
      MinisteringBrotherRow,
      $$MinisteringBrothersTableFilterComposer,
      $$MinisteringBrothersTableOrderingComposer,
      $$MinisteringBrothersTableAnnotationComposer,
      $$MinisteringBrothersTableCreateCompanionBuilder,
      $$MinisteringBrothersTableUpdateCompanionBuilder,
      (MinisteringBrotherRow, $$MinisteringBrothersTableReferences),
      MinisteringBrotherRow,
      PrefetchHooks Function({bool callingId})
    >;
typedef $$MinisteringLeadersTableCreateCompanionBuilder =
    MinisteringLeadersCompanion Function({
      required String id,
      required String callingId,
      required String displayLabel,
      required String role,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MinisteringLeadersTableUpdateCompanionBuilder =
    MinisteringLeadersCompanion Function({
      Value<String> id,
      Value<String> callingId,
      Value<String> displayLabel,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MinisteringLeadersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinisteringLeadersTable,
          MinisteringLeaderRow
        > {
  $$MinisteringLeadersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallingsTable _callingIdTable(_$AppDatabase db) =>
      db.callings.createAlias('ministering_leaders__calling_id__callings__id');

  $$CallingsTableProcessedTableManager get callingId {
    final $_column = $_itemColumn<String>('calling_id')!;

    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MinisteringInterviewsTable,
    List<MinisteringInterviewRow>
  >
  _ministeringInterviewsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ministeringInterviews,
        aliasName:
            'ministering_leaders__id__ministering_interviews__interviewer_id',
      );

  $$MinisteringInterviewsTableProcessedTableManager
  get ministeringInterviewsRefs {
    final manager = $$MinisteringInterviewsTableTableManager(
      $_db,
      $_db.ministeringInterviews,
    ).filter((f) => f.interviewerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ministeringInterviewsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MinisteringLeadersTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringLeadersTable> {
  $$MinisteringLeadersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallingsTableFilterComposer get callingId {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ministeringInterviewsRefs(
    Expression<bool> Function($$MinisteringInterviewsTableFilterComposer f) f,
  ) {
    final $$MinisteringInterviewsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringInterviews,
          getReferencedColumn: (t) => t.interviewerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringInterviewsTableFilterComposer(
                $db: $db,
                $table: $db.ministeringInterviews,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MinisteringLeadersTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringLeadersTable> {
  $$MinisteringLeadersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallingsTableOrderingComposer get callingId {
    final $$CallingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableOrderingComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringLeadersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringLeadersTable> {
  $$MinisteringLeadersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CallingsTableAnnotationComposer get callingId {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ministeringInterviewsRefs<T extends Object>(
    Expression<T> Function($$MinisteringInterviewsTableAnnotationComposer a) f,
  ) {
    final $$MinisteringInterviewsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ministeringInterviews,
          getReferencedColumn: (t) => t.interviewerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringInterviewsTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringInterviews,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MinisteringLeadersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringLeadersTable,
          MinisteringLeaderRow,
          $$MinisteringLeadersTableFilterComposer,
          $$MinisteringLeadersTableOrderingComposer,
          $$MinisteringLeadersTableAnnotationComposer,
          $$MinisteringLeadersTableCreateCompanionBuilder,
          $$MinisteringLeadersTableUpdateCompanionBuilder,
          (MinisteringLeaderRow, $$MinisteringLeadersTableReferences),
          MinisteringLeaderRow,
          PrefetchHooks Function({
            bool callingId,
            bool ministeringInterviewsRefs,
          })
        > {
  $$MinisteringLeadersTableTableManager(
    _$AppDatabase db,
    $MinisteringLeadersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringLeadersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinisteringLeadersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MinisteringLeadersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String> displayLabel = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringLeadersCompanion(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callingId,
                required String displayLabel,
                required String role,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringLeadersCompanion.insert(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinisteringLeadersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({callingId = false, ministeringInterviewsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ministeringInterviewsRefs) db.ministeringInterviews,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (callingId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.callingId,
                            referencedTable: $$MinisteringLeadersTableReferences
                                ._callingIdTable(db),
                            referencedColumn:
                                $$MinisteringLeadersTableReferences
                                    ._callingIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ministeringInterviewsRefs)
                        await $_getPrefetchedData<
                          MinisteringLeaderRow,
                          $MinisteringLeadersTable,
                          MinisteringInterviewRow
                        >(
                          currentTable: table,
                          referencedTable: $$MinisteringLeadersTableReferences
                              ._ministeringInterviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MinisteringLeadersTableReferences(
                                db,
                                table,
                                p0,
                              ).ministeringInterviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.interviewerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MinisteringLeadersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringLeadersTable,
      MinisteringLeaderRow,
      $$MinisteringLeadersTableFilterComposer,
      $$MinisteringLeadersTableOrderingComposer,
      $$MinisteringLeadersTableAnnotationComposer,
      $$MinisteringLeadersTableCreateCompanionBuilder,
      $$MinisteringLeadersTableUpdateCompanionBuilder,
      (MinisteringLeaderRow, $$MinisteringLeadersTableReferences),
      MinisteringLeaderRow,
      PrefetchHooks Function({bool callingId, bool ministeringInterviewsRefs})
    >;
typedef $$MinisteringCompanionshipsTableCreateCompanionBuilder =
    MinisteringCompanionshipsCompanion Function({
      required String id,
      required String callingId,
      Value<String?> displayLabel,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MinisteringCompanionshipsTableUpdateCompanionBuilder =
    MinisteringCompanionshipsCompanion Function({
      Value<String> id,
      Value<String> callingId,
      Value<String?> displayLabel,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MinisteringCompanionshipsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinisteringCompanionshipsTable,
          MinisteringCompanionshipRow
        > {
  $$MinisteringCompanionshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallingsTable _callingIdTable(_$AppDatabase db) => db.callings
      .createAlias('ministering_companionships__calling_id__callings__id');

  $$CallingsTableProcessedTableManager get callingId {
    final $_column = $_itemColumn<String>('calling_id')!;

    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinisteringCompanionshipsTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipsTable> {
  $$MinisteringCompanionshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallingsTableFilterComposer get callingId {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringCompanionshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipsTable> {
  $$MinisteringCompanionshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallingsTableOrderingComposer get callingId {
    final $$CallingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableOrderingComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringCompanionshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipsTable> {
  $$MinisteringCompanionshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CallingsTableAnnotationComposer get callingId {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringCompanionshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringCompanionshipsTable,
          MinisteringCompanionshipRow,
          $$MinisteringCompanionshipsTableFilterComposer,
          $$MinisteringCompanionshipsTableOrderingComposer,
          $$MinisteringCompanionshipsTableAnnotationComposer,
          $$MinisteringCompanionshipsTableCreateCompanionBuilder,
          $$MinisteringCompanionshipsTableUpdateCompanionBuilder,
          (
            MinisteringCompanionshipRow,
            $$MinisteringCompanionshipsTableReferences,
          ),
          MinisteringCompanionshipRow,
          PrefetchHooks Function({bool callingId})
        > {
  $$MinisteringCompanionshipsTableTableManager(
    _$AppDatabase db,
    $MinisteringCompanionshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringCompanionshipsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinisteringCompanionshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringCompanionshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String?> displayLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringCompanionshipsCompanion(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callingId,
                Value<String?> displayLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringCompanionshipsCompanion.insert(
                id: id,
                callingId: callingId,
                displayLabel: displayLabel,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinisteringCompanionshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (callingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.callingId,
                        referencedTable:
                            $$MinisteringCompanionshipsTableReferences
                                ._callingIdTable(db),
                        referencedColumn:
                            $$MinisteringCompanionshipsTableReferences
                                ._callingIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinisteringCompanionshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringCompanionshipsTable,
      MinisteringCompanionshipRow,
      $$MinisteringCompanionshipsTableFilterComposer,
      $$MinisteringCompanionshipsTableOrderingComposer,
      $$MinisteringCompanionshipsTableAnnotationComposer,
      $$MinisteringCompanionshipsTableCreateCompanionBuilder,
      $$MinisteringCompanionshipsTableUpdateCompanionBuilder,
      (MinisteringCompanionshipRow, $$MinisteringCompanionshipsTableReferences),
      MinisteringCompanionshipRow,
      PrefetchHooks Function({bool callingId})
    >;
typedef $$MinisteringCompanionshipMembersTableCreateCompanionBuilder =
    MinisteringCompanionshipMembersCompanion Function({
      required String companionshipId,
      required String brotherId,
      required String callingId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MinisteringCompanionshipMembersTableUpdateCompanionBuilder =
    MinisteringCompanionshipMembersCompanion Function({
      Value<String> companionshipId,
      Value<String> brotherId,
      Value<String> callingId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MinisteringCompanionshipMembersTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipMembersTable> {
  $$MinisteringCompanionshipMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherId => $composableBuilder(
    column: $table.brotherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callingId => $composableBuilder(
    column: $table.callingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MinisteringCompanionshipMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipMembersTable> {
  $$MinisteringCompanionshipMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherId => $composableBuilder(
    column: $table.brotherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callingId => $composableBuilder(
    column: $table.callingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MinisteringCompanionshipMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringCompanionshipMembersTable> {
  $$MinisteringCompanionshipMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherId =>
      $composableBuilder(column: $table.brotherId, builder: (column) => column);

  GeneratedColumn<String> get callingId =>
      $composableBuilder(column: $table.callingId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MinisteringCompanionshipMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringCompanionshipMembersTable,
          MinisteringCompanionshipMemberRow,
          $$MinisteringCompanionshipMembersTableFilterComposer,
          $$MinisteringCompanionshipMembersTableOrderingComposer,
          $$MinisteringCompanionshipMembersTableAnnotationComposer,
          $$MinisteringCompanionshipMembersTableCreateCompanionBuilder,
          $$MinisteringCompanionshipMembersTableUpdateCompanionBuilder,
          (
            MinisteringCompanionshipMemberRow,
            BaseReferences<
              _$AppDatabase,
              $MinisteringCompanionshipMembersTable,
              MinisteringCompanionshipMemberRow
            >,
          ),
          MinisteringCompanionshipMemberRow,
          PrefetchHooks Function()
        > {
  $$MinisteringCompanionshipMembersTableTableManager(
    _$AppDatabase db,
    $MinisteringCompanionshipMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringCompanionshipMembersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinisteringCompanionshipMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringCompanionshipMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> companionshipId = const Value.absent(),
                Value<String> brotherId = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringCompanionshipMembersCompanion(
                companionshipId: companionshipId,
                brotherId: brotherId,
                callingId: callingId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String companionshipId,
                required String brotherId,
                required String callingId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringCompanionshipMembersCompanion.insert(
                companionshipId: companionshipId,
                brotherId: brotherId,
                callingId: callingId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MinisteringCompanionshipMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringCompanionshipMembersTable,
      MinisteringCompanionshipMemberRow,
      $$MinisteringCompanionshipMembersTableFilterComposer,
      $$MinisteringCompanionshipMembersTableOrderingComposer,
      $$MinisteringCompanionshipMembersTableAnnotationComposer,
      $$MinisteringCompanionshipMembersTableCreateCompanionBuilder,
      $$MinisteringCompanionshipMembersTableUpdateCompanionBuilder,
      (
        MinisteringCompanionshipMemberRow,
        BaseReferences<
          _$AppDatabase,
          $MinisteringCompanionshipMembersTable,
          MinisteringCompanionshipMemberRow
        >,
      ),
      MinisteringCompanionshipMemberRow,
      PrefetchHooks Function()
    >;
typedef $$MinisteringInterviewsTableCreateCompanionBuilder =
    MinisteringInterviewsCompanion Function({
      required String id,
      required String callingId,
      required String companionshipId,
      Value<String?> interviewerId,
      required DateTime completedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MinisteringInterviewsTableUpdateCompanionBuilder =
    MinisteringInterviewsCompanion Function({
      Value<String> id,
      Value<String> callingId,
      Value<String> companionshipId,
      Value<String?> interviewerId,
      Value<DateTime> completedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MinisteringInterviewsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinisteringInterviewsTable,
          MinisteringInterviewRow
        > {
  $$MinisteringInterviewsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallingsTable _callingIdTable(_$AppDatabase db) => db.callings
      .createAlias('ministering_interviews__calling_id__callings__id');

  $$CallingsTableProcessedTableManager get callingId {
    final $_column = $_itemColumn<String>('calling_id')!;

    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MinisteringLeadersTable _interviewerIdTable(_$AppDatabase db) =>
      db.ministeringLeaders.createAlias(
        'ministering_interviews__interviewer_id__ministering_leaders__id',
      );

  $$MinisteringLeadersTableProcessedTableManager? get interviewerId {
    final $_column = $_itemColumn<String>('interviewer_id');
    if ($_column == null) return null;
    final manager = $$MinisteringLeadersTableTableManager(
      $_db,
      $_db.ministeringLeaders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_interviewerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinisteringInterviewsTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewsTable> {
  $$MinisteringInterviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallingsTableFilterComposer get callingId {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinisteringLeadersTableFilterComposer get interviewerId {
    final $$MinisteringLeadersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interviewerId,
      referencedTable: $db.ministeringLeaders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinisteringLeadersTableFilterComposer(
            $db: $db,
            $table: $db.ministeringLeaders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringInterviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewsTable> {
  $$MinisteringInterviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallingsTableOrderingComposer get callingId {
    final $$CallingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableOrderingComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinisteringLeadersTableOrderingComposer get interviewerId {
    final $$MinisteringLeadersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interviewerId,
      referencedTable: $db.ministeringLeaders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinisteringLeadersTableOrderingComposer(
            $db: $db,
            $table: $db.ministeringLeaders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringInterviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewsTable> {
  $$MinisteringInterviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CallingsTableAnnotationComposer get callingId {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinisteringLeadersTableAnnotationComposer get interviewerId {
    final $$MinisteringLeadersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.interviewerId,
          referencedTable: $db.ministeringLeaders,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinisteringLeadersTableAnnotationComposer(
                $db: $db,
                $table: $db.ministeringLeaders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MinisteringInterviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringInterviewsTable,
          MinisteringInterviewRow,
          $$MinisteringInterviewsTableFilterComposer,
          $$MinisteringInterviewsTableOrderingComposer,
          $$MinisteringInterviewsTableAnnotationComposer,
          $$MinisteringInterviewsTableCreateCompanionBuilder,
          $$MinisteringInterviewsTableUpdateCompanionBuilder,
          (MinisteringInterviewRow, $$MinisteringInterviewsTableReferences),
          MinisteringInterviewRow,
          PrefetchHooks Function({bool callingId, bool interviewerId})
        > {
  $$MinisteringInterviewsTableTableManager(
    _$AppDatabase db,
    $MinisteringInterviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringInterviewsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinisteringInterviewsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringInterviewsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String> companionshipId = const Value.absent(),
                Value<String?> interviewerId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringInterviewsCompanion(
                id: id,
                callingId: callingId,
                companionshipId: companionshipId,
                interviewerId: interviewerId,
                completedAt: completedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callingId,
                required String companionshipId,
                Value<String?> interviewerId = const Value.absent(),
                required DateTime completedAt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringInterviewsCompanion.insert(
                id: id,
                callingId: callingId,
                companionshipId: companionshipId,
                interviewerId: interviewerId,
                completedAt: completedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinisteringInterviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callingId = false, interviewerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (callingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.callingId,
                        referencedTable: $$MinisteringInterviewsTableReferences
                            ._callingIdTable(db),
                        referencedColumn: $$MinisteringInterviewsTableReferences
                            ._callingIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (interviewerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.interviewerId,
                        referencedTable: $$MinisteringInterviewsTableReferences
                            ._interviewerIdTable(db),
                        referencedColumn: $$MinisteringInterviewsTableReferences
                            ._interviewerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinisteringInterviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringInterviewsTable,
      MinisteringInterviewRow,
      $$MinisteringInterviewsTableFilterComposer,
      $$MinisteringInterviewsTableOrderingComposer,
      $$MinisteringInterviewsTableAnnotationComposer,
      $$MinisteringInterviewsTableCreateCompanionBuilder,
      $$MinisteringInterviewsTableUpdateCompanionBuilder,
      (MinisteringInterviewRow, $$MinisteringInterviewsTableReferences),
      MinisteringInterviewRow,
      PrefetchHooks Function({bool callingId, bool interviewerId})
    >;
typedef $$MinisteringInterviewParticipantsTableCreateCompanionBuilder =
    MinisteringInterviewParticipantsCompanion Function({
      required String interviewId,
      required String brotherId,
      required String callingId,
      required String companionshipId,
      Value<int> rowid,
    });
typedef $$MinisteringInterviewParticipantsTableUpdateCompanionBuilder =
    MinisteringInterviewParticipantsCompanion Function({
      Value<String> interviewId,
      Value<String> brotherId,
      Value<String> callingId,
      Value<String> companionshipId,
      Value<int> rowid,
    });

class $$MinisteringInterviewParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewParticipantsTable> {
  $$MinisteringInterviewParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get interviewId => $composableBuilder(
    column: $table.interviewId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherId => $composableBuilder(
    column: $table.brotherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callingId => $composableBuilder(
    column: $table.callingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MinisteringInterviewParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewParticipantsTable> {
  $$MinisteringInterviewParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get interviewId => $composableBuilder(
    column: $table.interviewId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherId => $composableBuilder(
    column: $table.brotherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callingId => $composableBuilder(
    column: $table.callingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MinisteringInterviewParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringInterviewParticipantsTable> {
  $$MinisteringInterviewParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get interviewId => $composableBuilder(
    column: $table.interviewId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherId =>
      $composableBuilder(column: $table.brotherId, builder: (column) => column);

  GeneratedColumn<String> get callingId =>
      $composableBuilder(column: $table.callingId, builder: (column) => column);

  GeneratedColumn<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => column,
  );
}

class $$MinisteringInterviewParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringInterviewParticipantsTable,
          MinisteringInterviewParticipantRow,
          $$MinisteringInterviewParticipantsTableFilterComposer,
          $$MinisteringInterviewParticipantsTableOrderingComposer,
          $$MinisteringInterviewParticipantsTableAnnotationComposer,
          $$MinisteringInterviewParticipantsTableCreateCompanionBuilder,
          $$MinisteringInterviewParticipantsTableUpdateCompanionBuilder,
          (
            MinisteringInterviewParticipantRow,
            BaseReferences<
              _$AppDatabase,
              $MinisteringInterviewParticipantsTable,
              MinisteringInterviewParticipantRow
            >,
          ),
          MinisteringInterviewParticipantRow,
          PrefetchHooks Function()
        > {
  $$MinisteringInterviewParticipantsTableTableManager(
    _$AppDatabase db,
    $MinisteringInterviewParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringInterviewParticipantsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinisteringInterviewParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringInterviewParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> interviewId = const Value.absent(),
                Value<String> brotherId = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String> companionshipId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringInterviewParticipantsCompanion(
                interviewId: interviewId,
                brotherId: brotherId,
                callingId: callingId,
                companionshipId: companionshipId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String interviewId,
                required String brotherId,
                required String callingId,
                required String companionshipId,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringInterviewParticipantsCompanion.insert(
                interviewId: interviewId,
                brotherId: brotherId,
                callingId: callingId,
                companionshipId: companionshipId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MinisteringInterviewParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringInterviewParticipantsTable,
      MinisteringInterviewParticipantRow,
      $$MinisteringInterviewParticipantsTableFilterComposer,
      $$MinisteringInterviewParticipantsTableOrderingComposer,
      $$MinisteringInterviewParticipantsTableAnnotationComposer,
      $$MinisteringInterviewParticipantsTableCreateCompanionBuilder,
      $$MinisteringInterviewParticipantsTableUpdateCompanionBuilder,
      (
        MinisteringInterviewParticipantRow,
        BaseReferences<
          _$AppDatabase,
          $MinisteringInterviewParticipantsTable,
          MinisteringInterviewParticipantRow
        >,
      ),
      MinisteringInterviewParticipantRow,
      PrefetchHooks Function()
    >;
typedef $$MinisteringAppointmentsTableCreateCompanionBuilder =
    MinisteringAppointmentsCompanion Function({
      required String id,
      required String callingId,
      required String companionshipId,
      required String interviewerId,
      required DateTime scheduledAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MinisteringAppointmentsTableUpdateCompanionBuilder =
    MinisteringAppointmentsCompanion Function({
      Value<String> id,
      Value<String> callingId,
      Value<String> companionshipId,
      Value<String> interviewerId,
      Value<DateTime> scheduledAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MinisteringAppointmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinisteringAppointmentsTable,
          MinisteringAppointmentRow
        > {
  $$MinisteringAppointmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallingsTable _callingIdTable(_$AppDatabase db) => db.callings
      .createAlias('ministering_appointments__calling_id__callings__id');

  $$CallingsTableProcessedTableManager get callingId {
    final $_column = $_itemColumn<String>('calling_id')!;

    final manager = $$CallingsTableTableManager(
      $_db,
      $_db.callings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinisteringAppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $MinisteringAppointmentsTable> {
  $$MinisteringAppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interviewerId => $composableBuilder(
    column: $table.interviewerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallingsTableFilterComposer get callingId {
    final $$CallingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableFilterComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringAppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MinisteringAppointmentsTable> {
  $$MinisteringAppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interviewerId => $composableBuilder(
    column: $table.interviewerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallingsTableOrderingComposer get callingId {
    final $$CallingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableOrderingComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringAppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinisteringAppointmentsTable> {
  $$MinisteringAppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companionshipId => $composableBuilder(
    column: $table.companionshipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interviewerId => $composableBuilder(
    column: $table.interviewerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CallingsTableAnnotationComposer get callingId {
    final $$CallingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callingId,
      referencedTable: $db.callings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinisteringAppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinisteringAppointmentsTable,
          MinisteringAppointmentRow,
          $$MinisteringAppointmentsTableFilterComposer,
          $$MinisteringAppointmentsTableOrderingComposer,
          $$MinisteringAppointmentsTableAnnotationComposer,
          $$MinisteringAppointmentsTableCreateCompanionBuilder,
          $$MinisteringAppointmentsTableUpdateCompanionBuilder,
          (MinisteringAppointmentRow, $$MinisteringAppointmentsTableReferences),
          MinisteringAppointmentRow,
          PrefetchHooks Function({bool callingId})
        > {
  $$MinisteringAppointmentsTableTableManager(
    _$AppDatabase db,
    $MinisteringAppointmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinisteringAppointmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinisteringAppointmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinisteringAppointmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callingId = const Value.absent(),
                Value<String> companionshipId = const Value.absent(),
                Value<String> interviewerId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinisteringAppointmentsCompanion(
                id: id,
                callingId: callingId,
                companionshipId: companionshipId,
                interviewerId: interviewerId,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callingId,
                required String companionshipId,
                required String interviewerId,
                required DateTime scheduledAt,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinisteringAppointmentsCompanion.insert(
                id: id,
                callingId: callingId,
                companionshipId: companionshipId,
                interviewerId: interviewerId,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinisteringAppointmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (callingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.callingId,
                        referencedTable:
                            $$MinisteringAppointmentsTableReferences
                                ._callingIdTable(db),
                        referencedColumn:
                            $$MinisteringAppointmentsTableReferences
                                ._callingIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinisteringAppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinisteringAppointmentsTable,
      MinisteringAppointmentRow,
      $$MinisteringAppointmentsTableFilterComposer,
      $$MinisteringAppointmentsTableOrderingComposer,
      $$MinisteringAppointmentsTableAnnotationComposer,
      $$MinisteringAppointmentsTableCreateCompanionBuilder,
      $$MinisteringAppointmentsTableUpdateCompanionBuilder,
      (MinisteringAppointmentRow, $$MinisteringAppointmentsTableReferences),
      MinisteringAppointmentRow,
      PrefetchHooks Function({bool callingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MembershipsTableTableManager get memberships =>
      $$MembershipsTableTableManager(_db, _db.memberships);
  $$CallingsTableTableManager get callings =>
      $$CallingsTableTableManager(_db, _db.callings);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$MinisteringBrothersTableTableManager get ministeringBrothers =>
      $$MinisteringBrothersTableTableManager(_db, _db.ministeringBrothers);
  $$MinisteringLeadersTableTableManager get ministeringLeaders =>
      $$MinisteringLeadersTableTableManager(_db, _db.ministeringLeaders);
  $$MinisteringCompanionshipsTableTableManager get ministeringCompanionships =>
      $$MinisteringCompanionshipsTableTableManager(
        _db,
        _db.ministeringCompanionships,
      );
  $$MinisteringCompanionshipMembersTableTableManager
  get ministeringCompanionshipMembers =>
      $$MinisteringCompanionshipMembersTableTableManager(
        _db,
        _db.ministeringCompanionshipMembers,
      );
  $$MinisteringInterviewsTableTableManager get ministeringInterviews =>
      $$MinisteringInterviewsTableTableManager(_db, _db.ministeringInterviews);
  $$MinisteringInterviewParticipantsTableTableManager
  get ministeringInterviewParticipants =>
      $$MinisteringInterviewParticipantsTableTableManager(
        _db,
        _db.ministeringInterviewParticipants,
      );
  $$MinisteringAppointmentsTableTableManager get ministeringAppointments =>
      $$MinisteringAppointmentsTableTableManager(
        _db,
        _db.ministeringAppointments,
      );
}
