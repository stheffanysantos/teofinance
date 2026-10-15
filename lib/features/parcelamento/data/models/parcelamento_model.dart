import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../parcelamento/domain/entities/parcelamento.dart';

/// Model para serialização/desserialização de Parcelamento
class ParcelamentoModel extends Parcelamento {
  const ParcelamentoModel({
    required super.id,
    super.remoteId,
    required super.transacaoOriginalId,
    required super.totalOriginal,
    required super.numeroParcelas,
    required super.dataPrimeiraParc,
    required super.updatedAt,
  });

  factory ParcelamentoModel.fromDomain(Parcelamento parcelamento) {
    return ParcelamentoModel(
      id: parcelamento.id,
      remoteId: parcelamento.remoteId,
      transacaoOriginalId: parcelamento.transacaoOriginalId,
      totalOriginal: parcelamento.totalOriginal,
      numeroParcelas: parcelamento.numeroParcelas,
      dataPrimeiraParc: parcelamento.dataPrimeiraParc,
      updatedAt: parcelamento.updatedAt,
    );
  }

  factory ParcelamentoModel.fromDriftData(ParcelamentoTableData data) {
    return ParcelamentoModel(
      id: data.id,
      remoteId: data.remoteId,
      transacaoOriginalId: data.transacaoOriginalId,
      totalOriginal: data.totalOriginal,
      numeroParcelas: data.numeroParcelas,
      dataPrimeiraParc: data.dataPrimeiraParc,
      updatedAt: data.updatedAt,
    );
  }

  ParcelamentoTableCompanion toDriftCompanion() {
    return ParcelamentoTableCompanion(
      id: Value(id),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
      transacaoOriginalId: Value(transacaoOriginalId),
      totalOriginal: Value(totalOriginal),
      numeroParcelas: Value(numeroParcelas),
      dataPrimeiraParc: Value(dataPrimeiraParc),
      updatedAt: Value(updatedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'remoteId': remoteId,
        'transacaoOriginalId': transacaoOriginalId,
        'totalOriginal': totalOriginal,
        'numeroParcelas': numeroParcelas,
        'dataPrimeiraParc': dataPrimeiraParc.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ParcelamentoModel.fromJson(Map<String, dynamic> json) {
    return ParcelamentoModel(
      id: json['id'] as String,
      remoteId: json['remoteId'] as String?,
      transacaoOriginalId: json['transacaoOriginalId'] as String,
      totalOriginal: json['totalOriginal'] as double,
      numeroParcelas: json['numeroParcelas'] as int,
      dataPrimeiraParc: DateTime.parse(json['dataPrimeiraParc'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
