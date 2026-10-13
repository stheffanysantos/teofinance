import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teofinance/core/status/sync_status.dart';

part 'nome_entidade.freezed.dart';

/// Entidade de domínio pura — SEM Flutter/Riverpod/cloud_firestore/drift.
/// Renomeie `NomeEntidade`/`nomeEntidade` para o conceito real (ex.: Transacao, Meta).
@freezed
class NomeEntidade with _$NomeEntidade {
  const factory NomeEntidade({
    /// ID local (drift), nulo antes da primeira persistência.
    int? idLocal,

    /// ID do documento no Firestore, nulo até a primeira sincronização bem-sucedida.
    String? idRemoto,

    required String descricao,
    required double valor,
    required DateTime data,

    /// Estado de sincronização — ver .claude/rules/architecture.md (regra de sincronização).
    @Default(SyncStatus.pendingCreate) SyncStatus syncStatus,
  }) = _NomeEntidade;

  const NomeEntidade._();

  /// Exemplo de invariante de negócio pura, sem I/O.
  bool get valorValido => valor != 0;
}
