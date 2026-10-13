import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/perfil_banco.dart';

/// Única classe da feature que fala com a tabela `drift` de Perfis de Banco
/// (ver `.claude/rules/architecture.md`).
class PerfilBancoLocalDataSource {
  PerfilBancoLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<List<PerfilBanco>> listarTodos() async {
    final linhas = await _db.select(_db.perfilBancoTable).get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<PerfilBanco> salvar(PerfilBanco perfil) async {
    final id = perfil.id.isEmpty ? _uuid.v4() : perfil.id;

    await _db
        .into(_db.perfilBancoTable)
        .insertOnConflictUpdate(
          PerfilBancoTableCompanion.insert(
            id: id,
            nomeBanco: perfil.nomeBanco,
            delimitador: perfil.delimitador,
            codificacaoLatin1: Value(perfil.codificacaoLatin1),
            temCabecalho: Value(perfil.temCabecalho),
            formatoData: perfil.formatoData,
            separadorDecimalVirgula: Value(perfil.separadorDecimalVirgula),
            mapeamentoColunasJson: jsonEncode(
              perfil.mapeamentoColunas.map((k, v) => MapEntry(k.toString(), v.name)),
            ),
            assinaturaCabecalhoJson: jsonEncode(perfil.assinaturaCabecalho),
          ),
        );

    return PerfilBanco(
      id: id,
      nomeBanco: perfil.nomeBanco,
      delimitador: perfil.delimitador,
      codificacaoLatin1: perfil.codificacaoLatin1,
      temCabecalho: perfil.temCabecalho,
      formatoData: perfil.formatoData,
      separadorDecimalVirgula: perfil.separadorDecimalVirgula,
      mapeamentoColunas: perfil.mapeamentoColunas,
      assinaturaCabecalho: perfil.assinaturaCabecalho,
      remoteId: perfil.remoteId,
    );
  }

  Future<void> excluir(String id) {
    return (_db.delete(_db.perfilBancoTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<PerfilBanco>> listarPendentes() async {
    final linhas = await (_db.select(_db.perfilBancoTable)
          ..where((t) => t.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              t.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.perfilBancoTable)..where((t) => t.id.equals(id))).write(
      PerfilBancoTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  Future<void> aplicarRemoto(PerfilBanco perfil) async {
    final existente = perfil.remoteId == null
        ? null
        : await (_db.select(_db.perfilBancoTable)..where((t) => t.remoteId.equals(perfil.remoteId!)))
            .getSingleOrNull();

    if (existente != null && existente.syncStatus != SyncStatus.synced) {
      return;
    }

    final id = existente?.id ?? _uuid.v4();
    await _db.into(_db.perfilBancoTable).insertOnConflictUpdate(
          PerfilBancoTableCompanion.insert(
            id: id,
            remoteId: Value(perfil.remoteId),
            nomeBanco: perfil.nomeBanco,
            delimitador: perfil.delimitador,
            codificacaoLatin1: Value(perfil.codificacaoLatin1),
            temCabecalho: Value(perfil.temCabecalho),
            formatoData: perfil.formatoData,
            separadorDecimalVirgula: Value(perfil.separadorDecimalVirgula),
            mapeamentoColunasJson: jsonEncode(
              perfil.mapeamentoColunas.map((k, v) => MapEntry(k.toString(), v.name)),
            ),
            assinaturaCabecalhoJson: jsonEncode(perfil.assinaturaCabecalho),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  PerfilBanco _paraEntidade(PerfilBancoTableData linha) {
    final mapaJson = jsonDecode(linha.mapeamentoColunasJson) as Map<String, dynamic>;
    final mapeamento = mapaJson.map(
      (chave, valor) => MapEntry(int.parse(chave), CampoColuna.values.byName(valor as String)),
    );
    final assinatura = (jsonDecode(linha.assinaturaCabecalhoJson) as List).cast<String>();

    return PerfilBanco(
      id: linha.id,
      nomeBanco: linha.nomeBanco,
      delimitador: linha.delimitador,
      codificacaoLatin1: linha.codificacaoLatin1,
      temCabecalho: linha.temCabecalho,
      formatoData: linha.formatoData,
      separadorDecimalVirgula: linha.separadorDecimalVirgula,
      mapeamentoColunas: mapeamento,
      assinaturaCabecalho: assinatura,
      remoteId: linha.remoteId,
      syncStatus: linha.syncStatus,
    );
  }
}
