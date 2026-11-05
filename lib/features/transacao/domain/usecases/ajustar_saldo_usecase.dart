import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Faz o "Saldo total" do app bater com o saldo real da conta. Em vez de um
/// campo à parte, grava (ou atualiza) uma única transação de categoria
/// [kCategoriaAjusteSaldo], datada no início do histórico — assim ela sincroniza
/// como qualquer transação e o saldo de meses anteriores também fica coerente.
class AjustarSaldoUseCase {
  AjustarSaldoUseCase(this._repository, {DateTime Function() agora = DateTime.now}) : _agora = agora;

  final TransacaoRepository _repository;
  final DateTime Function() _agora;

  /// [saldoReal] é quanto há na conta hoje.
  Future<Either<Failure, Unit>> call(double saldoReal) async {
    final todas = await _repository.observarTodas().first;
    final existente = todas.where((t) => t.categoria == kCategoriaAjusteSaldo).firstOrNull;

    final saldoAtual = todas.fold<double>(0, (a, t) => a + t.valorNoSaldo);
    final ajuste = double.parse(((existente?.valor ?? 0) + (saldoReal - saldoAtual)).toStringAsFixed(2));

    if (ajuste == 0) {
      return existente == null ? const Right(unit) : _repository.excluir(existente.id);
    }

    final data = _inicioDoHistorico(todas.where((t) => t.id != existente?.id).toList());
    if (existente == null) {
      final r = await _repository.criar(
        descricao: 'Ajuste de saldo',
        valor: ajuste,
        data: data,
        categoria: kCategoriaAjusteSaldo,
      );
      return r.map((_) => unit);
    }
    return _repository.editar(
      id: existente.id,
      descricao: existente.descricao,
      valor: ajuste,
      data: data,
      categoria: kCategoriaAjusteSaldo,
    );
  }

  /// Dia da transação mais antiga (o ajuste vale desde o começo); sem histórico, hoje.
  DateTime _inicioDoHistorico(List<Transacao> outras) {
    if (outras.isEmpty) {
      final h = _agora();
      return DateTime(h.year, h.month, h.day);
    }
    final menor = outras.map((t) => t.data).reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(menor.year, menor.month, menor.day);
  }
}
