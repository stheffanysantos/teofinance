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

  /// Parcelamento: campos adicionados na v5 (Sprint 02)
  /// FK → ParcelamentoTable (nulo se não é parcela)
  TextColumn get parcelamentoId => text().nullable()();
  /// Número da parcela: 1, 2, 3... (nulo se não é parcela)
  IntColumn get numeroParcela => integer().nullable()();
  /// Valor da parcela individual (nulo se não é parcela)
  RealColumn get valorParcela => real().nullable()();
  /// true se é transação-filha de um parcelamento, false caso contrário
  BoolColumn get ehParcela => boolean().withDefault(const Constant(false))();
  /// Status da parcela: 'pendente' | 'pago' | 'atrasado' (nulo se não é parcela)
  TextColumn get statusParcela => text().nullable()();

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

/// Parcelamentos de compras de cartão — ver `.claude/plans/Sprint02-Parcelamento.md`.
/// Quando um usuário compra algo em 12x, cria 1 registro aqui (a "mãe")
/// e 12 registros filhos em `TransactionsTable` com `parcelamentoId` apontando para este.
class ParcelamentoTable extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get transacaoOriginalId => text()();  // FK → TransactionsTable
  RealColumn get totalOriginal => real()();        // R$3000
  IntColumn get numeroParcelas => integer()();     // 12
  DateTimeColumn get dataPrimeiraParc => dateTime()();
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
        Constant(SyncStatus.pendingCreate.index),
      )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Linhas de extrato importadas — intermediário entre importação e reconciliação.
/// Cada linha representa um movimento bancário do extrato CSV/OFX.
class ExtratoLinhasTable extends Table {
  TextColumn get id => text()();
  TextColumn get importId => text()();           // FK para saber qual importação
  TextColumn get descricao => text()();          // "SUPERMERCADO X 123"
  RealColumn get valor => real()();
  DateTimeColumn get data => dateTime()();
  TextColumn get tipo => text()();               // 'D' (débito) | 'C' (crédito)
  TextColumn get nomeBancoOriginal => text()(); // Como veio do banco
  DateTimeColumn get importadoEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Matches entre transações do usuário e linhas do extrato — resultado da reconciliação.
/// Quando faz matching, cria registro aqui linkando a transação à linha do extrato.
class ReconciliationMatchesTable extends Table {
  TextColumn get id => text()();
  TextColumn get transacaoId => text().nullable()(); // FK → TransactionsTable (nulo se orphan)
  TextColumn get linhaExtratoId => text()();        // FK → ExtratoLinhasTable
  DateTimeColumn get dataReconciliacao => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text()();                // 'auto_matched' | 'manual_matched' | 'unmatched' | 'orphan'
  RealColumn get confidence => real()();            // 0.0–1.0 (algoritmo de matching)

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  TransactionsTable,
  PerfilBancoTable,
  RendaTable,
  MetaTable,
  ParcelamentoTable,
  ExtratoLinhasTable,
  ReconciliationMatchesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
          if (from < 5) {
            // Adiciona suporte a parcelamento de cartão:
            // - Nova tabela ParcelamentoTable
            // - Novos campos em TransactionsTable
            await m.createTable(parcelamentoTable);
            await m.addColumn(transactionsTable, transactionsTable.parcelamentoId);
            await m.addColumn(transactionsTable, transactionsTable.numeroParcela);
            await m.addColumn(transactionsTable, transactionsTable.valorParcela);
            await m.addColumn(transactionsTable, transactionsTable.ehParcela);
            await m.addColumn(transactionsTable, transactionsTable.statusParcela);
          }
          if (from < 6) {
            // Adiciona suporte a reconciliação (Sprint 03):
            // - Nova tabela ExtratoLinhasTable (linhas do extrato)
            // - Nova tabela ReconciliationMatchesTable (matches entre transações e extrato)
            await m.createTable(extratoLinhasTable);
            await m.createTable(reconciliationMatchesTable);
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
