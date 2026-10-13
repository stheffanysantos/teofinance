import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../sync/sync_status.dart';

part 'app_database.g.dart';

/// Cache local das transações — fonte de verdade quando offline, sincronizada
/// com o Firestore pela feature `sync/` (ver `.claude/agents/firebase-sync-engineer.md`).
/// `remoteId` é o id do documento no Firestore; nulo enquanto a transação
/// ainda não foi enviada.
class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get value => real()();
  DateTimeColumn get occurredAt => dateTime()();
  BoolColumn get needsCategory => boolean().withDefault(const Constant(false))();
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
        Constant(SyncStatus.pendingCreate.index),
      )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Perfis de Banco salvos pelo usuário — mapeamento de colunas reaproveitado
/// entre importações (ver `.claude/docs/IMPORT_FLOW.md`). `mapeamentoColunasJson`
/// e `assinaturaCabecalhoJson` guardam, respectivamente, `Map<int,CampoColuna>`
/// e `List<String>` serializados.
class PerfilBancoTable extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get nomeBanco => text()();
  TextColumn get delimitador => text()();
  BoolColumn get codificacaoLatin1 => boolean().withDefault(const Constant(false))();
  BoolColumn get temCabecalho => boolean().withDefault(const Constant(true))();
  TextColumn get formatoData => text()();
  BoolColumn get separadorDecimalVirgula => boolean().withDefault(const Constant(true))();
  TextColumn get mapeamentoColunasJson => text()();
  TextColumn get assinaturaCabecalhoJson => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
        Constant(SyncStatus.pendingCreate.index),
      )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rendas fixas (com recorrência) e variáveis cadastradas pelo usuário —
/// ver `.claude/memory/domain-glossary.md` (distinta de `TransactionsTable`,
/// que registra lançamentos já ocorridos).
class RendaTable extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get descricao => text()();
  RealColumn get valor => real()();

  /// 'fixa' ou 'variavel'.
  TextColumn get tipo => text()();

  /// 'semanal', 'mensal', 'anual' ou nulo (renda variável).
  TextColumn get recorrencia => text().nullable()();
  DateTimeColumn get dataRecebimento => dateTime()();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
        Constant(SyncStatus.pendingCreate.index),
      )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Metas de Investimento — ver `.claude/memory/domain-glossary.md`.
class MetaTable extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get nome => text()();
  RealColumn get valorAtual => real().withDefault(const Constant(0))();
  RealColumn get valorAlvo => real()();
  DateTimeColumn get prazo => dateTime()();
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
        Constant(SyncStatus.pendingCreate.index),
      )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TransactionsTable, PerfilBancoTable, RendaTable, MetaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(rendaTable);
          }
          if (from < 3) {
            await m.createTable(metaTable);
          }
          if (from < 4) {
            // Troca `pendingSync` (bool) por `syncStatus` (enum) — ver
            // `.claude/docs/DATABASE.md`. Pré-lançamento, sem usuários reais
            // ainda, então recriar as tabelas é seguro e mais simples que
            // uma migração célula a célula.
            await m.deleteTable(transactionsTable.actualTableName);
            await m.createTable(transactionsTable);
            await m.deleteTable(perfilBancoTable.actualTableName);
            await m.createTable(perfilBancoTable);
            await m.deleteTable(rendaTable.actualTableName);
            await m.createTable(rendaTable);
            await m.deleteTable(metaTable.actualTableName);
            await m.createTable(metaTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'teofinance.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
