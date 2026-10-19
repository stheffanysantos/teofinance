import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/planejar_lembretes.dart';
import 'package:teofinance/features/contas/domain/usecases/reagendar_lembretes_usecase.dart';

ContaAPagar _conta(String id, DateTime venc, {int antes = 1, bool paga = false, double valor = 100}) => ContaAPagar(
      id: id,
      descricao: 'Conta $id',
      valor: valor,
      vencimento: venc,
      diaBase: venc.day,
      diasAntesLembrete: antes,
      paga: paga,
    );

final _agora = DateTime(2026, 10, 19, 12);

class _FakeNotificacoes implements NotificacaoService {
  bool permissao = true;
  bool falhar = false;
  List<NotificacaoAgendada>? agendadas;
  int cancelamentos = 0;

  @override
  Future<bool> permissaoConcedida() async => permissao;

  @override
  Future<bool> pedirPermissao() async => permissao;

  @override
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes) async {
    if (falhar) throw StateError('plugin quebrou');
    agendadas = lembretes;
  }

  @override
  Future<void> cancelarTudo() async => cancelamentos++;

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async {}
}

void main() {
  group('planejarLembretes', () {
    test('agenda um aviso antes e outro no dia, na hora configurada', () {
      final l = planejarLembretes([_conta('a', DateTime(2026, 10, 25), antes: 2)], agora: _agora, hora: 9);

      expect(l.map((x) => x.quando), [DateTime(2026, 10, 23, 9), DateTime(2026, 10, 25, 9)]);
      expect(l[0].titulo, 'Conta a vence em 2 dias');
      expect(l[1].titulo, 'Conta a vence hoje');
      expect(l[0].corpo, contains('25/10'));
      expect(l[0].corpo, contains('R\$ 100,00'));
    });

    test('1 dia antes diz "amanhã"', () {
      final l = planejarLembretes([_conta('a', DateTime(2026, 10, 25), antes: 1)], agora: _agora, hora: 9);

      expect(l.first.titulo, 'Conta a vence amanhã');
    });

    test('lembrar "no dia" gera só um aviso', () {
      final l = planejarLembretes([_conta('a', DateTime(2026, 10, 25), antes: 0)], agora: _agora, hora: 9);

      expect(l, hasLength(1));
      expect(l.single.quando, DateTime(2026, 10, 25, 9));
    });

    test('contas pagas não geram aviso', () {
      expect(planejarLembretes([_conta('a', DateTime(2026, 10, 25), paga: true)], agora: _agora, hora: 9), isEmpty);
    });

    test('horários que já passaram ficam de fora; os futuros do mesmo dia entram', () {
      // Vence hoje (19/10): o aviso das 9h já passou (agora = 12h) e o de véspera também.
      expect(planejarLembretes([_conta('a', DateTime(2026, 10, 19))], agora: _agora, hora: 9), isEmpty);
      // Com o aviso às 18h ainda dá tempo.
      final l = planejarLembretes([_conta('a', DateTime(2026, 10, 19))], agora: _agora, hora: 18);
      expect(l.single.quando, DateTime(2026, 10, 19, 18));
    });

    test('conta atrasada não gera aviso novo', () {
      expect(planejarLembretes([_conta('a', DateTime(2026, 10, 10))], agora: _agora, hora: 9), isEmpty);
    });

    test('o aviso de véspera atravessa a virada de mês', () {
      final l = planejarLembretes([_conta('a', DateTime(2026, 11, 1), antes: 3)], agora: _agora, hora: 9);

      expect(l.first.quando, DateTime(2026, 10, 29, 9));
    });

    test('sai ordenado por horário', () {
      final l = planejarLembretes(
        [_conta('b', DateTime(2026, 11, 20)), _conta('a', DateTime(2026, 10, 25))],
        agora: _agora,
        hora: 9,
      );

      expect(l.map((x) => x.quando).toList(), [...l.map((x) => x.quando)]..sort());
    });

    test('respeita o limite de notificações agendadas', () {
      final contas = [for (var i = 0; i < 100; i++) _conta('c$i', DateTime(2026, 11, 1).add(Duration(days: i)))];

      expect(planejarLembretes(contas, agora: _agora, hora: 9), hasLength(kMaxLembretesAgendados));
    });
  });

  group('idDoLembrete', () {
    test('é estável, positivo e diferente entre aviso de véspera e do dia', () {
      expect(idDoLembrete('abc', noDia: true), idDoLembrete('abc', noDia: true));
      expect(idDoLembrete('abc', noDia: true), isNot(idDoLembrete('abc', noDia: false)));
      expect(idDoLembrete('abc', noDia: true), greaterThanOrEqualTo(0));
      expect(idDoLembrete('abc', noDia: true), isNot(idDoLembrete('abd', noDia: true)));
    });

    test('valor conhecido não muda entre versões (reagendar depende disso)', () {
      expect(idDoLembrete('conta-1', noDia: true), 604307716);
    });

    test('ids de contas diferentes não colidem em uma amostra grande', () {
      final ids = {for (var i = 0; i < 5000; i++) idDoLembrete('uuid-$i', noDia: true)};

      expect(ids.length, 5000);
    });
  });

  group('ReagendarLembretesUseCase', () {
    late _FakeNotificacoes servico;
    late ReagendarLembretesUseCase usecase;

    setUp(() {
      servico = _FakeNotificacoes();
      usecase = ReagendarLembretesUseCase(servico, agora: () => _agora);
    });

    test('agenda os lembretes e devolve quantos ficaram', () async {
      final n = await usecase(contas: [_conta('a', DateTime(2026, 10, 25))], ativo: true, hora: 9);

      expect(n, 2);
      expect(servico.agendadas, hasLength(2));
    });

    test('desligado cancela tudo e não agenda', () async {
      final n = await usecase(contas: [_conta('a', DateTime(2026, 10, 25))], ativo: false, hora: 9);

      expect(n, 0);
      expect(servico.cancelamentos, 1);
      expect(servico.agendadas, isNull);
    });

    test('sem permissão do sistema cancela tudo e não agenda', () async {
      servico.permissao = false;

      final n = await usecase(contas: [_conta('a', DateTime(2026, 10, 25))], ativo: true, hora: 9);

      expect(n, 0);
      expect(servico.agendadas, isNull);
    });

    test('quando a última conta é paga, os lembretes antigos somem', () async {
      await usecase(contas: [_conta('a', DateTime(2026, 10, 25))], ativo: true, hora: 9);

      await usecase(contas: [_conta('a', DateTime(2026, 10, 25), paga: true)], ativo: true, hora: 9);

      expect(servico.agendadas, isEmpty);
    });

    test('chamar duas vezes com os mesmos dados dá o mesmo resultado', () async {
      final contas = [_conta('a', DateTime(2026, 10, 25))];

      await usecase(contas: contas, ativo: true, hora: 9);
      final primeira = servico.agendadas!.map((x) => (x.id, x.quando)).toList();
      await usecase(contas: contas, ativo: true, hora: 9);

      expect(servico.agendadas!.map((x) => (x.id, x.quando)).toList(), primeira);
    });

    test('falha do plugin nunca vira exceção', () async {
      servico.falhar = true;

      final n = await usecase(contas: [_conta('a', DateTime(2026, 10, 25))], ativo: true, hora: 9);

      expect(n, 0);
    });
  });
}
