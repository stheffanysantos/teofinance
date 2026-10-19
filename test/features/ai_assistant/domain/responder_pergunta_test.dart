import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/construir_contexto.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/ai_assistant/domain/usecases/responder_pergunta_usecase.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/meta/domain/repositories/meta_repository.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

class _FakeTransacoes implements TransacaoRepository {
  _FakeTransacoes(this.dados);
  final List<Transacao> dados;

  @override
  Stream<List<Transacao>> observarTodas() => Stream.value(dados);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMetas implements MetaRepository {
  @override
  Stream<List<Meta>> observarTodas() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrcamentos implements OrcamentoRepository {
  @override
  Stream<List<Orcamento>> observarTodos() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MotorEspiao implements MotorResposta {
  ContextoFinanceiro? contextoRecebido;
  int chamadas = 0;

  @override
  Future<Either<Failure, String>> responder({
    required String pergunta,
    required ContextoFinanceiro contexto,
  }) async {
    chamadas++;
    contextoRecebido = contexto;
    return const Right('ok');
  }
}

Transacao _t(double valor, {String categoria = 'Mercado', DateTime? data, double? minhaParte}) => Transacao(
      id: '$valor$categoria${data ?? ''}',
      descricao: 'x',
      categoria: categoria,
      valor: valor,
      data: data ?? DateTime(2026, 10, 5),
      minhaParte: minhaParte,
    );

final _mes = DateTime(2026, 10, 15);

void main() {
  group('construirContexto', () {
    test('agrega só o mês pedido, separando receitas e despesas', () {
      final c = construirContexto(
        transacoes: [
          _t(5000, categoria: 'Renda'),
          _t(-200),
          _t(-100, categoria: 'Lazer'),
          _t(-999, data: DateTime(2026, 9, 30)),
        ],
        limites: const [],
        metas: const [],
        mes: _mes,
      );

      expect(c.receitas, 5000);
      expect(c.despesas, 300);
      expect(c.gastoPorCategoria, {'Mercado': 200, 'Lazer': 100});
      expect(c.saldo, 4700);
      expect(c.maiorCategoria!.key, 'Mercado');
    });

    test('compra dividida conta só a parte do usuário', () {
      final c = construirContexto(
        transacoes: [_t(-120, minhaParte: 40)],
        limites: const [],
        metas: const [],
        mes: _mes,
      );

      expect(c.despesas, 40);
    });

    test('despesa sem categoria vai para "Sem categoria"', () {
      final c = construirContexto(
        transacoes: [_t(-10, categoria: '  ')],
        limites: const [],
        metas: const [],
        mes: _mes,
      );

      expect(c.gastoPorCategoria.keys, ['Sem categoria']);
    });
  });

  group('ResponderPerguntaUseCase', () {
    late _MotorEspiao motor;

    ResponderPerguntaUseCase criar(List<Transacao> transacoes) => ResponderPerguntaUseCase(
          transacoes: _FakeTransacoes(transacoes),
          metas: _FakeMetas(),
          orcamentos: _FakeOrcamentos(),
          motor: motor,
          agora: () => _mes,
        );

    setUp(() => motor = _MotorEspiao());

    test('entrega ao motor o agregado do mês, não a lista de transações', () async {
      final r = await criar([_t(-50), _t(-30, data: DateTime(2026, 8, 1))])('Resumo do mês');

      expect(r.getOrElse((_) => ''), 'ok');
      expect(motor.contextoRecebido!.despesas, 50);
    });

    test('pergunta vazia é recusada sem consultar o motor', () async {
      final r = await criar(const [])('   ');

      expect(r.swap().getOrElse((_) => throw StateError('esperava Left')), isA<ValidationFailure>());
      expect(motor.chamadas, 0);
    });
  });
}
