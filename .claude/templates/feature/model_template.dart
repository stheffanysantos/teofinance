import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teofinance/core/status/sync_status.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';

part 'nome_entidade_model.freezed.dart';
part 'nome_entidade_model.g.dart';

/// Model (DTO) — só serialização e conversão, zero regra de negócio.
@freezed
class NomeEntidadeModel with _$NomeEntidadeModel {
  const factory NomeEntidadeModel({
    String? idRemoto,
    required String descricao,
    required double valor,

    /// Firestore guarda Timestamp; convertido explicitamente (ver fromFirestore/toFirestore).
    required DateTime data,
  }) = _NomeEntidadeModel;

  const NomeEntidadeModel._();

  factory NomeEntidadeModel.fromJson(Map<String, dynamic> json) =>
      _$NomeEntidadeModelFromJson(json);

  factory NomeEntidadeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NomeEntidadeModel(
      idRemoto: doc.id,
      descricao: data['descricao'] as String,
      valor: (data['valor'] as num).toDouble(),
      data: (data['data'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'descricao': descricao,
        'valor': valor,
        'data': Timestamp.fromDate(data),
      };

  /// Conversão manual para a entidade de domínio — nunca gerada automaticamente.
  NomeEntidade toEntity({int? idLocal, SyncStatus syncStatus = SyncStatus.synced}) {
    return NomeEntidade(
      idLocal: idLocal,
      idRemoto: idRemoto,
      descricao: descricao,
      valor: valor,
      data: data,
      syncStatus: syncStatus,
    );
  }

  factory NomeEntidadeModel.fromEntity(NomeEntidade entity) {
    return NomeEntidadeModel(
      idRemoto: entity.idRemoto,
      descricao: entity.descricao,
      valor: entity.valor,
      data: entity.data,
    );
  }
}
