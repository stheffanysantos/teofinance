// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsCategoryMeta = const VerificationMeta(
    'needsCategory',
  );
  @override
  late final GeneratedColumn<bool> needsCategory = GeneratedColumn<bool>(
    'needs_category',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_category" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($TransactionsTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _parcelamentoIdMeta = const VerificationMeta(
    'parcelamentoId',
  );
  @override
  late final GeneratedColumn<String> parcelamentoId = GeneratedColumn<String>(
    'parcelamento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numeroParcelaMeta = const VerificationMeta(
    'numeroParcela',
  );
  @override
  late final GeneratedColumn<int> numeroParcela = GeneratedColumn<int>(
    'numero_parcela',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorParcelaMeta = const VerificationMeta(
    'valorParcela',
  );
  @override
  late final GeneratedColumn<double> valorParcela = GeneratedColumn<double>(
    'valor_parcela',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ehParcelaMeta = const VerificationMeta(
    'ehParcela',
  );
  @override
  late final GeneratedColumn<bool> ehParcela = GeneratedColumn<bool>(
    'eh_parcela',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("eh_parcela" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusParcelaMeta = const VerificationMeta(
    'statusParcela',
  );
  @override
  late final GeneratedColumn<String> statusParcela = GeneratedColumn<String>(
    'status_parcela',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minhaParteMeta = const VerificationMeta(
    'minhaParte',
  );
  @override
  late final GeneratedColumn<double> minhaParte = GeneratedColumn<double>(
    'minha_parte',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _divididoComMeta = const VerificationMeta(
    'divididoCom',
  );
  @override
  late final GeneratedColumn<String> divididoCom = GeneratedColumn<String>(
    'dividido_com',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    name,
    category,
    value,
    occurredAt,
    needsCategory,
    syncStatus,
    updatedAt,
    parcelamentoId,
    numeroParcela,
    valorParcela,
    ehParcela,
    statusParcela,
    minhaParte,
    divididoCom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('needs_category')) {
      context.handle(
        _needsCategoryMeta,
        needsCategory.isAcceptableOrUnknown(
          data['needs_category']!,
          _needsCategoryMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('parcelamento_id')) {
      context.handle(
        _parcelamentoIdMeta,
        parcelamentoId.isAcceptableOrUnknown(
          data['parcelamento_id']!,
          _parcelamentoIdMeta,
        ),
      );
    }
    if (data.containsKey('numero_parcela')) {
      context.handle(
        _numeroParcelaMeta,
        numeroParcela.isAcceptableOrUnknown(
          data['numero_parcela']!,
          _numeroParcelaMeta,
        ),
      );
    }
    if (data.containsKey('valor_parcela')) {
      context.handle(
        _valorParcelaMeta,
        valorParcela.isAcceptableOrUnknown(
          data['valor_parcela']!,
          _valorParcelaMeta,
        ),
      );
    }
    if (data.containsKey('eh_parcela')) {
      context.handle(
        _ehParcelaMeta,
        ehParcela.isAcceptableOrUnknown(data['eh_parcela']!, _ehParcelaMeta),
      );
    }
    if (data.containsKey('status_parcela')) {
      context.handle(
        _statusParcelaMeta,
        statusParcela.isAcceptableOrUnknown(
          data['status_parcela']!,
          _statusParcelaMeta,
        ),
      );
    }
    if (data.containsKey('minha_parte')) {
      context.handle(
        _minhaParteMeta,
        minhaParte.isAcceptableOrUnknown(data['minha_parte']!, _minhaParteMeta),
      );
    }
    if (data.containsKey('dividido_com')) {
      context.handle(
        _divididoComMeta,
        divididoCom.isAcceptableOrUnknown(
          data['dividido_com']!,
          _divididoComMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      needsCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_category'],
      )!,
      syncStatus: $TransactionsTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      parcelamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcelamento_id'],
      ),
      numeroParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_parcela'],
      ),
      valorParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_parcela'],
      ),
      ehParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}eh_parcela'],
      )!,
      statusParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_parcela'],
      ),
      minhaParte: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minha_parte'],
      ),
      divididoCom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividido_com'],
      ),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String? remoteId;
  final String name;
  final String category;
  final double value;
  final DateTime occurredAt;
  final bool needsCategory;
  final SyncStatus syncStatus;
  final DateTime updatedAt;

  /// Parcelamento: campos adicionados na v5 (Sprint 02)
  /// FK → ParcelamentoTable (nulo se não é parcela)
  final String? parcelamentoId;

  /// Número da parcela: 1, 2, 3... (nulo se não é parcela)
  final int? numeroParcela;

  /// Valor da parcela individual (nulo se não é parcela)
  final double? valorParcela;

  /// true se é transação-filha de um parcelamento, false caso contrário
  final bool ehParcela;

  /// Status da parcela: 'pendente' | 'pago' | 'atrasado' (nulo se não é parcela)
  final String? statusParcela;

  /// Divisão de despesa (v7): quanto da compra é realmente do usuário. Nulo =
  /// não dividida. `valor` continua sendo o total cobrado pelo banco.
  final double? minhaParte;

  /// Nomes das outras pessoas, em JSON (`["Ana","Bruno"]`).
  final String? divididoCom;
  const TransactionsTableData({
    required this.id,
    this.remoteId,
    required this.name,
    required this.category,
    required this.value,
    required this.occurredAt,
    required this.needsCategory,
    required this.syncStatus,
    required this.updatedAt,
    this.parcelamentoId,
    this.numeroParcela,
    this.valorParcela,
    required this.ehParcela,
    this.statusParcela,
    this.minhaParte,
    this.divididoCom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['value'] = Variable<double>(value);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['needs_category'] = Variable<bool>(needsCategory);
    {
      map['sync_status'] = Variable<int>(
        $TransactionsTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || parcelamentoId != null) {
      map['parcelamento_id'] = Variable<String>(parcelamentoId);
    }
    if (!nullToAbsent || numeroParcela != null) {
      map['numero_parcela'] = Variable<int>(numeroParcela);
    }
    if (!nullToAbsent || valorParcela != null) {
      map['valor_parcela'] = Variable<double>(valorParcela);
    }
    map['eh_parcela'] = Variable<bool>(ehParcela);
    if (!nullToAbsent || statusParcela != null) {
      map['status_parcela'] = Variable<String>(statusParcela);
    }
    if (!nullToAbsent || minhaParte != null) {
      map['minha_parte'] = Variable<double>(minhaParte);
    }
    if (!nullToAbsent || divididoCom != null) {
      map['dividido_com'] = Variable<String>(divididoCom);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      category: Value(category),
      value: Value(value),
      occurredAt: Value(occurredAt),
      needsCategory: Value(needsCategory),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
      parcelamentoId: parcelamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelamentoId),
      numeroParcela: numeroParcela == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroParcela),
      valorParcela: valorParcela == null && nullToAbsent
          ? const Value.absent()
          : Value(valorParcela),
      ehParcela: Value(ehParcela),
      statusParcela: statusParcela == null && nullToAbsent
          ? const Value.absent()
          : Value(statusParcela),
      minhaParte: minhaParte == null && nullToAbsent
          ? const Value.absent()
          : Value(minhaParte),
      divididoCom: divididoCom == null && nullToAbsent
          ? const Value.absent()
          : Value(divididoCom),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      value: serializer.fromJson<double>(json['value']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      needsCategory: serializer.fromJson<bool>(json['needsCategory']),
      syncStatus: $TransactionsTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      parcelamentoId: serializer.fromJson<String?>(json['parcelamentoId']),
      numeroParcela: serializer.fromJson<int?>(json['numeroParcela']),
      valorParcela: serializer.fromJson<double?>(json['valorParcela']),
      ehParcela: serializer.fromJson<bool>(json['ehParcela']),
      statusParcela: serializer.fromJson<String?>(json['statusParcela']),
      minhaParte: serializer.fromJson<double?>(json['minhaParte']),
      divididoCom: serializer.fromJson<String?>(json['divididoCom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'value': serializer.toJson<double>(value),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'needsCategory': serializer.toJson<bool>(needsCategory),
      'syncStatus': serializer.toJson<int>(
        $TransactionsTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'parcelamentoId': serializer.toJson<String?>(parcelamentoId),
      'numeroParcela': serializer.toJson<int?>(numeroParcela),
      'valorParcela': serializer.toJson<double?>(valorParcela),
      'ehParcela': serializer.toJson<bool>(ehParcela),
      'statusParcela': serializer.toJson<String?>(statusParcela),
      'minhaParte': serializer.toJson<double?>(minhaParte),
      'divididoCom': serializer.toJson<String?>(divididoCom),
    };
  }

  TransactionsTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? name,
    String? category,
    double? value,
    DateTime? occurredAt,
    bool? needsCategory,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
    Value<String?> parcelamentoId = const Value.absent(),
    Value<int?> numeroParcela = const Value.absent(),
    Value<double?> valorParcela = const Value.absent(),
    bool? ehParcela,
    Value<String?> statusParcela = const Value.absent(),
    Value<double?> minhaParte = const Value.absent(),
    Value<String?> divididoCom = const Value.absent(),
  }) => TransactionsTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    name: name ?? this.name,
    category: category ?? this.category,
    value: value ?? this.value,
    occurredAt: occurredAt ?? this.occurredAt,
    needsCategory: needsCategory ?? this.needsCategory,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
    parcelamentoId: parcelamentoId.present
        ? parcelamentoId.value
        : this.parcelamentoId,
    numeroParcela: numeroParcela.present
        ? numeroParcela.value
        : this.numeroParcela,
    valorParcela: valorParcela.present ? valorParcela.value : this.valorParcela,
    ehParcela: ehParcela ?? this.ehParcela,
    statusParcela: statusParcela.present
        ? statusParcela.value
        : this.statusParcela,
    minhaParte: minhaParte.present ? minhaParte.value : this.minhaParte,
    divididoCom: divididoCom.present ? divididoCom.value : this.divididoCom,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      value: data.value.present ? data.value.value : this.value,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      needsCategory: data.needsCategory.present
          ? data.needsCategory.value
          : this.needsCategory,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      parcelamentoId: data.parcelamentoId.present
          ? data.parcelamentoId.value
          : this.parcelamentoId,
      numeroParcela: data.numeroParcela.present
          ? data.numeroParcela.value
          : this.numeroParcela,
      valorParcela: data.valorParcela.present
          ? data.valorParcela.value
          : this.valorParcela,
      ehParcela: data.ehParcela.present ? data.ehParcela.value : this.ehParcela,
      statusParcela: data.statusParcela.present
          ? data.statusParcela.value
          : this.statusParcela,
      minhaParte: data.minhaParte.present
          ? data.minhaParte.value
          : this.minhaParte,
      divididoCom: data.divididoCom.present
          ? data.divididoCom.value
          : this.divididoCom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('value: $value, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('needsCategory: $needsCategory, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('parcelamentoId: $parcelamentoId, ')
          ..write('numeroParcela: $numeroParcela, ')
          ..write('valorParcela: $valorParcela, ')
          ..write('ehParcela: $ehParcela, ')
          ..write('statusParcela: $statusParcela, ')
          ..write('minhaParte: $minhaParte, ')
          ..write('divididoCom: $divididoCom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    name,
    category,
    value,
    occurredAt,
    needsCategory,
    syncStatus,
    updatedAt,
    parcelamentoId,
    numeroParcela,
    valorParcela,
    ehParcela,
    statusParcela,
    minhaParte,
    divididoCom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.category == this.category &&
          other.value == this.value &&
          other.occurredAt == this.occurredAt &&
          other.needsCategory == this.needsCategory &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt &&
          other.parcelamentoId == this.parcelamentoId &&
          other.numeroParcela == this.numeroParcela &&
          other.valorParcela == this.valorParcela &&
          other.ehParcela == this.ehParcela &&
          other.statusParcela == this.statusParcela &&
          other.minhaParte == this.minhaParte &&
          other.divididoCom == this.divididoCom);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> name;
  final Value<String> category;
  final Value<double> value;
  final Value<DateTime> occurredAt;
  final Value<bool> needsCategory;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<String?> parcelamentoId;
  final Value<int?> numeroParcela;
  final Value<double?> valorParcela;
  final Value<bool> ehParcela;
  final Value<String?> statusParcela;
  final Value<double?> minhaParte;
  final Value<String?> divididoCom;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.value = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.needsCategory = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.parcelamentoId = const Value.absent(),
    this.numeroParcela = const Value.absent(),
    this.valorParcela = const Value.absent(),
    this.ehParcela = const Value.absent(),
    this.statusParcela = const Value.absent(),
    this.minhaParte = const Value.absent(),
    this.divididoCom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String name,
    required String category,
    required double value,
    required DateTime occurredAt,
    this.needsCategory = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.parcelamentoId = const Value.absent(),
    this.numeroParcela = const Value.absent(),
    this.valorParcela = const Value.absent(),
    this.ehParcela = const Value.absent(),
    this.statusParcela = const Value.absent(),
    this.minhaParte = const Value.absent(),
    this.divididoCom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       value = Value(value),
       occurredAt = Value(occurredAt);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? value,
    Expression<DateTime>? occurredAt,
    Expression<bool>? needsCategory,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<String>? parcelamentoId,
    Expression<int>? numeroParcela,
    Expression<double>? valorParcela,
    Expression<bool>? ehParcela,
    Expression<String>? statusParcela,
    Expression<double>? minhaParte,
    Expression<String>? divididoCom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (value != null) 'value': value,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (needsCategory != null) 'needs_category': needsCategory,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (parcelamentoId != null) 'parcelamento_id': parcelamentoId,
      if (numeroParcela != null) 'numero_parcela': numeroParcela,
      if (valorParcela != null) 'valor_parcela': valorParcela,
      if (ehParcela != null) 'eh_parcela': ehParcela,
      if (statusParcela != null) 'status_parcela': statusParcela,
      if (minhaParte != null) 'minha_parte': minhaParte,
      if (divididoCom != null) 'dividido_com': divididoCom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? name,
    Value<String>? category,
    Value<double>? value,
    Value<DateTime>? occurredAt,
    Value<bool>? needsCategory,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<String?>? parcelamentoId,
    Value<int?>? numeroParcela,
    Value<double?>? valorParcela,
    Value<bool>? ehParcela,
    Value<String?>? statusParcela,
    Value<double?>? minhaParte,
    Value<String?>? divididoCom,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      category: category ?? this.category,
      value: value ?? this.value,
      occurredAt: occurredAt ?? this.occurredAt,
      needsCategory: needsCategory ?? this.needsCategory,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      parcelamentoId: parcelamentoId ?? this.parcelamentoId,
      numeroParcela: numeroParcela ?? this.numeroParcela,
      valorParcela: valorParcela ?? this.valorParcela,
      ehParcela: ehParcela ?? this.ehParcela,
      statusParcela: statusParcela ?? this.statusParcela,
      minhaParte: minhaParte ?? this.minhaParte,
      divididoCom: divididoCom ?? this.divididoCom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (needsCategory.present) {
      map['needs_category'] = Variable<bool>(needsCategory.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $TransactionsTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (parcelamentoId.present) {
      map['parcelamento_id'] = Variable<String>(parcelamentoId.value);
    }
    if (numeroParcela.present) {
      map['numero_parcela'] = Variable<int>(numeroParcela.value);
    }
    if (valorParcela.present) {
      map['valor_parcela'] = Variable<double>(valorParcela.value);
    }
    if (ehParcela.present) {
      map['eh_parcela'] = Variable<bool>(ehParcela.value);
    }
    if (statusParcela.present) {
      map['status_parcela'] = Variable<String>(statusParcela.value);
    }
    if (minhaParte.present) {
      map['minha_parte'] = Variable<double>(minhaParte.value);
    }
    if (divididoCom.present) {
      map['dividido_com'] = Variable<String>(divididoCom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('value: $value, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('needsCategory: $needsCategory, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('parcelamentoId: $parcelamentoId, ')
          ..write('numeroParcela: $numeroParcela, ')
          ..write('valorParcela: $valorParcela, ')
          ..write('ehParcela: $ehParcela, ')
          ..write('statusParcela: $statusParcela, ')
          ..write('minhaParte: $minhaParte, ')
          ..write('divididoCom: $divididoCom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PerfilBancoTableTable extends PerfilBancoTable
    with TableInfo<$PerfilBancoTableTable, PerfilBancoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PerfilBancoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeBancoMeta = const VerificationMeta(
    'nomeBanco',
  );
  @override
  late final GeneratedColumn<String> nomeBanco = GeneratedColumn<String>(
    'nome_banco',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _delimitadorMeta = const VerificationMeta(
    'delimitador',
  );
  @override
  late final GeneratedColumn<String> delimitador = GeneratedColumn<String>(
    'delimitador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codificacaoLatin1Meta = const VerificationMeta(
    'codificacaoLatin1',
  );
  @override
  late final GeneratedColumn<bool> codificacaoLatin1 = GeneratedColumn<bool>(
    'codificacao_latin1',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("codificacao_latin1" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _temCabecalhoMeta = const VerificationMeta(
    'temCabecalho',
  );
  @override
  late final GeneratedColumn<bool> temCabecalho = GeneratedColumn<bool>(
    'tem_cabecalho',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tem_cabecalho" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _formatoDataMeta = const VerificationMeta(
    'formatoData',
  );
  @override
  late final GeneratedColumn<String> formatoData = GeneratedColumn<String>(
    'formato_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _separadorDecimalVirgulaMeta =
      const VerificationMeta('separadorDecimalVirgula');
  @override
  late final GeneratedColumn<bool> separadorDecimalVirgula =
      GeneratedColumn<bool>(
        'separador_decimal_virgula',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("separador_decimal_virgula" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _mapeamentoColunasJsonMeta =
      const VerificationMeta('mapeamentoColunasJson');
  @override
  late final GeneratedColumn<String> mapeamentoColunasJson =
      GeneratedColumn<String>(
        'mapeamento_colunas_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _assinaturaCabecalhoJsonMeta =
      const VerificationMeta('assinaturaCabecalhoJson');
  @override
  late final GeneratedColumn<String> assinaturaCabecalhoJson =
      GeneratedColumn<String>(
        'assinatura_cabecalho_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($PerfilBancoTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    nomeBanco,
    delimitador,
    codificacaoLatin1,
    temCabecalho,
    formatoData,
    separadorDecimalVirgula,
    mapeamentoColunasJson,
    assinaturaCabecalhoJson,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'perfil_banco_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PerfilBancoTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('nome_banco')) {
      context.handle(
        _nomeBancoMeta,
        nomeBanco.isAcceptableOrUnknown(data['nome_banco']!, _nomeBancoMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeBancoMeta);
    }
    if (data.containsKey('delimitador')) {
      context.handle(
        _delimitadorMeta,
        delimitador.isAcceptableOrUnknown(
          data['delimitador']!,
          _delimitadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_delimitadorMeta);
    }
    if (data.containsKey('codificacao_latin1')) {
      context.handle(
        _codificacaoLatin1Meta,
        codificacaoLatin1.isAcceptableOrUnknown(
          data['codificacao_latin1']!,
          _codificacaoLatin1Meta,
        ),
      );
    }
    if (data.containsKey('tem_cabecalho')) {
      context.handle(
        _temCabecalhoMeta,
        temCabecalho.isAcceptableOrUnknown(
          data['tem_cabecalho']!,
          _temCabecalhoMeta,
        ),
      );
    }
    if (data.containsKey('formato_data')) {
      context.handle(
        _formatoDataMeta,
        formatoData.isAcceptableOrUnknown(
          data['formato_data']!,
          _formatoDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatoDataMeta);
    }
    if (data.containsKey('separador_decimal_virgula')) {
      context.handle(
        _separadorDecimalVirgulaMeta,
        separadorDecimalVirgula.isAcceptableOrUnknown(
          data['separador_decimal_virgula']!,
          _separadorDecimalVirgulaMeta,
        ),
      );
    }
    if (data.containsKey('mapeamento_colunas_json')) {
      context.handle(
        _mapeamentoColunasJsonMeta,
        mapeamentoColunasJson.isAcceptableOrUnknown(
          data['mapeamento_colunas_json']!,
          _mapeamentoColunasJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mapeamentoColunasJsonMeta);
    }
    if (data.containsKey('assinatura_cabecalho_json')) {
      context.handle(
        _assinaturaCabecalhoJsonMeta,
        assinaturaCabecalhoJson.isAcceptableOrUnknown(
          data['assinatura_cabecalho_json']!,
          _assinaturaCabecalhoJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assinaturaCabecalhoJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PerfilBancoTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PerfilBancoTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      nomeBanco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_banco'],
      )!,
      delimitador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delimitador'],
      )!,
      codificacaoLatin1: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}codificacao_latin1'],
      )!,
      temCabecalho: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tem_cabecalho'],
      )!,
      formatoData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formato_data'],
      )!,
      separadorDecimalVirgula: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}separador_decimal_virgula'],
      )!,
      mapeamentoColunasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mapeamento_colunas_json'],
      )!,
      assinaturaCabecalhoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assinatura_cabecalho_json'],
      )!,
      syncStatus: $PerfilBancoTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PerfilBancoTableTable createAlias(String alias) {
    return $PerfilBancoTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class PerfilBancoTableData extends DataClass
    implements Insertable<PerfilBancoTableData> {
  final String id;
  final String? remoteId;
  final String nomeBanco;
  final String delimitador;
  final bool codificacaoLatin1;
  final bool temCabecalho;
  final String formatoData;
  final bool separadorDecimalVirgula;
  final String mapeamentoColunasJson;
  final String assinaturaCabecalhoJson;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const PerfilBancoTableData({
    required this.id,
    this.remoteId,
    required this.nomeBanco,
    required this.delimitador,
    required this.codificacaoLatin1,
    required this.temCabecalho,
    required this.formatoData,
    required this.separadorDecimalVirgula,
    required this.mapeamentoColunasJson,
    required this.assinaturaCabecalhoJson,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['nome_banco'] = Variable<String>(nomeBanco);
    map['delimitador'] = Variable<String>(delimitador);
    map['codificacao_latin1'] = Variable<bool>(codificacaoLatin1);
    map['tem_cabecalho'] = Variable<bool>(temCabecalho);
    map['formato_data'] = Variable<String>(formatoData);
    map['separador_decimal_virgula'] = Variable<bool>(separadorDecimalVirgula);
    map['mapeamento_colunas_json'] = Variable<String>(mapeamentoColunasJson);
    map['assinatura_cabecalho_json'] = Variable<String>(
      assinaturaCabecalhoJson,
    );
    {
      map['sync_status'] = Variable<int>(
        $PerfilBancoTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PerfilBancoTableCompanion toCompanion(bool nullToAbsent) {
    return PerfilBancoTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      nomeBanco: Value(nomeBanco),
      delimitador: Value(delimitador),
      codificacaoLatin1: Value(codificacaoLatin1),
      temCabecalho: Value(temCabecalho),
      formatoData: Value(formatoData),
      separadorDecimalVirgula: Value(separadorDecimalVirgula),
      mapeamentoColunasJson: Value(mapeamentoColunasJson),
      assinaturaCabecalhoJson: Value(assinaturaCabecalhoJson),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory PerfilBancoTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PerfilBancoTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      nomeBanco: serializer.fromJson<String>(json['nomeBanco']),
      delimitador: serializer.fromJson<String>(json['delimitador']),
      codificacaoLatin1: serializer.fromJson<bool>(json['codificacaoLatin1']),
      temCabecalho: serializer.fromJson<bool>(json['temCabecalho']),
      formatoData: serializer.fromJson<String>(json['formatoData']),
      separadorDecimalVirgula: serializer.fromJson<bool>(
        json['separadorDecimalVirgula'],
      ),
      mapeamentoColunasJson: serializer.fromJson<String>(
        json['mapeamentoColunasJson'],
      ),
      assinaturaCabecalhoJson: serializer.fromJson<String>(
        json['assinaturaCabecalhoJson'],
      ),
      syncStatus: $PerfilBancoTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'nomeBanco': serializer.toJson<String>(nomeBanco),
      'delimitador': serializer.toJson<String>(delimitador),
      'codificacaoLatin1': serializer.toJson<bool>(codificacaoLatin1),
      'temCabecalho': serializer.toJson<bool>(temCabecalho),
      'formatoData': serializer.toJson<String>(formatoData),
      'separadorDecimalVirgula': serializer.toJson<bool>(
        separadorDecimalVirgula,
      ),
      'mapeamentoColunasJson': serializer.toJson<String>(mapeamentoColunasJson),
      'assinaturaCabecalhoJson': serializer.toJson<String>(
        assinaturaCabecalhoJson,
      ),
      'syncStatus': serializer.toJson<int>(
        $PerfilBancoTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PerfilBancoTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? nomeBanco,
    String? delimitador,
    bool? codificacaoLatin1,
    bool? temCabecalho,
    String? formatoData,
    bool? separadorDecimalVirgula,
    String? mapeamentoColunasJson,
    String? assinaturaCabecalhoJson,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => PerfilBancoTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    nomeBanco: nomeBanco ?? this.nomeBanco,
    delimitador: delimitador ?? this.delimitador,
    codificacaoLatin1: codificacaoLatin1 ?? this.codificacaoLatin1,
    temCabecalho: temCabecalho ?? this.temCabecalho,
    formatoData: formatoData ?? this.formatoData,
    separadorDecimalVirgula:
        separadorDecimalVirgula ?? this.separadorDecimalVirgula,
    mapeamentoColunasJson: mapeamentoColunasJson ?? this.mapeamentoColunasJson,
    assinaturaCabecalhoJson:
        assinaturaCabecalhoJson ?? this.assinaturaCabecalhoJson,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PerfilBancoTableData copyWithCompanion(PerfilBancoTableCompanion data) {
    return PerfilBancoTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      nomeBanco: data.nomeBanco.present ? data.nomeBanco.value : this.nomeBanco,
      delimitador: data.delimitador.present
          ? data.delimitador.value
          : this.delimitador,
      codificacaoLatin1: data.codificacaoLatin1.present
          ? data.codificacaoLatin1.value
          : this.codificacaoLatin1,
      temCabecalho: data.temCabecalho.present
          ? data.temCabecalho.value
          : this.temCabecalho,
      formatoData: data.formatoData.present
          ? data.formatoData.value
          : this.formatoData,
      separadorDecimalVirgula: data.separadorDecimalVirgula.present
          ? data.separadorDecimalVirgula.value
          : this.separadorDecimalVirgula,
      mapeamentoColunasJson: data.mapeamentoColunasJson.present
          ? data.mapeamentoColunasJson.value
          : this.mapeamentoColunasJson,
      assinaturaCabecalhoJson: data.assinaturaCabecalhoJson.present
          ? data.assinaturaCabecalhoJson.value
          : this.assinaturaCabecalhoJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PerfilBancoTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('nomeBanco: $nomeBanco, ')
          ..write('delimitador: $delimitador, ')
          ..write('codificacaoLatin1: $codificacaoLatin1, ')
          ..write('temCabecalho: $temCabecalho, ')
          ..write('formatoData: $formatoData, ')
          ..write('separadorDecimalVirgula: $separadorDecimalVirgula, ')
          ..write('mapeamentoColunasJson: $mapeamentoColunasJson, ')
          ..write('assinaturaCabecalhoJson: $assinaturaCabecalhoJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    nomeBanco,
    delimitador,
    codificacaoLatin1,
    temCabecalho,
    formatoData,
    separadorDecimalVirgula,
    mapeamentoColunasJson,
    assinaturaCabecalhoJson,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PerfilBancoTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.nomeBanco == this.nomeBanco &&
          other.delimitador == this.delimitador &&
          other.codificacaoLatin1 == this.codificacaoLatin1 &&
          other.temCabecalho == this.temCabecalho &&
          other.formatoData == this.formatoData &&
          other.separadorDecimalVirgula == this.separadorDecimalVirgula &&
          other.mapeamentoColunasJson == this.mapeamentoColunasJson &&
          other.assinaturaCabecalhoJson == this.assinaturaCabecalhoJson &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class PerfilBancoTableCompanion extends UpdateCompanion<PerfilBancoTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> nomeBanco;
  final Value<String> delimitador;
  final Value<bool> codificacaoLatin1;
  final Value<bool> temCabecalho;
  final Value<String> formatoData;
  final Value<bool> separadorDecimalVirgula;
  final Value<String> mapeamentoColunasJson;
  final Value<String> assinaturaCabecalhoJson;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PerfilBancoTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.nomeBanco = const Value.absent(),
    this.delimitador = const Value.absent(),
    this.codificacaoLatin1 = const Value.absent(),
    this.temCabecalho = const Value.absent(),
    this.formatoData = const Value.absent(),
    this.separadorDecimalVirgula = const Value.absent(),
    this.mapeamentoColunasJson = const Value.absent(),
    this.assinaturaCabecalhoJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PerfilBancoTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String nomeBanco,
    required String delimitador,
    this.codificacaoLatin1 = const Value.absent(),
    this.temCabecalho = const Value.absent(),
    required String formatoData,
    this.separadorDecimalVirgula = const Value.absent(),
    required String mapeamentoColunasJson,
    required String assinaturaCabecalhoJson,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nomeBanco = Value(nomeBanco),
       delimitador = Value(delimitador),
       formatoData = Value(formatoData),
       mapeamentoColunasJson = Value(mapeamentoColunasJson),
       assinaturaCabecalhoJson = Value(assinaturaCabecalhoJson);
  static Insertable<PerfilBancoTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? nomeBanco,
    Expression<String>? delimitador,
    Expression<bool>? codificacaoLatin1,
    Expression<bool>? temCabecalho,
    Expression<String>? formatoData,
    Expression<bool>? separadorDecimalVirgula,
    Expression<String>? mapeamentoColunasJson,
    Expression<String>? assinaturaCabecalhoJson,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (nomeBanco != null) 'nome_banco': nomeBanco,
      if (delimitador != null) 'delimitador': delimitador,
      if (codificacaoLatin1 != null) 'codificacao_latin1': codificacaoLatin1,
      if (temCabecalho != null) 'tem_cabecalho': temCabecalho,
      if (formatoData != null) 'formato_data': formatoData,
      if (separadorDecimalVirgula != null)
        'separador_decimal_virgula': separadorDecimalVirgula,
      if (mapeamentoColunasJson != null)
        'mapeamento_colunas_json': mapeamentoColunasJson,
      if (assinaturaCabecalhoJson != null)
        'assinatura_cabecalho_json': assinaturaCabecalhoJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PerfilBancoTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? nomeBanco,
    Value<String>? delimitador,
    Value<bool>? codificacaoLatin1,
    Value<bool>? temCabecalho,
    Value<String>? formatoData,
    Value<bool>? separadorDecimalVirgula,
    Value<String>? mapeamentoColunasJson,
    Value<String>? assinaturaCabecalhoJson,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PerfilBancoTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      nomeBanco: nomeBanco ?? this.nomeBanco,
      delimitador: delimitador ?? this.delimitador,
      codificacaoLatin1: codificacaoLatin1 ?? this.codificacaoLatin1,
      temCabecalho: temCabecalho ?? this.temCabecalho,
      formatoData: formatoData ?? this.formatoData,
      separadorDecimalVirgula:
          separadorDecimalVirgula ?? this.separadorDecimalVirgula,
      mapeamentoColunasJson:
          mapeamentoColunasJson ?? this.mapeamentoColunasJson,
      assinaturaCabecalhoJson:
          assinaturaCabecalhoJson ?? this.assinaturaCabecalhoJson,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (nomeBanco.present) {
      map['nome_banco'] = Variable<String>(nomeBanco.value);
    }
    if (delimitador.present) {
      map['delimitador'] = Variable<String>(delimitador.value);
    }
    if (codificacaoLatin1.present) {
      map['codificacao_latin1'] = Variable<bool>(codificacaoLatin1.value);
    }
    if (temCabecalho.present) {
      map['tem_cabecalho'] = Variable<bool>(temCabecalho.value);
    }
    if (formatoData.present) {
      map['formato_data'] = Variable<String>(formatoData.value);
    }
    if (separadorDecimalVirgula.present) {
      map['separador_decimal_virgula'] = Variable<bool>(
        separadorDecimalVirgula.value,
      );
    }
    if (mapeamentoColunasJson.present) {
      map['mapeamento_colunas_json'] = Variable<String>(
        mapeamentoColunasJson.value,
      );
    }
    if (assinaturaCabecalhoJson.present) {
      map['assinatura_cabecalho_json'] = Variable<String>(
        assinaturaCabecalhoJson.value,
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $PerfilBancoTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('PerfilBancoTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('nomeBanco: $nomeBanco, ')
          ..write('delimitador: $delimitador, ')
          ..write('codificacaoLatin1: $codificacaoLatin1, ')
          ..write('temCabecalho: $temCabecalho, ')
          ..write('formatoData: $formatoData, ')
          ..write('separadorDecimalVirgula: $separadorDecimalVirgula, ')
          ..write('mapeamentoColunasJson: $mapeamentoColunasJson, ')
          ..write('assinaturaCabecalhoJson: $assinaturaCabecalhoJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RendaTableTable extends RendaTable
    with TableInfo<$RendaTableTable, RendaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RendaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recorrenciaMeta = const VerificationMeta(
    'recorrencia',
  );
  @override
  late final GeneratedColumn<String> recorrencia = GeneratedColumn<String>(
    'recorrencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataRecebimentoMeta = const VerificationMeta(
    'dataRecebimento',
  );
  @override
  late final GeneratedColumn<DateTime> dataRecebimento =
      GeneratedColumn<DateTime>(
        'data_recebimento',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($RendaTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    descricao,
    valor,
    tipo,
    recorrencia,
    dataRecebimento,
    ativa,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'renda_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RendaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('recorrencia')) {
      context.handle(
        _recorrenciaMeta,
        recorrencia.isAcceptableOrUnknown(
          data['recorrencia']!,
          _recorrenciaMeta,
        ),
      );
    }
    if (data.containsKey('data_recebimento')) {
      context.handle(
        _dataRecebimentoMeta,
        dataRecebimento.isAcceptableOrUnknown(
          data['data_recebimento']!,
          _dataRecebimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataRecebimentoMeta);
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RendaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RendaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      recorrencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorrencia'],
      ),
      dataRecebimento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_recebimento'],
      )!,
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
      syncStatus: $RendaTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RendaTableTable createAlias(String alias) {
    return $RendaTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class RendaTableData extends DataClass implements Insertable<RendaTableData> {
  final String id;
  final String? remoteId;
  final String descricao;
  final double valor;

  /// 'fixa' ou 'variavel'.
  final String tipo;

  /// 'semanal', 'mensal', 'anual' ou nulo (renda variável).
  final String? recorrencia;
  final DateTime dataRecebimento;
  final bool ativa;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const RendaTableData({
    required this.id,
    this.remoteId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    this.recorrencia,
    required this.dataRecebimento,
    required this.ativa,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['descricao'] = Variable<String>(descricao);
    map['valor'] = Variable<double>(valor);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || recorrencia != null) {
      map['recorrencia'] = Variable<String>(recorrencia);
    }
    map['data_recebimento'] = Variable<DateTime>(dataRecebimento);
    map['ativa'] = Variable<bool>(ativa);
    {
      map['sync_status'] = Variable<int>(
        $RendaTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RendaTableCompanion toCompanion(bool nullToAbsent) {
    return RendaTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      descricao: Value(descricao),
      valor: Value(valor),
      tipo: Value(tipo),
      recorrencia: recorrencia == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrencia),
      dataRecebimento: Value(dataRecebimento),
      ativa: Value(ativa),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory RendaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RendaTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valor: serializer.fromJson<double>(json['valor']),
      tipo: serializer.fromJson<String>(json['tipo']),
      recorrencia: serializer.fromJson<String?>(json['recorrencia']),
      dataRecebimento: serializer.fromJson<DateTime>(json['dataRecebimento']),
      ativa: serializer.fromJson<bool>(json['ativa']),
      syncStatus: $RendaTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'descricao': serializer.toJson<String>(descricao),
      'valor': serializer.toJson<double>(valor),
      'tipo': serializer.toJson<String>(tipo),
      'recorrencia': serializer.toJson<String?>(recorrencia),
      'dataRecebimento': serializer.toJson<DateTime>(dataRecebimento),
      'ativa': serializer.toJson<bool>(ativa),
      'syncStatus': serializer.toJson<int>(
        $RendaTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RendaTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? descricao,
    double? valor,
    String? tipo,
    Value<String?> recorrencia = const Value.absent(),
    DateTime? dataRecebimento,
    bool? ativa,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => RendaTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    descricao: descricao ?? this.descricao,
    valor: valor ?? this.valor,
    tipo: tipo ?? this.tipo,
    recorrencia: recorrencia.present ? recorrencia.value : this.recorrencia,
    dataRecebimento: dataRecebimento ?? this.dataRecebimento,
    ativa: ativa ?? this.ativa,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RendaTableData copyWithCompanion(RendaTableCompanion data) {
    return RendaTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valor: data.valor.present ? data.valor.value : this.valor,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      recorrencia: data.recorrencia.present
          ? data.recorrencia.value
          : this.recorrencia,
      dataRecebimento: data.dataRecebimento.present
          ? data.dataRecebimento.value
          : this.dataRecebimento,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RendaTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('tipo: $tipo, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('dataRecebimento: $dataRecebimento, ')
          ..write('ativa: $ativa, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    descricao,
    valor,
    tipo,
    recorrencia,
    dataRecebimento,
    ativa,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RendaTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.descricao == this.descricao &&
          other.valor == this.valor &&
          other.tipo == this.tipo &&
          other.recorrencia == this.recorrencia &&
          other.dataRecebimento == this.dataRecebimento &&
          other.ativa == this.ativa &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class RendaTableCompanion extends UpdateCompanion<RendaTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> descricao;
  final Value<double> valor;
  final Value<String> tipo;
  final Value<String?> recorrencia;
  final Value<DateTime> dataRecebimento;
  final Value<bool> ativa;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RendaTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valor = const Value.absent(),
    this.tipo = const Value.absent(),
    this.recorrencia = const Value.absent(),
    this.dataRecebimento = const Value.absent(),
    this.ativa = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RendaTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String descricao,
    required double valor,
    required String tipo,
    this.recorrencia = const Value.absent(),
    required DateTime dataRecebimento,
    this.ativa = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       descricao = Value(descricao),
       valor = Value(valor),
       tipo = Value(tipo),
       dataRecebimento = Value(dataRecebimento);
  static Insertable<RendaTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? descricao,
    Expression<double>? valor,
    Expression<String>? tipo,
    Expression<String>? recorrencia,
    Expression<DateTime>? dataRecebimento,
    Expression<bool>? ativa,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (descricao != null) 'descricao': descricao,
      if (valor != null) 'valor': valor,
      if (tipo != null) 'tipo': tipo,
      if (recorrencia != null) 'recorrencia': recorrencia,
      if (dataRecebimento != null) 'data_recebimento': dataRecebimento,
      if (ativa != null) 'ativa': ativa,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RendaTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? descricao,
    Value<double>? valor,
    Value<String>? tipo,
    Value<String?>? recorrencia,
    Value<DateTime>? dataRecebimento,
    Value<bool>? ativa,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RendaTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      recorrencia: recorrencia ?? this.recorrencia,
      dataRecebimento: dataRecebimento ?? this.dataRecebimento,
      ativa: ativa ?? this.ativa,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (recorrencia.present) {
      map['recorrencia'] = Variable<String>(recorrencia.value);
    }
    if (dataRecebimento.present) {
      map['data_recebimento'] = Variable<DateTime>(dataRecebimento.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $RendaTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('RendaTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('tipo: $tipo, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('dataRecebimento: $dataRecebimento, ')
          ..write('ativa: $ativa, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTableTable extends MetaTable
    with TableInfo<$MetaTableTable, MetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAtualMeta = const VerificationMeta(
    'valorAtual',
  );
  @override
  late final GeneratedColumn<double> valorAtual = GeneratedColumn<double>(
    'valor_atual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorAlvoMeta = const VerificationMeta(
    'valorAlvo',
  );
  @override
  late final GeneratedColumn<double> valorAlvo = GeneratedColumn<double>(
    'valor_alvo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prazoMeta = const VerificationMeta('prazo');
  @override
  late final GeneratedColumn<DateTime> prazo = GeneratedColumn<DateTime>(
    'prazo',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($MetaTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    nome,
    valorAtual,
    valorAlvo,
    prazo,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('valor_atual')) {
      context.handle(
        _valorAtualMeta,
        valorAtual.isAcceptableOrUnknown(data['valor_atual']!, _valorAtualMeta),
      );
    }
    if (data.containsKey('valor_alvo')) {
      context.handle(
        _valorAlvoMeta,
        valorAlvo.isAcceptableOrUnknown(data['valor_alvo']!, _valorAlvoMeta),
      );
    } else if (isInserting) {
      context.missing(_valorAlvoMeta);
    }
    if (data.containsKey('prazo')) {
      context.handle(
        _prazoMeta,
        prazo.isAcceptableOrUnknown(data['prazo']!, _prazoMeta),
      );
    } else if (isInserting) {
      context.missing(_prazoMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      valorAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_atual'],
      )!,
      valorAlvo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_alvo'],
      )!,
      prazo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prazo'],
      )!,
      syncStatus: $MetaTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MetaTableTable createAlias(String alias) {
    return $MetaTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class MetaTableData extends DataClass implements Insertable<MetaTableData> {
  final String id;
  final String? remoteId;
  final String nome;
  final double valorAtual;
  final double valorAlvo;
  final DateTime prazo;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const MetaTableData({
    required this.id,
    this.remoteId,
    required this.nome,
    required this.valorAtual,
    required this.valorAlvo,
    required this.prazo,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['nome'] = Variable<String>(nome);
    map['valor_atual'] = Variable<double>(valorAtual);
    map['valor_alvo'] = Variable<double>(valorAlvo);
    map['prazo'] = Variable<DateTime>(prazo);
    {
      map['sync_status'] = Variable<int>(
        $MetaTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MetaTableCompanion toCompanion(bool nullToAbsent) {
    return MetaTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      nome: Value(nome),
      valorAtual: Value(valorAtual),
      valorAlvo: Value(valorAlvo),
      prazo: Value(prazo),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory MetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      nome: serializer.fromJson<String>(json['nome']),
      valorAtual: serializer.fromJson<double>(json['valorAtual']),
      valorAlvo: serializer.fromJson<double>(json['valorAlvo']),
      prazo: serializer.fromJson<DateTime>(json['prazo']),
      syncStatus: $MetaTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'nome': serializer.toJson<String>(nome),
      'valorAtual': serializer.toJson<double>(valorAtual),
      'valorAlvo': serializer.toJson<double>(valorAlvo),
      'prazo': serializer.toJson<DateTime>(prazo),
      'syncStatus': serializer.toJson<int>(
        $MetaTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MetaTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? nome,
    double? valorAtual,
    double? valorAlvo,
    DateTime? prazo,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => MetaTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    nome: nome ?? this.nome,
    valorAtual: valorAtual ?? this.valorAtual,
    valorAlvo: valorAlvo ?? this.valorAlvo,
    prazo: prazo ?? this.prazo,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MetaTableData copyWithCompanion(MetaTableCompanion data) {
    return MetaTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      nome: data.nome.present ? data.nome.value : this.nome,
      valorAtual: data.valorAtual.present
          ? data.valorAtual.value
          : this.valorAtual,
      valorAlvo: data.valorAlvo.present ? data.valorAlvo.value : this.valorAlvo,
      prazo: data.prazo.present ? data.prazo.value : this.prazo,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('nome: $nome, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('prazo: $prazo, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    nome,
    valorAtual,
    valorAlvo,
    prazo,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.nome == this.nome &&
          other.valorAtual == this.valorAtual &&
          other.valorAlvo == this.valorAlvo &&
          other.prazo == this.prazo &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class MetaTableCompanion extends UpdateCompanion<MetaTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> nome;
  final Value<double> valorAtual;
  final Value<double> valorAlvo;
  final Value<DateTime> prazo;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MetaTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.nome = const Value.absent(),
    this.valorAtual = const Value.absent(),
    this.valorAlvo = const Value.absent(),
    this.prazo = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String nome,
    this.valorAtual = const Value.absent(),
    required double valorAlvo,
    required DateTime prazo,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       valorAlvo = Value(valorAlvo),
       prazo = Value(prazo);
  static Insertable<MetaTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? nome,
    Expression<double>? valorAtual,
    Expression<double>? valorAlvo,
    Expression<DateTime>? prazo,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (nome != null) 'nome': nome,
      if (valorAtual != null) 'valor_atual': valorAtual,
      if (valorAlvo != null) 'valor_alvo': valorAlvo,
      if (prazo != null) 'prazo': prazo,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? nome,
    Value<double>? valorAtual,
    Value<double>? valorAlvo,
    Value<DateTime>? prazo,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MetaTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      nome: nome ?? this.nome,
      valorAtual: valorAtual ?? this.valorAtual,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      prazo: prazo ?? this.prazo,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (valorAtual.present) {
      map['valor_atual'] = Variable<double>(valorAtual.value);
    }
    if (valorAlvo.present) {
      map['valor_alvo'] = Variable<double>(valorAlvo.value);
    }
    if (prazo.present) {
      map['prazo'] = Variable<DateTime>(prazo.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $MetaTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('MetaTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('nome: $nome, ')
          ..write('valorAtual: $valorAtual, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('prazo: $prazo, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParcelamentoTableTable extends ParcelamentoTable
    with TableInfo<$ParcelamentoTableTable, ParcelamentoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParcelamentoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transacaoOriginalIdMeta =
      const VerificationMeta('transacaoOriginalId');
  @override
  late final GeneratedColumn<String> transacaoOriginalId =
      GeneratedColumn<String>(
        'transacao_original_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalOriginalMeta = const VerificationMeta(
    'totalOriginal',
  );
  @override
  late final GeneratedColumn<double> totalOriginal = GeneratedColumn<double>(
    'total_original',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroParcelasMeta = const VerificationMeta(
    'numeroParcelas',
  );
  @override
  late final GeneratedColumn<int> numeroParcelas = GeneratedColumn<int>(
    'numero_parcelas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataPrimeiraParcMeta = const VerificationMeta(
    'dataPrimeiraParc',
  );
  @override
  late final GeneratedColumn<DateTime> dataPrimeiraParc =
      GeneratedColumn<DateTime>(
        'data_primeira_parc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($ParcelamentoTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    transacaoOriginalId,
    totalOriginal,
    numeroParcelas,
    dataPrimeiraParc,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parcelamento_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParcelamentoTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('transacao_original_id')) {
      context.handle(
        _transacaoOriginalIdMeta,
        transacaoOriginalId.isAcceptableOrUnknown(
          data['transacao_original_id']!,
          _transacaoOriginalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transacaoOriginalIdMeta);
    }
    if (data.containsKey('total_original')) {
      context.handle(
        _totalOriginalMeta,
        totalOriginal.isAcceptableOrUnknown(
          data['total_original']!,
          _totalOriginalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalOriginalMeta);
    }
    if (data.containsKey('numero_parcelas')) {
      context.handle(
        _numeroParcelasMeta,
        numeroParcelas.isAcceptableOrUnknown(
          data['numero_parcelas']!,
          _numeroParcelasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numeroParcelasMeta);
    }
    if (data.containsKey('data_primeira_parc')) {
      context.handle(
        _dataPrimeiraParcMeta,
        dataPrimeiraParc.isAcceptableOrUnknown(
          data['data_primeira_parc']!,
          _dataPrimeiraParcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataPrimeiraParcMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParcelamentoTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParcelamentoTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      transacaoOriginalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transacao_original_id'],
      )!,
      totalOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_original'],
      )!,
      numeroParcelas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_parcelas'],
      )!,
      dataPrimeiraParc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_primeira_parc'],
      )!,
      syncStatus: $ParcelamentoTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ParcelamentoTableTable createAlias(String alias) {
    return $ParcelamentoTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ParcelamentoTableData extends DataClass
    implements Insertable<ParcelamentoTableData> {
  final String id;
  final String? remoteId;
  final String transacaoOriginalId;
  final double totalOriginal;
  final int numeroParcelas;
  final DateTime dataPrimeiraParc;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const ParcelamentoTableData({
    required this.id,
    this.remoteId,
    required this.transacaoOriginalId,
    required this.totalOriginal,
    required this.numeroParcelas,
    required this.dataPrimeiraParc,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['transacao_original_id'] = Variable<String>(transacaoOriginalId);
    map['total_original'] = Variable<double>(totalOriginal);
    map['numero_parcelas'] = Variable<int>(numeroParcelas);
    map['data_primeira_parc'] = Variable<DateTime>(dataPrimeiraParc);
    {
      map['sync_status'] = Variable<int>(
        $ParcelamentoTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ParcelamentoTableCompanion toCompanion(bool nullToAbsent) {
    return ParcelamentoTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      transacaoOriginalId: Value(transacaoOriginalId),
      totalOriginal: Value(totalOriginal),
      numeroParcelas: Value(numeroParcelas),
      dataPrimeiraParc: Value(dataPrimeiraParc),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory ParcelamentoTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParcelamentoTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      transacaoOriginalId: serializer.fromJson<String>(
        json['transacaoOriginalId'],
      ),
      totalOriginal: serializer.fromJson<double>(json['totalOriginal']),
      numeroParcelas: serializer.fromJson<int>(json['numeroParcelas']),
      dataPrimeiraParc: serializer.fromJson<DateTime>(json['dataPrimeiraParc']),
      syncStatus: $ParcelamentoTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'transacaoOriginalId': serializer.toJson<String>(transacaoOriginalId),
      'totalOriginal': serializer.toJson<double>(totalOriginal),
      'numeroParcelas': serializer.toJson<int>(numeroParcelas),
      'dataPrimeiraParc': serializer.toJson<DateTime>(dataPrimeiraParc),
      'syncStatus': serializer.toJson<int>(
        $ParcelamentoTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ParcelamentoTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? transacaoOriginalId,
    double? totalOriginal,
    int? numeroParcelas,
    DateTime? dataPrimeiraParc,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => ParcelamentoTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    transacaoOriginalId: transacaoOriginalId ?? this.transacaoOriginalId,
    totalOriginal: totalOriginal ?? this.totalOriginal,
    numeroParcelas: numeroParcelas ?? this.numeroParcelas,
    dataPrimeiraParc: dataPrimeiraParc ?? this.dataPrimeiraParc,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ParcelamentoTableData copyWithCompanion(ParcelamentoTableCompanion data) {
    return ParcelamentoTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      transacaoOriginalId: data.transacaoOriginalId.present
          ? data.transacaoOriginalId.value
          : this.transacaoOriginalId,
      totalOriginal: data.totalOriginal.present
          ? data.totalOriginal.value
          : this.totalOriginal,
      numeroParcelas: data.numeroParcelas.present
          ? data.numeroParcelas.value
          : this.numeroParcelas,
      dataPrimeiraParc: data.dataPrimeiraParc.present
          ? data.dataPrimeiraParc.value
          : this.dataPrimeiraParc,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParcelamentoTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('transacaoOriginalId: $transacaoOriginalId, ')
          ..write('totalOriginal: $totalOriginal, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('dataPrimeiraParc: $dataPrimeiraParc, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    transacaoOriginalId,
    totalOriginal,
    numeroParcelas,
    dataPrimeiraParc,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParcelamentoTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.transacaoOriginalId == this.transacaoOriginalId &&
          other.totalOriginal == this.totalOriginal &&
          other.numeroParcelas == this.numeroParcelas &&
          other.dataPrimeiraParc == this.dataPrimeiraParc &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class ParcelamentoTableCompanion
    extends UpdateCompanion<ParcelamentoTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> transacaoOriginalId;
  final Value<double> totalOriginal;
  final Value<int> numeroParcelas;
  final Value<DateTime> dataPrimeiraParc;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ParcelamentoTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.transacaoOriginalId = const Value.absent(),
    this.totalOriginal = const Value.absent(),
    this.numeroParcelas = const Value.absent(),
    this.dataPrimeiraParc = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParcelamentoTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String transacaoOriginalId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeiraParc,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transacaoOriginalId = Value(transacaoOriginalId),
       totalOriginal = Value(totalOriginal),
       numeroParcelas = Value(numeroParcelas),
       dataPrimeiraParc = Value(dataPrimeiraParc);
  static Insertable<ParcelamentoTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? transacaoOriginalId,
    Expression<double>? totalOriginal,
    Expression<int>? numeroParcelas,
    Expression<DateTime>? dataPrimeiraParc,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (transacaoOriginalId != null)
        'transacao_original_id': transacaoOriginalId,
      if (totalOriginal != null) 'total_original': totalOriginal,
      if (numeroParcelas != null) 'numero_parcelas': numeroParcelas,
      if (dataPrimeiraParc != null) 'data_primeira_parc': dataPrimeiraParc,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParcelamentoTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? transacaoOriginalId,
    Value<double>? totalOriginal,
    Value<int>? numeroParcelas,
    Value<DateTime>? dataPrimeiraParc,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ParcelamentoTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      transacaoOriginalId: transacaoOriginalId ?? this.transacaoOriginalId,
      totalOriginal: totalOriginal ?? this.totalOriginal,
      numeroParcelas: numeroParcelas ?? this.numeroParcelas,
      dataPrimeiraParc: dataPrimeiraParc ?? this.dataPrimeiraParc,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (transacaoOriginalId.present) {
      map['transacao_original_id'] = Variable<String>(
        transacaoOriginalId.value,
      );
    }
    if (totalOriginal.present) {
      map['total_original'] = Variable<double>(totalOriginal.value);
    }
    if (numeroParcelas.present) {
      map['numero_parcelas'] = Variable<int>(numeroParcelas.value);
    }
    if (dataPrimeiraParc.present) {
      map['data_primeira_parc'] = Variable<DateTime>(dataPrimeiraParc.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ParcelamentoTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('ParcelamentoTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('transacaoOriginalId: $transacaoOriginalId, ')
          ..write('totalOriginal: $totalOriginal, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('dataPrimeiraParc: $dataPrimeiraParc, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExtratoLinhasTableTable extends ExtratoLinhasTable
    with TableInfo<$ExtratoLinhasTableTable, ExtratoLinhasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtratoLinhasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<String> importId = GeneratedColumn<String>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeBancoOriginalMeta = const VerificationMeta(
    'nomeBancoOriginal',
  );
  @override
  late final GeneratedColumn<String> nomeBancoOriginal =
      GeneratedColumn<String>(
        'nome_banco_original',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _importadoEmMeta = const VerificationMeta(
    'importadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> importadoEm = GeneratedColumn<DateTime>(
    'importado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importId,
    descricao,
    valor,
    data,
    tipo,
    nomeBancoOriginal,
    importadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extrato_linhas_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtratoLinhasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nome_banco_original')) {
      context.handle(
        _nomeBancoOriginalMeta,
        nomeBancoOriginal.isAcceptableOrUnknown(
          data['nome_banco_original']!,
          _nomeBancoOriginalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nomeBancoOriginalMeta);
    }
    if (data.containsKey('importado_em')) {
      context.handle(
        _importadoEmMeta,
        importadoEm.isAcceptableOrUnknown(
          data['importado_em']!,
          _importadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtratoLinhasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtratoLinhasTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nomeBancoOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_banco_original'],
      )!,
      importadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}importado_em'],
      )!,
    );
  }

  @override
  $ExtratoLinhasTableTable createAlias(String alias) {
    return $ExtratoLinhasTableTable(attachedDatabase, alias);
  }
}

class ExtratoLinhasTableData extends DataClass
    implements Insertable<ExtratoLinhasTableData> {
  final String id;
  final String importId;
  final String descricao;
  final double valor;
  final DateTime data;
  final String tipo;
  final String nomeBancoOriginal;
  final DateTime importadoEm;
  const ExtratoLinhasTableData({
    required this.id,
    required this.importId,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.nomeBancoOriginal,
    required this.importadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['import_id'] = Variable<String>(importId);
    map['descricao'] = Variable<String>(descricao);
    map['valor'] = Variable<double>(valor);
    map['data'] = Variable<DateTime>(data);
    map['tipo'] = Variable<String>(tipo);
    map['nome_banco_original'] = Variable<String>(nomeBancoOriginal);
    map['importado_em'] = Variable<DateTime>(importadoEm);
    return map;
  }

  ExtratoLinhasTableCompanion toCompanion(bool nullToAbsent) {
    return ExtratoLinhasTableCompanion(
      id: Value(id),
      importId: Value(importId),
      descricao: Value(descricao),
      valor: Value(valor),
      data: Value(data),
      tipo: Value(tipo),
      nomeBancoOriginal: Value(nomeBancoOriginal),
      importadoEm: Value(importadoEm),
    );
  }

  factory ExtratoLinhasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtratoLinhasTableData(
      id: serializer.fromJson<String>(json['id']),
      importId: serializer.fromJson<String>(json['importId']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valor: serializer.fromJson<double>(json['valor']),
      data: serializer.fromJson<DateTime>(json['data']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nomeBancoOriginal: serializer.fromJson<String>(json['nomeBancoOriginal']),
      importadoEm: serializer.fromJson<DateTime>(json['importadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'importId': serializer.toJson<String>(importId),
      'descricao': serializer.toJson<String>(descricao),
      'valor': serializer.toJson<double>(valor),
      'data': serializer.toJson<DateTime>(data),
      'tipo': serializer.toJson<String>(tipo),
      'nomeBancoOriginal': serializer.toJson<String>(nomeBancoOriginal),
      'importadoEm': serializer.toJson<DateTime>(importadoEm),
    };
  }

  ExtratoLinhasTableData copyWith({
    String? id,
    String? importId,
    String? descricao,
    double? valor,
    DateTime? data,
    String? tipo,
    String? nomeBancoOriginal,
    DateTime? importadoEm,
  }) => ExtratoLinhasTableData(
    id: id ?? this.id,
    importId: importId ?? this.importId,
    descricao: descricao ?? this.descricao,
    valor: valor ?? this.valor,
    data: data ?? this.data,
    tipo: tipo ?? this.tipo,
    nomeBancoOriginal: nomeBancoOriginal ?? this.nomeBancoOriginal,
    importadoEm: importadoEm ?? this.importadoEm,
  );
  ExtratoLinhasTableData copyWithCompanion(ExtratoLinhasTableCompanion data) {
    return ExtratoLinhasTableData(
      id: data.id.present ? data.id.value : this.id,
      importId: data.importId.present ? data.importId.value : this.importId,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valor: data.valor.present ? data.valor.value : this.valor,
      data: data.data.present ? data.data.value : this.data,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nomeBancoOriginal: data.nomeBancoOriginal.present
          ? data.nomeBancoOriginal.value
          : this.nomeBancoOriginal,
      importadoEm: data.importadoEm.present
          ? data.importadoEm.value
          : this.importadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtratoLinhasTableData(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('tipo: $tipo, ')
          ..write('nomeBancoOriginal: $nomeBancoOriginal, ')
          ..write('importadoEm: $importadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    importId,
    descricao,
    valor,
    data,
    tipo,
    nomeBancoOriginal,
    importadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtratoLinhasTableData &&
          other.id == this.id &&
          other.importId == this.importId &&
          other.descricao == this.descricao &&
          other.valor == this.valor &&
          other.data == this.data &&
          other.tipo == this.tipo &&
          other.nomeBancoOriginal == this.nomeBancoOriginal &&
          other.importadoEm == this.importadoEm);
}

class ExtratoLinhasTableCompanion
    extends UpdateCompanion<ExtratoLinhasTableData> {
  final Value<String> id;
  final Value<String> importId;
  final Value<String> descricao;
  final Value<double> valor;
  final Value<DateTime> data;
  final Value<String> tipo;
  final Value<String> nomeBancoOriginal;
  final Value<DateTime> importadoEm;
  final Value<int> rowid;
  const ExtratoLinhasTableCompanion({
    this.id = const Value.absent(),
    this.importId = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valor = const Value.absent(),
    this.data = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nomeBancoOriginal = const Value.absent(),
    this.importadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExtratoLinhasTableCompanion.insert({
    required String id,
    required String importId,
    required String descricao,
    required double valor,
    required DateTime data,
    required String tipo,
    required String nomeBancoOriginal,
    this.importadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       importId = Value(importId),
       descricao = Value(descricao),
       valor = Value(valor),
       data = Value(data),
       tipo = Value(tipo),
       nomeBancoOriginal = Value(nomeBancoOriginal);
  static Insertable<ExtratoLinhasTableData> custom({
    Expression<String>? id,
    Expression<String>? importId,
    Expression<String>? descricao,
    Expression<double>? valor,
    Expression<DateTime>? data,
    Expression<String>? tipo,
    Expression<String>? nomeBancoOriginal,
    Expression<DateTime>? importadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importId != null) 'import_id': importId,
      if (descricao != null) 'descricao': descricao,
      if (valor != null) 'valor': valor,
      if (data != null) 'data': data,
      if (tipo != null) 'tipo': tipo,
      if (nomeBancoOriginal != null) 'nome_banco_original': nomeBancoOriginal,
      if (importadoEm != null) 'importado_em': importadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExtratoLinhasTableCompanion copyWith({
    Value<String>? id,
    Value<String>? importId,
    Value<String>? descricao,
    Value<double>? valor,
    Value<DateTime>? data,
    Value<String>? tipo,
    Value<String>? nomeBancoOriginal,
    Value<DateTime>? importadoEm,
    Value<int>? rowid,
  }) {
    return ExtratoLinhasTableCompanion(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      nomeBancoOriginal: nomeBancoOriginal ?? this.nomeBancoOriginal,
      importadoEm: importadoEm ?? this.importadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<String>(importId.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nomeBancoOriginal.present) {
      map['nome_banco_original'] = Variable<String>(nomeBancoOriginal.value);
    }
    if (importadoEm.present) {
      map['importado_em'] = Variable<DateTime>(importadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtratoLinhasTableCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('tipo: $tipo, ')
          ..write('nomeBancoOriginal: $nomeBancoOriginal, ')
          ..write('importadoEm: $importadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReconciliationMatchesTableTable extends ReconciliationMatchesTable
    with
        TableInfo<
          $ReconciliationMatchesTableTable,
          ReconciliationMatchesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReconciliationMatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transacaoIdMeta = const VerificationMeta(
    'transacaoId',
  );
  @override
  late final GeneratedColumn<String> transacaoId = GeneratedColumn<String>(
    'transacao_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linhaExtratoIdMeta = const VerificationMeta(
    'linhaExtratoId',
  );
  @override
  late final GeneratedColumn<String> linhaExtratoId = GeneratedColumn<String>(
    'linha_extrato_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataReconciliacaoMeta = const VerificationMeta(
    'dataReconciliacao',
  );
  @override
  late final GeneratedColumn<DateTime> dataReconciliacao =
      GeneratedColumn<DateTime>(
        'data_reconciliacao',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
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
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transacaoId,
    linhaExtratoId,
    dataReconciliacao,
    status,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reconciliation_matches_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReconciliationMatchesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transacao_id')) {
      context.handle(
        _transacaoIdMeta,
        transacaoId.isAcceptableOrUnknown(
          data['transacao_id']!,
          _transacaoIdMeta,
        ),
      );
    }
    if (data.containsKey('linha_extrato_id')) {
      context.handle(
        _linhaExtratoIdMeta,
        linhaExtratoId.isAcceptableOrUnknown(
          data['linha_extrato_id']!,
          _linhaExtratoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_linhaExtratoIdMeta);
    }
    if (data.containsKey('data_reconciliacao')) {
      context.handle(
        _dataReconciliacaoMeta,
        dataReconciliacao.isAcceptableOrUnknown(
          data['data_reconciliacao']!,
          _dataReconciliacaoMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReconciliationMatchesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReconciliationMatchesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transacao_id'],
      ),
      linhaExtratoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linha_extrato_id'],
      )!,
      dataReconciliacao: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_reconciliacao'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $ReconciliationMatchesTableTable createAlias(String alias) {
    return $ReconciliationMatchesTableTable(attachedDatabase, alias);
  }
}

class ReconciliationMatchesTableData extends DataClass
    implements Insertable<ReconciliationMatchesTableData> {
  final String id;
  final String? transacaoId;
  final String linhaExtratoId;
  final DateTime dataReconciliacao;
  final String status;
  final double confidence;
  const ReconciliationMatchesTableData({
    required this.id,
    this.transacaoId,
    required this.linhaExtratoId,
    required this.dataReconciliacao,
    required this.status,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || transacaoId != null) {
      map['transacao_id'] = Variable<String>(transacaoId);
    }
    map['linha_extrato_id'] = Variable<String>(linhaExtratoId);
    map['data_reconciliacao'] = Variable<DateTime>(dataReconciliacao);
    map['status'] = Variable<String>(status);
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  ReconciliationMatchesTableCompanion toCompanion(bool nullToAbsent) {
    return ReconciliationMatchesTableCompanion(
      id: Value(id),
      transacaoId: transacaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(transacaoId),
      linhaExtratoId: Value(linhaExtratoId),
      dataReconciliacao: Value(dataReconciliacao),
      status: Value(status),
      confidence: Value(confidence),
    );
  }

  factory ReconciliationMatchesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReconciliationMatchesTableData(
      id: serializer.fromJson<String>(json['id']),
      transacaoId: serializer.fromJson<String?>(json['transacaoId']),
      linhaExtratoId: serializer.fromJson<String>(json['linhaExtratoId']),
      dataReconciliacao: serializer.fromJson<DateTime>(
        json['dataReconciliacao'],
      ),
      status: serializer.fromJson<String>(json['status']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transacaoId': serializer.toJson<String?>(transacaoId),
      'linhaExtratoId': serializer.toJson<String>(linhaExtratoId),
      'dataReconciliacao': serializer.toJson<DateTime>(dataReconciliacao),
      'status': serializer.toJson<String>(status),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  ReconciliationMatchesTableData copyWith({
    String? id,
    Value<String?> transacaoId = const Value.absent(),
    String? linhaExtratoId,
    DateTime? dataReconciliacao,
    String? status,
    double? confidence,
  }) => ReconciliationMatchesTableData(
    id: id ?? this.id,
    transacaoId: transacaoId.present ? transacaoId.value : this.transacaoId,
    linhaExtratoId: linhaExtratoId ?? this.linhaExtratoId,
    dataReconciliacao: dataReconciliacao ?? this.dataReconciliacao,
    status: status ?? this.status,
    confidence: confidence ?? this.confidence,
  );
  ReconciliationMatchesTableData copyWithCompanion(
    ReconciliationMatchesTableCompanion data,
  ) {
    return ReconciliationMatchesTableData(
      id: data.id.present ? data.id.value : this.id,
      transacaoId: data.transacaoId.present
          ? data.transacaoId.value
          : this.transacaoId,
      linhaExtratoId: data.linhaExtratoId.present
          ? data.linhaExtratoId.value
          : this.linhaExtratoId,
      dataReconciliacao: data.dataReconciliacao.present
          ? data.dataReconciliacao.value
          : this.dataReconciliacao,
      status: data.status.present ? data.status.value : this.status,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReconciliationMatchesTableData(')
          ..write('id: $id, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('linhaExtratoId: $linhaExtratoId, ')
          ..write('dataReconciliacao: $dataReconciliacao, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transacaoId,
    linhaExtratoId,
    dataReconciliacao,
    status,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReconciliationMatchesTableData &&
          other.id == this.id &&
          other.transacaoId == this.transacaoId &&
          other.linhaExtratoId == this.linhaExtratoId &&
          other.dataReconciliacao == this.dataReconciliacao &&
          other.status == this.status &&
          other.confidence == this.confidence);
}

class ReconciliationMatchesTableCompanion
    extends UpdateCompanion<ReconciliationMatchesTableData> {
  final Value<String> id;
  final Value<String?> transacaoId;
  final Value<String> linhaExtratoId;
  final Value<DateTime> dataReconciliacao;
  final Value<String> status;
  final Value<double> confidence;
  final Value<int> rowid;
  const ReconciliationMatchesTableCompanion({
    this.id = const Value.absent(),
    this.transacaoId = const Value.absent(),
    this.linhaExtratoId = const Value.absent(),
    this.dataReconciliacao = const Value.absent(),
    this.status = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReconciliationMatchesTableCompanion.insert({
    required String id,
    this.transacaoId = const Value.absent(),
    required String linhaExtratoId,
    this.dataReconciliacao = const Value.absent(),
    required String status,
    required double confidence,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       linhaExtratoId = Value(linhaExtratoId),
       status = Value(status),
       confidence = Value(confidence);
  static Insertable<ReconciliationMatchesTableData> custom({
    Expression<String>? id,
    Expression<String>? transacaoId,
    Expression<String>? linhaExtratoId,
    Expression<DateTime>? dataReconciliacao,
    Expression<String>? status,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transacaoId != null) 'transacao_id': transacaoId,
      if (linhaExtratoId != null) 'linha_extrato_id': linhaExtratoId,
      if (dataReconciliacao != null) 'data_reconciliacao': dataReconciliacao,
      if (status != null) 'status': status,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReconciliationMatchesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? transacaoId,
    Value<String>? linhaExtratoId,
    Value<DateTime>? dataReconciliacao,
    Value<String>? status,
    Value<double>? confidence,
    Value<int>? rowid,
  }) {
    return ReconciliationMatchesTableCompanion(
      id: id ?? this.id,
      transacaoId: transacaoId ?? this.transacaoId,
      linhaExtratoId: linhaExtratoId ?? this.linhaExtratoId,
      dataReconciliacao: dataReconciliacao ?? this.dataReconciliacao,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transacaoId.present) {
      map['transacao_id'] = Variable<String>(transacaoId.value);
    }
    if (linhaExtratoId.present) {
      map['linha_extrato_id'] = Variable<String>(linhaExtratoId.value);
    }
    if (dataReconciliacao.present) {
      map['data_reconciliacao'] = Variable<DateTime>(dataReconciliacao.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReconciliationMatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('linhaExtratoId: $linhaExtratoId, ')
          ..write('dataReconciliacao: $dataReconciliacao, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrcamentoTableTable extends OrcamentoTable
    with TableInfo<$OrcamentoTableTable, OrcamentoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrcamentoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _limiteMeta = const VerificationMeta('limite');
  @override
  late final GeneratedColumn<double> limite = GeneratedColumn<double>(
    'limite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($OrcamentoTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    categoria,
    limite,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orcamento_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrcamentoTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('limite')) {
      context.handle(
        _limiteMeta,
        limite.isAcceptableOrUnknown(data['limite']!, _limiteMeta),
      );
    } else if (isInserting) {
      context.missing(_limiteMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrcamentoTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrcamentoTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      limite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limite'],
      )!,
      syncStatus: $OrcamentoTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrcamentoTableTable createAlias(String alias) {
    return $OrcamentoTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class OrcamentoTableData extends DataClass
    implements Insertable<OrcamentoTableData> {
  final String id;
  final String? remoteId;
  final String categoria;
  final double limite;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const OrcamentoTableData({
    required this.id,
    this.remoteId,
    required this.categoria,
    required this.limite,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['categoria'] = Variable<String>(categoria);
    map['limite'] = Variable<double>(limite);
    {
      map['sync_status'] = Variable<int>(
        $OrcamentoTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrcamentoTableCompanion toCompanion(bool nullToAbsent) {
    return OrcamentoTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      categoria: Value(categoria),
      limite: Value(limite),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrcamentoTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrcamentoTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      categoria: serializer.fromJson<String>(json['categoria']),
      limite: serializer.fromJson<double>(json['limite']),
      syncStatus: $OrcamentoTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'categoria': serializer.toJson<String>(categoria),
      'limite': serializer.toJson<double>(limite),
      'syncStatus': serializer.toJson<int>(
        $OrcamentoTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrcamentoTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? categoria,
    double? limite,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => OrcamentoTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    categoria: categoria ?? this.categoria,
    limite: limite ?? this.limite,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrcamentoTableData copyWithCompanion(OrcamentoTableCompanion data) {
    return OrcamentoTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      limite: data.limite.present ? data.limite.value : this.limite,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentoTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('categoria: $categoria, ')
          ..write('limite: $limite, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteId, categoria, limite, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrcamentoTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.categoria == this.categoria &&
          other.limite == this.limite &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class OrcamentoTableCompanion extends UpdateCompanion<OrcamentoTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> categoria;
  final Value<double> limite;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OrcamentoTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.categoria = const Value.absent(),
    this.limite = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrcamentoTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String categoria,
    required double limite,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoria = Value(categoria),
       limite = Value(limite);
  static Insertable<OrcamentoTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? categoria,
    Expression<double>? limite,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (categoria != null) 'categoria': categoria,
      if (limite != null) 'limite': limite,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrcamentoTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? categoria,
    Value<double>? limite,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrcamentoTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      categoria: categoria ?? this.categoria,
      limite: limite ?? this.limite,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (limite.present) {
      map['limite'] = Variable<double>(limite.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $OrcamentoTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('OrcamentoTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('categoria: $categoria, ')
          ..write('limite: $limite, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContaTableTable extends ContaTable
    with TableInfo<$ContaTableTable, ContaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vencimentoMeta = const VerificationMeta(
    'vencimento',
  );
  @override
  late final GeneratedColumn<DateTime> vencimento = GeneratedColumn<DateTime>(
    'vencimento',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaBaseMeta = const VerificationMeta(
    'diaBase',
  );
  @override
  late final GeneratedColumn<int> diaBase = GeneratedColumn<int>(
    'dia_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recorrenciaMeta = const VerificationMeta(
    'recorrencia',
  );
  @override
  late final GeneratedColumn<String> recorrencia = GeneratedColumn<String>(
    'recorrencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nenhuma'),
  );
  static const VerificationMeta _pagaMeta = const VerificationMeta('paga');
  @override
  late final GeneratedColumn<bool> paga = GeneratedColumn<bool>(
    'paga',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paga" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dataPagamentoMeta = const VerificationMeta(
    'dataPagamento',
  );
  @override
  late final GeneratedColumn<DateTime> dataPagamento =
      GeneratedColumn<DateTime>(
        'data_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _valorPagoMeta = const VerificationMeta(
    'valorPago',
  );
  @override
  late final GeneratedColumn<double> valorPago = GeneratedColumn<double>(
    'valor_pago',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diasAntesLembreteMeta = const VerificationMeta(
    'diasAntesLembrete',
  );
  @override
  late final GeneratedColumn<int> diasAntesLembrete = GeneratedColumn<int>(
    'dias_antes_lembrete',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _transacaoIdMeta = const VerificationMeta(
    'transacaoId',
  );
  @override
  late final GeneratedColumn<String> transacaoId = GeneratedColumn<String>(
    'transacao_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pendingCreate.index),
      ).withConverter<SyncStatus>($ContaTableTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    descricao,
    categoria,
    valor,
    vencimento,
    diaBase,
    recorrencia,
    paga,
    dataPagamento,
    valorPago,
    diasAntesLembrete,
    transacaoId,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conta_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('vencimento')) {
      context.handle(
        _vencimentoMeta,
        vencimento.isAcceptableOrUnknown(data['vencimento']!, _vencimentoMeta),
      );
    } else if (isInserting) {
      context.missing(_vencimentoMeta);
    }
    if (data.containsKey('dia_base')) {
      context.handle(
        _diaBaseMeta,
        diaBase.isAcceptableOrUnknown(data['dia_base']!, _diaBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_diaBaseMeta);
    }
    if (data.containsKey('recorrencia')) {
      context.handle(
        _recorrenciaMeta,
        recorrencia.isAcceptableOrUnknown(
          data['recorrencia']!,
          _recorrenciaMeta,
        ),
      );
    }
    if (data.containsKey('paga')) {
      context.handle(
        _pagaMeta,
        paga.isAcceptableOrUnknown(data['paga']!, _pagaMeta),
      );
    }
    if (data.containsKey('data_pagamento')) {
      context.handle(
        _dataPagamentoMeta,
        dataPagamento.isAcceptableOrUnknown(
          data['data_pagamento']!,
          _dataPagamentoMeta,
        ),
      );
    }
    if (data.containsKey('valor_pago')) {
      context.handle(
        _valorPagoMeta,
        valorPago.isAcceptableOrUnknown(data['valor_pago']!, _valorPagoMeta),
      );
    }
    if (data.containsKey('dias_antes_lembrete')) {
      context.handle(
        _diasAntesLembreteMeta,
        diasAntesLembrete.isAcceptableOrUnknown(
          data['dias_antes_lembrete']!,
          _diasAntesLembreteMeta,
        ),
      );
    }
    if (data.containsKey('transacao_id')) {
      context.handle(
        _transacaoIdMeta,
        transacaoId.isAcceptableOrUnknown(
          data['transacao_id']!,
          _transacaoIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      vencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vencimento'],
      )!,
      diaBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_base'],
      )!,
      recorrencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorrencia'],
      )!,
      paga: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paga'],
      )!,
      dataPagamento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_pagamento'],
      ),
      valorPago: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_pago'],
      ),
      diasAntesLembrete: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_antes_lembrete'],
      )!,
      transacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transacao_id'],
      ),
      syncStatus: $ContaTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ContaTableTable createAlias(String alias) {
    return $ContaTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ContaTableData extends DataClass implements Insertable<ContaTableData> {
  final String id;
  final String? remoteId;
  final String descricao;
  final String categoria;
  final double valor;
  final DateTime vencimento;

  /// Dia do mês do primeiro vencimento. Uma conta que vence todo dia 31 volta
  /// ao 31 depois de fevereiro, em vez de ficar presa no 28.
  final int diaBase;

  /// 'nenhuma' | 'mensal' | 'anual'
  final String recorrencia;
  final bool paga;
  final DateTime? dataPagamento;
  final double? valorPago;
  final int diasAntesLembrete;
  final String? transacaoId;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const ContaTableData({
    required this.id,
    this.remoteId,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.vencimento,
    required this.diaBase,
    required this.recorrencia,
    required this.paga,
    this.dataPagamento,
    this.valorPago,
    required this.diasAntesLembrete,
    this.transacaoId,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['descricao'] = Variable<String>(descricao);
    map['categoria'] = Variable<String>(categoria);
    map['valor'] = Variable<double>(valor);
    map['vencimento'] = Variable<DateTime>(vencimento);
    map['dia_base'] = Variable<int>(diaBase);
    map['recorrencia'] = Variable<String>(recorrencia);
    map['paga'] = Variable<bool>(paga);
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento);
    }
    if (!nullToAbsent || valorPago != null) {
      map['valor_pago'] = Variable<double>(valorPago);
    }
    map['dias_antes_lembrete'] = Variable<int>(diasAntesLembrete);
    if (!nullToAbsent || transacaoId != null) {
      map['transacao_id'] = Variable<String>(transacaoId);
    }
    {
      map['sync_status'] = Variable<int>(
        $ContaTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ContaTableCompanion toCompanion(bool nullToAbsent) {
    return ContaTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      descricao: Value(descricao),
      categoria: Value(categoria),
      valor: Value(valor),
      vencimento: Value(vencimento),
      diaBase: Value(diaBase),
      recorrencia: Value(recorrencia),
      paga: Value(paga),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
      valorPago: valorPago == null && nullToAbsent
          ? const Value.absent()
          : Value(valorPago),
      diasAntesLembrete: Value(diasAntesLembrete),
      transacaoId: transacaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(transacaoId),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory ContaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContaTableData(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoria: serializer.fromJson<String>(json['categoria']),
      valor: serializer.fromJson<double>(json['valor']),
      vencimento: serializer.fromJson<DateTime>(json['vencimento']),
      diaBase: serializer.fromJson<int>(json['diaBase']),
      recorrencia: serializer.fromJson<String>(json['recorrencia']),
      paga: serializer.fromJson<bool>(json['paga']),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
      valorPago: serializer.fromJson<double?>(json['valorPago']),
      diasAntesLembrete: serializer.fromJson<int>(json['diasAntesLembrete']),
      transacaoId: serializer.fromJson<String?>(json['transacaoId']),
      syncStatus: $ContaTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'descricao': serializer.toJson<String>(descricao),
      'categoria': serializer.toJson<String>(categoria),
      'valor': serializer.toJson<double>(valor),
      'vencimento': serializer.toJson<DateTime>(vencimento),
      'diaBase': serializer.toJson<int>(diaBase),
      'recorrencia': serializer.toJson<String>(recorrencia),
      'paga': serializer.toJson<bool>(paga),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
      'valorPago': serializer.toJson<double?>(valorPago),
      'diasAntesLembrete': serializer.toJson<int>(diasAntesLembrete),
      'transacaoId': serializer.toJson<String?>(transacaoId),
      'syncStatus': serializer.toJson<int>(
        $ContaTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ContaTableData copyWith({
    String? id,
    Value<String?> remoteId = const Value.absent(),
    String? descricao,
    String? categoria,
    double? valor,
    DateTime? vencimento,
    int? diaBase,
    String? recorrencia,
    bool? paga,
    Value<DateTime?> dataPagamento = const Value.absent(),
    Value<double?> valorPago = const Value.absent(),
    int? diasAntesLembrete,
    Value<String?> transacaoId = const Value.absent(),
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => ContaTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    descricao: descricao ?? this.descricao,
    categoria: categoria ?? this.categoria,
    valor: valor ?? this.valor,
    vencimento: vencimento ?? this.vencimento,
    diaBase: diaBase ?? this.diaBase,
    recorrencia: recorrencia ?? this.recorrencia,
    paga: paga ?? this.paga,
    dataPagamento: dataPagamento.present
        ? dataPagamento.value
        : this.dataPagamento,
    valorPago: valorPago.present ? valorPago.value : this.valorPago,
    diasAntesLembrete: diasAntesLembrete ?? this.diasAntesLembrete,
    transacaoId: transacaoId.present ? transacaoId.value : this.transacaoId,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ContaTableData copyWithCompanion(ContaTableCompanion data) {
    return ContaTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      valor: data.valor.present ? data.valor.value : this.valor,
      vencimento: data.vencimento.present
          ? data.vencimento.value
          : this.vencimento,
      diaBase: data.diaBase.present ? data.diaBase.value : this.diaBase,
      recorrencia: data.recorrencia.present
          ? data.recorrencia.value
          : this.recorrencia,
      paga: data.paga.present ? data.paga.value : this.paga,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
      valorPago: data.valorPago.present ? data.valorPago.value : this.valorPago,
      diasAntesLembrete: data.diasAntesLembrete.present
          ? data.diasAntesLembrete.value
          : this.diasAntesLembrete,
      transacaoId: data.transacaoId.present
          ? data.transacaoId.value
          : this.transacaoId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContaTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('descricao: $descricao, ')
          ..write('categoria: $categoria, ')
          ..write('valor: $valor, ')
          ..write('vencimento: $vencimento, ')
          ..write('diaBase: $diaBase, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('paga: $paga, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('valorPago: $valorPago, ')
          ..write('diasAntesLembrete: $diasAntesLembrete, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    descricao,
    categoria,
    valor,
    vencimento,
    diaBase,
    recorrencia,
    paga,
    dataPagamento,
    valorPago,
    diasAntesLembrete,
    transacaoId,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContaTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.descricao == this.descricao &&
          other.categoria == this.categoria &&
          other.valor == this.valor &&
          other.vencimento == this.vencimento &&
          other.diaBase == this.diaBase &&
          other.recorrencia == this.recorrencia &&
          other.paga == this.paga &&
          other.dataPagamento == this.dataPagamento &&
          other.valorPago == this.valorPago &&
          other.diasAntesLembrete == this.diasAntesLembrete &&
          other.transacaoId == this.transacaoId &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class ContaTableCompanion extends UpdateCompanion<ContaTableData> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> descricao;
  final Value<String> categoria;
  final Value<double> valor;
  final Value<DateTime> vencimento;
  final Value<int> diaBase;
  final Value<String> recorrencia;
  final Value<bool> paga;
  final Value<DateTime?> dataPagamento;
  final Value<double?> valorPago;
  final Value<int> diasAntesLembrete;
  final Value<String?> transacaoId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ContaTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoria = const Value.absent(),
    this.valor = const Value.absent(),
    this.vencimento = const Value.absent(),
    this.diaBase = const Value.absent(),
    this.recorrencia = const Value.absent(),
    this.paga = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.valorPago = const Value.absent(),
    this.diasAntesLembrete = const Value.absent(),
    this.transacaoId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContaTableCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String descricao,
    this.categoria = const Value.absent(),
    required double valor,
    required DateTime vencimento,
    required int diaBase,
    this.recorrencia = const Value.absent(),
    this.paga = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.valorPago = const Value.absent(),
    this.diasAntesLembrete = const Value.absent(),
    this.transacaoId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       descricao = Value(descricao),
       valor = Value(valor),
       vencimento = Value(vencimento),
       diaBase = Value(diaBase);
  static Insertable<ContaTableData> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? descricao,
    Expression<String>? categoria,
    Expression<double>? valor,
    Expression<DateTime>? vencimento,
    Expression<int>? diaBase,
    Expression<String>? recorrencia,
    Expression<bool>? paga,
    Expression<DateTime>? dataPagamento,
    Expression<double>? valorPago,
    Expression<int>? diasAntesLembrete,
    Expression<String>? transacaoId,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (descricao != null) 'descricao': descricao,
      if (categoria != null) 'categoria': categoria,
      if (valor != null) 'valor': valor,
      if (vencimento != null) 'vencimento': vencimento,
      if (diaBase != null) 'dia_base': diaBase,
      if (recorrencia != null) 'recorrencia': recorrencia,
      if (paga != null) 'paga': paga,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (valorPago != null) 'valor_pago': valorPago,
      if (diasAntesLembrete != null) 'dias_antes_lembrete': diasAntesLembrete,
      if (transacaoId != null) 'transacao_id': transacaoId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContaTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteId,
    Value<String>? descricao,
    Value<String>? categoria,
    Value<double>? valor,
    Value<DateTime>? vencimento,
    Value<int>? diaBase,
    Value<String>? recorrencia,
    Value<bool>? paga,
    Value<DateTime?>? dataPagamento,
    Value<double?>? valorPago,
    Value<int>? diasAntesLembrete,
    Value<String?>? transacaoId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ContaTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      vencimento: vencimento ?? this.vencimento,
      diaBase: diaBase ?? this.diaBase,
      recorrencia: recorrencia ?? this.recorrencia,
      paga: paga ?? this.paga,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      valorPago: valorPago ?? this.valorPago,
      diasAntesLembrete: diasAntesLembrete ?? this.diasAntesLembrete,
      transacaoId: transacaoId ?? this.transacaoId,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (vencimento.present) {
      map['vencimento'] = Variable<DateTime>(vencimento.value);
    }
    if (diaBase.present) {
      map['dia_base'] = Variable<int>(diaBase.value);
    }
    if (recorrencia.present) {
      map['recorrencia'] = Variable<String>(recorrencia.value);
    }
    if (paga.present) {
      map['paga'] = Variable<bool>(paga.value);
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento.value);
    }
    if (valorPago.present) {
      map['valor_pago'] = Variable<double>(valorPago.value);
    }
    if (diasAntesLembrete.present) {
      map['dias_antes_lembrete'] = Variable<int>(diasAntesLembrete.value);
    }
    if (transacaoId.present) {
      map['transacao_id'] = Variable<String>(transacaoId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ContaTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
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
    return (StringBuffer('ContaTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('descricao: $descricao, ')
          ..write('categoria: $categoria, ')
          ..write('valor: $valor, ')
          ..write('vencimento: $vencimento, ')
          ..write('diaBase: $diaBase, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('paga: $paga, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('valorPago: $valorPago, ')
          ..write('diasAntesLembrete: $diasAntesLembrete, ')
          ..write('transacaoId: $transacaoId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $PerfilBancoTableTable perfilBancoTable = $PerfilBancoTableTable(
    this,
  );
  late final $RendaTableTable rendaTable = $RendaTableTable(this);
  late final $MetaTableTable metaTable = $MetaTableTable(this);
  late final $ParcelamentoTableTable parcelamentoTable =
      $ParcelamentoTableTable(this);
  late final $ExtratoLinhasTableTable extratoLinhasTable =
      $ExtratoLinhasTableTable(this);
  late final $ReconciliationMatchesTableTable reconciliationMatchesTable =
      $ReconciliationMatchesTableTable(this);
  late final $OrcamentoTableTable orcamentoTable = $OrcamentoTableTable(this);
  late final $ContaTableTable contaTable = $ContaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionsTable,
    perfilBancoTable,
    rendaTable,
    metaTable,
    parcelamentoTable,
    extratoLinhasTable,
    reconciliationMatchesTable,
    orcamentoTable,
    contaTable,
  ];
}

typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String name,
      required String category,
      required double value,
      required DateTime occurredAt,
      Value<bool> needsCategory,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<String?> parcelamentoId,
      Value<int?> numeroParcela,
      Value<double?> valorParcela,
      Value<bool> ehParcela,
      Value<String?> statusParcela,
      Value<double?> minhaParte,
      Value<String?> divididoCom,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> name,
      Value<String> category,
      Value<double> value,
      Value<DateTime> occurredAt,
      Value<bool> needsCategory,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<String?> parcelamentoId,
      Value<int?> numeroParcela,
      Value<double?> valorParcela,
      Value<bool> ehParcela,
      Value<String?> statusParcela,
      Value<double?> minhaParte,
      Value<String?> divididoCom,
      Value<int> rowid,
    });

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsCategory => $composableBuilder(
    column: $table.needsCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelamentoId => $composableBuilder(
    column: $table.parcelamentoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorParcela => $composableBuilder(
    column: $table.valorParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ehParcela => $composableBuilder(
    column: $table.ehParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusParcela => $composableBuilder(
    column: $table.statusParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minhaParte => $composableBuilder(
    column: $table.minhaParte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get divididoCom => $composableBuilder(
    column: $table.divididoCom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsCategory => $composableBuilder(
    column: $table.needsCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelamentoId => $composableBuilder(
    column: $table.parcelamentoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorParcela => $composableBuilder(
    column: $table.valorParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ehParcela => $composableBuilder(
    column: $table.ehParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusParcela => $composableBuilder(
    column: $table.statusParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minhaParte => $composableBuilder(
    column: $table.minhaParte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get divididoCom => $composableBuilder(
    column: $table.divididoCom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsCategory => $composableBuilder(
    column: $table.needsCategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get parcelamentoId => $composableBuilder(
    column: $table.parcelamentoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorParcela => $composableBuilder(
    column: $table.valorParcela,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ehParcela =>
      $composableBuilder(column: $table.ehParcela, builder: (column) => column);

  GeneratedColumn<String> get statusParcela => $composableBuilder(
    column: $table.statusParcela,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minhaParte => $composableBuilder(
    column: $table.minhaParte,
    builder: (column) => column,
  );

  GeneratedColumn<String> get divididoCom => $composableBuilder(
    column: $table.divididoCom,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (
            TransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TransactionsTableTable,
              TransactionsTableData
            >,
          ),
          TransactionsTableData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<bool> needsCategory = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> parcelamentoId = const Value.absent(),
                Value<int?> numeroParcela = const Value.absent(),
                Value<double?> valorParcela = const Value.absent(),
                Value<bool> ehParcela = const Value.absent(),
                Value<String?> statusParcela = const Value.absent(),
                Value<double?> minhaParte = const Value.absent(),
                Value<String?> divididoCom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                remoteId: remoteId,
                name: name,
                category: category,
                value: value,
                occurredAt: occurredAt,
                needsCategory: needsCategory,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                parcelamentoId: parcelamentoId,
                numeroParcela: numeroParcela,
                valorParcela: valorParcela,
                ehParcela: ehParcela,
                statusParcela: statusParcela,
                minhaParte: minhaParte,
                divididoCom: divididoCom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String name,
                required String category,
                required double value,
                required DateTime occurredAt,
                Value<bool> needsCategory = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> parcelamentoId = const Value.absent(),
                Value<int?> numeroParcela = const Value.absent(),
                Value<double?> valorParcela = const Value.absent(),
                Value<bool> ehParcela = const Value.absent(),
                Value<String?> statusParcela = const Value.absent(),
                Value<double?> minhaParte = const Value.absent(),
                Value<String?> divididoCom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                name: name,
                category: category,
                value: value,
                occurredAt: occurredAt,
                needsCategory: needsCategory,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                parcelamentoId: parcelamentoId,
                numeroParcela: numeroParcela,
                valorParcela: valorParcela,
                ehParcela: ehParcela,
                statusParcela: statusParcela,
                minhaParte: minhaParte,
                divididoCom: divididoCom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (
        TransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        >,
      ),
      TransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$PerfilBancoTableTableCreateCompanionBuilder =
    PerfilBancoTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String nomeBanco,
      required String delimitador,
      Value<bool> codificacaoLatin1,
      Value<bool> temCabecalho,
      required String formatoData,
      Value<bool> separadorDecimalVirgula,
      required String mapeamentoColunasJson,
      required String assinaturaCabecalhoJson,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PerfilBancoTableTableUpdateCompanionBuilder =
    PerfilBancoTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> nomeBanco,
      Value<String> delimitador,
      Value<bool> codificacaoLatin1,
      Value<bool> temCabecalho,
      Value<String> formatoData,
      Value<bool> separadorDecimalVirgula,
      Value<String> mapeamentoColunasJson,
      Value<String> assinaturaCabecalhoJson,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PerfilBancoTableTableFilterComposer
    extends Composer<_$AppDatabase, $PerfilBancoTableTable> {
  $$PerfilBancoTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeBanco => $composableBuilder(
    column: $table.nomeBanco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get delimitador => $composableBuilder(
    column: $table.delimitador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get codificacaoLatin1 => $composableBuilder(
    column: $table.codificacaoLatin1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get separadorDecimalVirgula => $composableBuilder(
    column: $table.separadorDecimalVirgula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapeamentoColunasJson => $composableBuilder(
    column: $table.mapeamentoColunasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assinaturaCabecalhoJson => $composableBuilder(
    column: $table.assinaturaCabecalhoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PerfilBancoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PerfilBancoTableTable> {
  $$PerfilBancoTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeBanco => $composableBuilder(
    column: $table.nomeBanco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get delimitador => $composableBuilder(
    column: $table.delimitador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get codificacaoLatin1 => $composableBuilder(
    column: $table.codificacaoLatin1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get separadorDecimalVirgula => $composableBuilder(
    column: $table.separadorDecimalVirgula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapeamentoColunasJson => $composableBuilder(
    column: $table.mapeamentoColunasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assinaturaCabecalhoJson => $composableBuilder(
    column: $table.assinaturaCabecalhoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PerfilBancoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PerfilBancoTableTable> {
  $$PerfilBancoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get nomeBanco =>
      $composableBuilder(column: $table.nomeBanco, builder: (column) => column);

  GeneratedColumn<String> get delimitador => $composableBuilder(
    column: $table.delimitador,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get codificacaoLatin1 => $composableBuilder(
    column: $table.codificacaoLatin1,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get separadorDecimalVirgula => $composableBuilder(
    column: $table.separadorDecimalVirgula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mapeamentoColunasJson => $composableBuilder(
    column: $table.mapeamentoColunasJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assinaturaCabecalhoJson => $composableBuilder(
    column: $table.assinaturaCabecalhoJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PerfilBancoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PerfilBancoTableTable,
          PerfilBancoTableData,
          $$PerfilBancoTableTableFilterComposer,
          $$PerfilBancoTableTableOrderingComposer,
          $$PerfilBancoTableTableAnnotationComposer,
          $$PerfilBancoTableTableCreateCompanionBuilder,
          $$PerfilBancoTableTableUpdateCompanionBuilder,
          (
            PerfilBancoTableData,
            BaseReferences<
              _$AppDatabase,
              $PerfilBancoTableTable,
              PerfilBancoTableData
            >,
          ),
          PerfilBancoTableData,
          PrefetchHooks Function()
        > {
  $$PerfilBancoTableTableTableManager(
    _$AppDatabase db,
    $PerfilBancoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PerfilBancoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PerfilBancoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PerfilBancoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> nomeBanco = const Value.absent(),
                Value<String> delimitador = const Value.absent(),
                Value<bool> codificacaoLatin1 = const Value.absent(),
                Value<bool> temCabecalho = const Value.absent(),
                Value<String> formatoData = const Value.absent(),
                Value<bool> separadorDecimalVirgula = const Value.absent(),
                Value<String> mapeamentoColunasJson = const Value.absent(),
                Value<String> assinaturaCabecalhoJson = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PerfilBancoTableCompanion(
                id: id,
                remoteId: remoteId,
                nomeBanco: nomeBanco,
                delimitador: delimitador,
                codificacaoLatin1: codificacaoLatin1,
                temCabecalho: temCabecalho,
                formatoData: formatoData,
                separadorDecimalVirgula: separadorDecimalVirgula,
                mapeamentoColunasJson: mapeamentoColunasJson,
                assinaturaCabecalhoJson: assinaturaCabecalhoJson,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String nomeBanco,
                required String delimitador,
                Value<bool> codificacaoLatin1 = const Value.absent(),
                Value<bool> temCabecalho = const Value.absent(),
                required String formatoData,
                Value<bool> separadorDecimalVirgula = const Value.absent(),
                required String mapeamentoColunasJson,
                required String assinaturaCabecalhoJson,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PerfilBancoTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                nomeBanco: nomeBanco,
                delimitador: delimitador,
                codificacaoLatin1: codificacaoLatin1,
                temCabecalho: temCabecalho,
                formatoData: formatoData,
                separadorDecimalVirgula: separadorDecimalVirgula,
                mapeamentoColunasJson: mapeamentoColunasJson,
                assinaturaCabecalhoJson: assinaturaCabecalhoJson,
                syncStatus: syncStatus,
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

typedef $$PerfilBancoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PerfilBancoTableTable,
      PerfilBancoTableData,
      $$PerfilBancoTableTableFilterComposer,
      $$PerfilBancoTableTableOrderingComposer,
      $$PerfilBancoTableTableAnnotationComposer,
      $$PerfilBancoTableTableCreateCompanionBuilder,
      $$PerfilBancoTableTableUpdateCompanionBuilder,
      (
        PerfilBancoTableData,
        BaseReferences<
          _$AppDatabase,
          $PerfilBancoTableTable,
          PerfilBancoTableData
        >,
      ),
      PerfilBancoTableData,
      PrefetchHooks Function()
    >;
typedef $$RendaTableTableCreateCompanionBuilder =
    RendaTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String descricao,
      required double valor,
      required String tipo,
      Value<String?> recorrencia,
      required DateTime dataRecebimento,
      Value<bool> ativa,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RendaTableTableUpdateCompanionBuilder =
    RendaTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> descricao,
      Value<double> valor,
      Value<String> tipo,
      Value<String?> recorrencia,
      Value<DateTime> dataRecebimento,
      Value<bool> ativa,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RendaTableTableFilterComposer
    extends Composer<_$AppDatabase, $RendaTableTable> {
  $$RendaTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RendaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RendaTableTable> {
  $$RendaTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RendaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RendaTableTable> {
  $$RendaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RendaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RendaTableTable,
          RendaTableData,
          $$RendaTableTableFilterComposer,
          $$RendaTableTableOrderingComposer,
          $$RendaTableTableAnnotationComposer,
          $$RendaTableTableCreateCompanionBuilder,
          $$RendaTableTableUpdateCompanionBuilder,
          (
            RendaTableData,
            BaseReferences<_$AppDatabase, $RendaTableTable, RendaTableData>,
          ),
          RendaTableData,
          PrefetchHooks Function()
        > {
  $$RendaTableTableTableManager(_$AppDatabase db, $RendaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RendaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RendaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RendaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> recorrencia = const Value.absent(),
                Value<DateTime> dataRecebimento = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RendaTableCompanion(
                id: id,
                remoteId: remoteId,
                descricao: descricao,
                valor: valor,
                tipo: tipo,
                recorrencia: recorrencia,
                dataRecebimento: dataRecebimento,
                ativa: ativa,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String descricao,
                required double valor,
                required String tipo,
                Value<String?> recorrencia = const Value.absent(),
                required DateTime dataRecebimento,
                Value<bool> ativa = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RendaTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                descricao: descricao,
                valor: valor,
                tipo: tipo,
                recorrencia: recorrencia,
                dataRecebimento: dataRecebimento,
                ativa: ativa,
                syncStatus: syncStatus,
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

typedef $$RendaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RendaTableTable,
      RendaTableData,
      $$RendaTableTableFilterComposer,
      $$RendaTableTableOrderingComposer,
      $$RendaTableTableAnnotationComposer,
      $$RendaTableTableCreateCompanionBuilder,
      $$RendaTableTableUpdateCompanionBuilder,
      (
        RendaTableData,
        BaseReferences<_$AppDatabase, $RendaTableTable, RendaTableData>,
      ),
      RendaTableData,
      PrefetchHooks Function()
    >;
typedef $$MetaTableTableCreateCompanionBuilder =
    MetaTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String nome,
      Value<double> valorAtual,
      required double valorAlvo,
      required DateTime prazo,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$MetaTableTableUpdateCompanionBuilder =
    MetaTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> nome,
      Value<double> valorAtual,
      Value<double> valorAlvo,
      Value<DateTime> prazo,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get prazo => $composableBuilder(
    column: $table.prazo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get prazo => $composableBuilder(
    column: $table.prazo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get valorAtual => $composableBuilder(
    column: $table.valorAtual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorAlvo =>
      $composableBuilder(column: $table.valorAlvo, builder: (column) => column);

  GeneratedColumn<DateTime> get prazo =>
      $composableBuilder(column: $table.prazo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MetaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTableTable,
          MetaTableData,
          $$MetaTableTableFilterComposer,
          $$MetaTableTableOrderingComposer,
          $$MetaTableTableAnnotationComposer,
          $$MetaTableTableCreateCompanionBuilder,
          $$MetaTableTableUpdateCompanionBuilder,
          (
            MetaTableData,
            BaseReferences<_$AppDatabase, $MetaTableTable, MetaTableData>,
          ),
          MetaTableData,
          PrefetchHooks Function()
        > {
  $$MetaTableTableTableManager(_$AppDatabase db, $MetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> valorAtual = const Value.absent(),
                Value<double> valorAlvo = const Value.absent(),
                Value<DateTime> prazo = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion(
                id: id,
                remoteId: remoteId,
                nome: nome,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                prazo: prazo,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String nome,
                Value<double> valorAtual = const Value.absent(),
                required double valorAlvo,
                required DateTime prazo,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                nome: nome,
                valorAtual: valorAtual,
                valorAlvo: valorAlvo,
                prazo: prazo,
                syncStatus: syncStatus,
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

typedef $$MetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTableTable,
      MetaTableData,
      $$MetaTableTableFilterComposer,
      $$MetaTableTableOrderingComposer,
      $$MetaTableTableAnnotationComposer,
      $$MetaTableTableCreateCompanionBuilder,
      $$MetaTableTableUpdateCompanionBuilder,
      (
        MetaTableData,
        BaseReferences<_$AppDatabase, $MetaTableTable, MetaTableData>,
      ),
      MetaTableData,
      PrefetchHooks Function()
    >;
typedef $$ParcelamentoTableTableCreateCompanionBuilder =
    ParcelamentoTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String transacaoOriginalId,
      required double totalOriginal,
      required int numeroParcelas,
      required DateTime dataPrimeiraParc,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ParcelamentoTableTableUpdateCompanionBuilder =
    ParcelamentoTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> transacaoOriginalId,
      Value<double> totalOriginal,
      Value<int> numeroParcelas,
      Value<DateTime> dataPrimeiraParc,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ParcelamentoTableTableFilterComposer
    extends Composer<_$AppDatabase, $ParcelamentoTableTable> {
  $$ParcelamentoTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transacaoOriginalId => $composableBuilder(
    column: $table.transacaoOriginalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalOriginal => $composableBuilder(
    column: $table.totalOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPrimeiraParc => $composableBuilder(
    column: $table.dataPrimeiraParc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParcelamentoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ParcelamentoTableTable> {
  $$ParcelamentoTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transacaoOriginalId => $composableBuilder(
    column: $table.transacaoOriginalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalOriginal => $composableBuilder(
    column: $table.totalOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPrimeiraParc => $composableBuilder(
    column: $table.dataPrimeiraParc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParcelamentoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParcelamentoTableTable> {
  $$ParcelamentoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get transacaoOriginalId => $composableBuilder(
    column: $table.transacaoOriginalId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalOriginal => $composableBuilder(
    column: $table.totalOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataPrimeiraParc => $composableBuilder(
    column: $table.dataPrimeiraParc,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ParcelamentoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParcelamentoTableTable,
          ParcelamentoTableData,
          $$ParcelamentoTableTableFilterComposer,
          $$ParcelamentoTableTableOrderingComposer,
          $$ParcelamentoTableTableAnnotationComposer,
          $$ParcelamentoTableTableCreateCompanionBuilder,
          $$ParcelamentoTableTableUpdateCompanionBuilder,
          (
            ParcelamentoTableData,
            BaseReferences<
              _$AppDatabase,
              $ParcelamentoTableTable,
              ParcelamentoTableData
            >,
          ),
          ParcelamentoTableData,
          PrefetchHooks Function()
        > {
  $$ParcelamentoTableTableTableManager(
    _$AppDatabase db,
    $ParcelamentoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParcelamentoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParcelamentoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParcelamentoTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> transacaoOriginalId = const Value.absent(),
                Value<double> totalOriginal = const Value.absent(),
                Value<int> numeroParcelas = const Value.absent(),
                Value<DateTime> dataPrimeiraParc = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParcelamentoTableCompanion(
                id: id,
                remoteId: remoteId,
                transacaoOriginalId: transacaoOriginalId,
                totalOriginal: totalOriginal,
                numeroParcelas: numeroParcelas,
                dataPrimeiraParc: dataPrimeiraParc,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String transacaoOriginalId,
                required double totalOriginal,
                required int numeroParcelas,
                required DateTime dataPrimeiraParc,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParcelamentoTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                transacaoOriginalId: transacaoOriginalId,
                totalOriginal: totalOriginal,
                numeroParcelas: numeroParcelas,
                dataPrimeiraParc: dataPrimeiraParc,
                syncStatus: syncStatus,
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

typedef $$ParcelamentoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParcelamentoTableTable,
      ParcelamentoTableData,
      $$ParcelamentoTableTableFilterComposer,
      $$ParcelamentoTableTableOrderingComposer,
      $$ParcelamentoTableTableAnnotationComposer,
      $$ParcelamentoTableTableCreateCompanionBuilder,
      $$ParcelamentoTableTableUpdateCompanionBuilder,
      (
        ParcelamentoTableData,
        BaseReferences<
          _$AppDatabase,
          $ParcelamentoTableTable,
          ParcelamentoTableData
        >,
      ),
      ParcelamentoTableData,
      PrefetchHooks Function()
    >;
typedef $$ExtratoLinhasTableTableCreateCompanionBuilder =
    ExtratoLinhasTableCompanion Function({
      required String id,
      required String importId,
      required String descricao,
      required double valor,
      required DateTime data,
      required String tipo,
      required String nomeBancoOriginal,
      Value<DateTime> importadoEm,
      Value<int> rowid,
    });
typedef $$ExtratoLinhasTableTableUpdateCompanionBuilder =
    ExtratoLinhasTableCompanion Function({
      Value<String> id,
      Value<String> importId,
      Value<String> descricao,
      Value<double> valor,
      Value<DateTime> data,
      Value<String> tipo,
      Value<String> nomeBancoOriginal,
      Value<DateTime> importadoEm,
      Value<int> rowid,
    });

class $$ExtratoLinhasTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExtratoLinhasTableTable> {
  $$ExtratoLinhasTableTableFilterComposer({
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

  ColumnFilters<String> get importId => $composableBuilder(
    column: $table.importId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeBancoOriginal => $composableBuilder(
    column: $table.nomeBancoOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importadoEm => $composableBuilder(
    column: $table.importadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtratoLinhasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExtratoLinhasTableTable> {
  $$ExtratoLinhasTableTableOrderingComposer({
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

  ColumnOrderings<String> get importId => $composableBuilder(
    column: $table.importId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeBancoOriginal => $composableBuilder(
    column: $table.nomeBancoOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importadoEm => $composableBuilder(
    column: $table.importadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtratoLinhasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExtratoLinhasTableTable> {
  $$ExtratoLinhasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get importId =>
      $composableBuilder(column: $table.importId, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nomeBancoOriginal => $composableBuilder(
    column: $table.nomeBancoOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importadoEm => $composableBuilder(
    column: $table.importadoEm,
    builder: (column) => column,
  );
}

class $$ExtratoLinhasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExtratoLinhasTableTable,
          ExtratoLinhasTableData,
          $$ExtratoLinhasTableTableFilterComposer,
          $$ExtratoLinhasTableTableOrderingComposer,
          $$ExtratoLinhasTableTableAnnotationComposer,
          $$ExtratoLinhasTableTableCreateCompanionBuilder,
          $$ExtratoLinhasTableTableUpdateCompanionBuilder,
          (
            ExtratoLinhasTableData,
            BaseReferences<
              _$AppDatabase,
              $ExtratoLinhasTableTable,
              ExtratoLinhasTableData
            >,
          ),
          ExtratoLinhasTableData,
          PrefetchHooks Function()
        > {
  $$ExtratoLinhasTableTableTableManager(
    _$AppDatabase db,
    $ExtratoLinhasTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtratoLinhasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtratoLinhasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtratoLinhasTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> importId = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nomeBancoOriginal = const Value.absent(),
                Value<DateTime> importadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExtratoLinhasTableCompanion(
                id: id,
                importId: importId,
                descricao: descricao,
                valor: valor,
                data: data,
                tipo: tipo,
                nomeBancoOriginal: nomeBancoOriginal,
                importadoEm: importadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String importId,
                required String descricao,
                required double valor,
                required DateTime data,
                required String tipo,
                required String nomeBancoOriginal,
                Value<DateTime> importadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExtratoLinhasTableCompanion.insert(
                id: id,
                importId: importId,
                descricao: descricao,
                valor: valor,
                data: data,
                tipo: tipo,
                nomeBancoOriginal: nomeBancoOriginal,
                importadoEm: importadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtratoLinhasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExtratoLinhasTableTable,
      ExtratoLinhasTableData,
      $$ExtratoLinhasTableTableFilterComposer,
      $$ExtratoLinhasTableTableOrderingComposer,
      $$ExtratoLinhasTableTableAnnotationComposer,
      $$ExtratoLinhasTableTableCreateCompanionBuilder,
      $$ExtratoLinhasTableTableUpdateCompanionBuilder,
      (
        ExtratoLinhasTableData,
        BaseReferences<
          _$AppDatabase,
          $ExtratoLinhasTableTable,
          ExtratoLinhasTableData
        >,
      ),
      ExtratoLinhasTableData,
      PrefetchHooks Function()
    >;
typedef $$ReconciliationMatchesTableTableCreateCompanionBuilder =
    ReconciliationMatchesTableCompanion Function({
      required String id,
      Value<String?> transacaoId,
      required String linhaExtratoId,
      Value<DateTime> dataReconciliacao,
      required String status,
      required double confidence,
      Value<int> rowid,
    });
typedef $$ReconciliationMatchesTableTableUpdateCompanionBuilder =
    ReconciliationMatchesTableCompanion Function({
      Value<String> id,
      Value<String?> transacaoId,
      Value<String> linhaExtratoId,
      Value<DateTime> dataReconciliacao,
      Value<String> status,
      Value<double> confidence,
      Value<int> rowid,
    });

class $$ReconciliationMatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReconciliationMatchesTableTable> {
  $$ReconciliationMatchesTableTableFilterComposer({
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

  ColumnFilters<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linhaExtratoId => $composableBuilder(
    column: $table.linhaExtratoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataReconciliacao => $composableBuilder(
    column: $table.dataReconciliacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReconciliationMatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReconciliationMatchesTableTable> {
  $$ReconciliationMatchesTableTableOrderingComposer({
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

  ColumnOrderings<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linhaExtratoId => $composableBuilder(
    column: $table.linhaExtratoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataReconciliacao => $composableBuilder(
    column: $table.dataReconciliacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReconciliationMatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReconciliationMatchesTableTable> {
  $$ReconciliationMatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linhaExtratoId => $composableBuilder(
    column: $table.linhaExtratoId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataReconciliacao => $composableBuilder(
    column: $table.dataReconciliacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );
}

class $$ReconciliationMatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReconciliationMatchesTableTable,
          ReconciliationMatchesTableData,
          $$ReconciliationMatchesTableTableFilterComposer,
          $$ReconciliationMatchesTableTableOrderingComposer,
          $$ReconciliationMatchesTableTableAnnotationComposer,
          $$ReconciliationMatchesTableTableCreateCompanionBuilder,
          $$ReconciliationMatchesTableTableUpdateCompanionBuilder,
          (
            ReconciliationMatchesTableData,
            BaseReferences<
              _$AppDatabase,
              $ReconciliationMatchesTableTable,
              ReconciliationMatchesTableData
            >,
          ),
          ReconciliationMatchesTableData,
          PrefetchHooks Function()
        > {
  $$ReconciliationMatchesTableTableTableManager(
    _$AppDatabase db,
    $ReconciliationMatchesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReconciliationMatchesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReconciliationMatchesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReconciliationMatchesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> transacaoId = const Value.absent(),
                Value<String> linhaExtratoId = const Value.absent(),
                Value<DateTime> dataReconciliacao = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationMatchesTableCompanion(
                id: id,
                transacaoId: transacaoId,
                linhaExtratoId: linhaExtratoId,
                dataReconciliacao: dataReconciliacao,
                status: status,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> transacaoId = const Value.absent(),
                required String linhaExtratoId,
                Value<DateTime> dataReconciliacao = const Value.absent(),
                required String status,
                required double confidence,
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationMatchesTableCompanion.insert(
                id: id,
                transacaoId: transacaoId,
                linhaExtratoId: linhaExtratoId,
                dataReconciliacao: dataReconciliacao,
                status: status,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReconciliationMatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReconciliationMatchesTableTable,
      ReconciliationMatchesTableData,
      $$ReconciliationMatchesTableTableFilterComposer,
      $$ReconciliationMatchesTableTableOrderingComposer,
      $$ReconciliationMatchesTableTableAnnotationComposer,
      $$ReconciliationMatchesTableTableCreateCompanionBuilder,
      $$ReconciliationMatchesTableTableUpdateCompanionBuilder,
      (
        ReconciliationMatchesTableData,
        BaseReferences<
          _$AppDatabase,
          $ReconciliationMatchesTableTable,
          ReconciliationMatchesTableData
        >,
      ),
      ReconciliationMatchesTableData,
      PrefetchHooks Function()
    >;
typedef $$OrcamentoTableTableCreateCompanionBuilder =
    OrcamentoTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String categoria,
      required double limite,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$OrcamentoTableTableUpdateCompanionBuilder =
    OrcamentoTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> categoria,
      Value<double> limite,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OrcamentoTableTableFilterComposer
    extends Composer<_$AppDatabase, $OrcamentoTableTable> {
  $$OrcamentoTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrcamentoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OrcamentoTableTable> {
  $$OrcamentoTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrcamentoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrcamentoTableTable> {
  $$OrcamentoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get limite =>
      $composableBuilder(column: $table.limite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrcamentoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrcamentoTableTable,
          OrcamentoTableData,
          $$OrcamentoTableTableFilterComposer,
          $$OrcamentoTableTableOrderingComposer,
          $$OrcamentoTableTableAnnotationComposer,
          $$OrcamentoTableTableCreateCompanionBuilder,
          $$OrcamentoTableTableUpdateCompanionBuilder,
          (
            OrcamentoTableData,
            BaseReferences<
              _$AppDatabase,
              $OrcamentoTableTable,
              OrcamentoTableData
            >,
          ),
          OrcamentoTableData,
          PrefetchHooks Function()
        > {
  $$OrcamentoTableTableTableManager(
    _$AppDatabase db,
    $OrcamentoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrcamentoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrcamentoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrcamentoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<double> limite = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrcamentoTableCompanion(
                id: id,
                remoteId: remoteId,
                categoria: categoria,
                limite: limite,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String categoria,
                required double limite,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrcamentoTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                categoria: categoria,
                limite: limite,
                syncStatus: syncStatus,
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

typedef $$OrcamentoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrcamentoTableTable,
      OrcamentoTableData,
      $$OrcamentoTableTableFilterComposer,
      $$OrcamentoTableTableOrderingComposer,
      $$OrcamentoTableTableAnnotationComposer,
      $$OrcamentoTableTableCreateCompanionBuilder,
      $$OrcamentoTableTableUpdateCompanionBuilder,
      (
        OrcamentoTableData,
        BaseReferences<_$AppDatabase, $OrcamentoTableTable, OrcamentoTableData>,
      ),
      OrcamentoTableData,
      PrefetchHooks Function()
    >;
typedef $$ContaTableTableCreateCompanionBuilder =
    ContaTableCompanion Function({
      required String id,
      Value<String?> remoteId,
      required String descricao,
      Value<String> categoria,
      required double valor,
      required DateTime vencimento,
      required int diaBase,
      Value<String> recorrencia,
      Value<bool> paga,
      Value<DateTime?> dataPagamento,
      Value<double?> valorPago,
      Value<int> diasAntesLembrete,
      Value<String?> transacaoId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ContaTableTableUpdateCompanionBuilder =
    ContaTableCompanion Function({
      Value<String> id,
      Value<String?> remoteId,
      Value<String> descricao,
      Value<String> categoria,
      Value<double> valor,
      Value<DateTime> vencimento,
      Value<int> diaBase,
      Value<String> recorrencia,
      Value<bool> paga,
      Value<DateTime?> dataPagamento,
      Value<double?> valorPago,
      Value<int> diasAntesLembrete,
      Value<String?> transacaoId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ContaTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContaTableTable> {
  $$ContaTableTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaBase => $composableBuilder(
    column: $table.diaBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paga => $composableBuilder(
    column: $table.paga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasAntesLembrete => $composableBuilder(
    column: $table.diasAntesLembrete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContaTableTable> {
  $$ContaTableTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaBase => $composableBuilder(
    column: $table.diaBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paga => $composableBuilder(
    column: $table.paga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasAntesLembrete => $composableBuilder(
    column: $table.diasAntesLembrete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContaTableTable> {
  $$ContaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaBase =>
      $composableBuilder(column: $table.diaBase, builder: (column) => column);

  GeneratedColumn<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paga =>
      $composableBuilder(column: $table.paga, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorPago =>
      $composableBuilder(column: $table.valorPago, builder: (column) => column);

  GeneratedColumn<int> get diasAntesLembrete => $composableBuilder(
    column: $table.diasAntesLembrete,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transacaoId => $composableBuilder(
    column: $table.transacaoId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContaTableTable,
          ContaTableData,
          $$ContaTableTableFilterComposer,
          $$ContaTableTableOrderingComposer,
          $$ContaTableTableAnnotationComposer,
          $$ContaTableTableCreateCompanionBuilder,
          $$ContaTableTableUpdateCompanionBuilder,
          (
            ContaTableData,
            BaseReferences<_$AppDatabase, $ContaTableTable, ContaTableData>,
          ),
          ContaTableData,
          PrefetchHooks Function()
        > {
  $$ContaTableTableTableManager(_$AppDatabase db, $ContaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<DateTime> vencimento = const Value.absent(),
                Value<int> diaBase = const Value.absent(),
                Value<String> recorrencia = const Value.absent(),
                Value<bool> paga = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<double?> valorPago = const Value.absent(),
                Value<int> diasAntesLembrete = const Value.absent(),
                Value<String?> transacaoId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContaTableCompanion(
                id: id,
                remoteId: remoteId,
                descricao: descricao,
                categoria: categoria,
                valor: valor,
                vencimento: vencimento,
                diaBase: diaBase,
                recorrencia: recorrencia,
                paga: paga,
                dataPagamento: dataPagamento,
                valorPago: valorPago,
                diasAntesLembrete: diasAntesLembrete,
                transacaoId: transacaoId,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteId = const Value.absent(),
                required String descricao,
                Value<String> categoria = const Value.absent(),
                required double valor,
                required DateTime vencimento,
                required int diaBase,
                Value<String> recorrencia = const Value.absent(),
                Value<bool> paga = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<double?> valorPago = const Value.absent(),
                Value<int> diasAntesLembrete = const Value.absent(),
                Value<String?> transacaoId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContaTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                descricao: descricao,
                categoria: categoria,
                valor: valor,
                vencimento: vencimento,
                diaBase: diaBase,
                recorrencia: recorrencia,
                paga: paga,
                dataPagamento: dataPagamento,
                valorPago: valorPago,
                diasAntesLembrete: diasAntesLembrete,
                transacaoId: transacaoId,
                syncStatus: syncStatus,
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

typedef $$ContaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContaTableTable,
      ContaTableData,
      $$ContaTableTableFilterComposer,
      $$ContaTableTableOrderingComposer,
      $$ContaTableTableAnnotationComposer,
      $$ContaTableTableCreateCompanionBuilder,
      $$ContaTableTableUpdateCompanionBuilder,
      (
        ContaTableData,
        BaseReferences<_$AppDatabase, $ContaTableTable, ContaTableData>,
      ),
      ContaTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$PerfilBancoTableTableTableManager get perfilBancoTable =>
      $$PerfilBancoTableTableTableManager(_db, _db.perfilBancoTable);
  $$RendaTableTableTableManager get rendaTable =>
      $$RendaTableTableTableManager(_db, _db.rendaTable);
  $$MetaTableTableTableManager get metaTable =>
      $$MetaTableTableTableManager(_db, _db.metaTable);
  $$ParcelamentoTableTableTableManager get parcelamentoTable =>
      $$ParcelamentoTableTableTableManager(_db, _db.parcelamentoTable);
  $$ExtratoLinhasTableTableTableManager get extratoLinhasTable =>
      $$ExtratoLinhasTableTableTableManager(_db, _db.extratoLinhasTable);
  $$ReconciliationMatchesTableTableTableManager
  get reconciliationMatchesTable =>
      $$ReconciliationMatchesTableTableTableManager(
        _db,
        _db.reconciliationMatchesTable,
      );
  $$OrcamentoTableTableTableManager get orcamentoTable =>
      $$OrcamentoTableTableTableManager(_db, _db.orcamentoTable);
  $$ContaTableTableTableManager get contaTable =>
      $$ContaTableTableTableManager(_db, _db.contaTable);
}
