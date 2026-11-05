import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/repositories/cartao_repository.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';

/// Ids estáveis dos lembretes que acompanham um cartão: salvar o cartão de novo
/// atualiza os mesmos lembretes em vez de criar outros.
String idLembreteFechamento(String cartaoId) => 'cartao-$cartaoId-fecha';
String idLembreteVencimento(String cartaoId) => 'cartao-$cartaoId-vence';

/// Cadastra ou edita um cartão e mantém os dois lembretes mensais dele
/// (fechamento e vencimento) em "Meus lembretes". Se o usuário desligou um
/// deles, continua desligado.
class SalvarCartaoUseCase {
  SalvarCartaoUseCase(this._repository, this._lembretes);

  final CartaoRepository _repository;
  final LembreteRepository _lembretes;

  Future<Either<Failure, Unit>> call(Cartao cartao) async {
    if (cartao.nome.trim().isEmpty) {
      return const Left(ValidationFailure('Dê um nome ao cartão.'));
    }
    if (cartao.diaFechamento < 1 || cartao.diaFechamento > 31 || cartao.diaVencimento < 1 || cartao.diaVencimento > 31) {
      return const Left(ValidationFailure('Os dias devem ser de 1 a 31.'));
    }
    if (cartao.limite != null && cartao.limite! < 0) {
      return const Left(ValidationFailure('O limite não pode ser negativo.'));
    }

    // O cartão precisa de id antes de os lembretes referenciarem ele.
    final id = cartao.id.isEmpty ? _novoId() : cartao.id;
    final limpo = Cartao(
      id: id,
      nome: cartao.nome.trim(),
      diaFechamento: cartao.diaFechamento,
      diaVencimento: cartao.diaVencimento,
      limite: cartao.limite,
    );
    final salvo = await _repository.salvarCartao(limpo);
    if (salvo.isLeft()) return salvo;

    final existentes = (await _lembretes.listar()).getOrElse((_) => const []);
    bool ativo(String lembreteId) => existentes.where((l) => l.id == lembreteId).firstOrNull?.ativo ?? true;

    await _lembretes.salvar(LembretePersonalizado(
      id: idLembreteFechamento(id),
      titulo: '${limpo.nome}: fatura fecha',
      tipo: TipoLembrete.faturaFecha,
      dia: limpo.diaFechamento,
      ativo: ativo(idLembreteFechamento(id)),
    ));
    await _lembretes.salvar(LembretePersonalizado(
      id: idLembreteVencimento(id),
      titulo: '${limpo.nome}: fatura vence',
      tipo: TipoLembrete.faturaVence,
      dia: limpo.diaVencimento,
      ativo: ativo(idLembreteVencimento(id)),
    ));
    return const Right(unit);
  }

  static int _contador = 0;

  String _novoId() {
    _contador++;
    return '${DateTime.now().microsecondsSinceEpoch}$_contador';
  }
}
