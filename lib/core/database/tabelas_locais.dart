/// Tabelas locais criadas por SQL direto (sem classes geradas pelo drift):
/// categorias personalizadas, investimentos manuais e lembretes personalizados.
/// Sincronizam com o Firestore pelo `SyncEngine`, usando a coluna `sync_status`
/// (ver [kSyncSincronizado], [kSyncPendente] e [kSyncPendenteExclusao]).
///
/// Cada comando é idempotente (`IF NOT EXISTS`) e roda na criação do banco e na
/// migração para a versão 12.
const kSyncSincronizado = 0;
const kSyncPendente = 1;

/// Marca de exclusão: a linha some das listas e o `SyncEngine` apaga o
/// documento remoto antes de remover a linha de vez.
const kSyncPendenteExclusao = 2;

const kCriarTabelasLocais = <String>[
  'CREATE TABLE IF NOT EXISTS categorias_personalizadas ('
      'nome TEXT NOT NULL PRIMARY KEY, '
      'sync_status INTEGER NOT NULL DEFAULT 1)',
  'CREATE TABLE IF NOT EXISTS investimentos_manuais ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'nome TEXT NOT NULL, '
      'tipo TEXT NOT NULL, '
      'valor_investido REAL NOT NULL, '
      'valor_atual REAL NOT NULL, '
      'data_aplicacao INTEGER NOT NULL, '
      "observacao TEXT NOT NULL DEFAULT '', "
      'sync_status INTEGER NOT NULL DEFAULT 1)',
  'CREATE TABLE IF NOT EXISTS lembretes_personalizados ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'titulo TEXT NOT NULL, '
      'tipo TEXT NOT NULL, '
      'dia INTEGER NOT NULL, '
      'ativo INTEGER NOT NULL DEFAULT 1, '
      'sync_status INTEGER NOT NULL DEFAULT 1)',
  'CREATE TABLE IF NOT EXISTS cartoes ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'nome TEXT NOT NULL, '
      'dia_fechamento INTEGER NOT NULL, '
      'dia_vencimento INTEGER NOT NULL, '
      'limite REAL, '
      'sync_status INTEGER NOT NULL DEFAULT 1)',
  // id = "<cartaoId>|<ano>-<mes>" (mes = mês do vencimento da fatura).
  'CREATE TABLE IF NOT EXISTS faturas_pagas ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'cartao_id TEXT NOT NULL, '
      'ano INTEGER NOT NULL, '
      'mes INTEGER NOT NULL, '
      'valor REAL NOT NULL, '
      'data_pagamento INTEGER NOT NULL, '
      'sync_status INTEGER NOT NULL DEFAULT 1)',
];

/// Tabelas locais que guardam valores financeiros: zeradas junto dos demais
/// dados financeiros.
const kTabelasLocaisFinanceiras = <String>['investimentos_manuais', 'faturas_pagas'];

/// Todas as tabelas locais (exportação e exclusão completa da conta).
const kTodasTabelasLocais = <String>[
  'categorias_personalizadas',
  'investimentos_manuais',
  'lembretes_personalizados',
  'cartoes',
  'faturas_pagas',
];
