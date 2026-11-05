import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/features/contas/domain/services/planejar_lembrete_extrato.dart';
import 'package:teofinance/features/contas/domain/usecases/reagendar_lembretes_usecase.dart';

class _FakeNotificacoes implements NotificacaoService {
  List<NotificacaoAgendada>? agendadas;
  int cancelamentos = 0;

  @override
  Future<bool> permissaoConcedida() async => true;

  @override
  Future<bool> pedirPermissao() async => true;

  @override
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes) async => agendadas = lembretes;

  @override
  Future<void> cancelarTudo() async => cancelamentos++;

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async {}
}

void main() {
  group('planejarLembretesExtrato', () {
    test('antes do dia escolhido, o primeiro aviso é neste mês e fala do mês anterior', () {
      final lista = planejarLembretesExtrato(agora: DateTime(2026, 11, 2, 10), dia: 5, hora: 9);

      expect(lista.first.quando, DateTime(2026, 11, 5, 9));
      expect(lista.first.corpo, contains('outubro'));
      expect(lista, hasLength(kMesesAgendadosExtrato));
    });

    test('depois do dia escolhido, o primeiro aviso é no mês seguinte', () {
      final lista = planejarLembretesExtrato(agora: DateTime(2026, 11, 6, 10), dia: 5, hora: 9);

      expect(lista.first.quando, DateTime(2026, 12, 5, 9));
      expect(lista.first.corpo, contains('novembro'));
    });

    test('virada de ano: o aviso de janeiro fala de dezembro', () {
      final lista = planejarLembretesExtrato(agora: DateTime(2026, 12, 20), dia: 4, hora: 9);

      expect(lista.first.quando, DateTime(2027, 1, 4, 9));
      expect(lista.first.corpo, contains('dezembro'));
    });

    test('dia fora de 1–28 é ajustado e os ids são distintos', () {
      final lista = planejarLembretesExtrato(agora: DateTime(2026, 11, 1), dia: 31, hora: 9);

      expect(lista.first.quando.day, 28);
      expect(lista.map((l) => l.id).toSet(), hasLength(lista.length));
    });
  });

  group('ReagendarLembretesUseCase com extrato', () {
    final agora = DateTime(2026, 11, 2, 10);

    test('só o extrato ligado agenda os avisos do extrato', () async {
      final fake = _FakeNotificacoes();
      final n = await ReagendarLembretesUseCase(fake, agora: () => agora)(
        contas: const [],
        ativo: false,
        hora: 9,
        extratoAtivo: true,
        extratoDia: 5,
      );

      expect(n, kMesesAgendadosExtrato);
      expect(fake.agendadas!.first.titulo, 'Hora de enviar o extrato');
    });

    test('tudo desligado cancela os agendamentos', () async {
      final fake = _FakeNotificacoes();
      final n = await ReagendarLembretesUseCase(fake, agora: () => agora)(
        contas: const [],
        ativo: false,
        hora: 9,
      );

      expect(n, 0);
      expect(fake.cancelamentos, 1);
    });
  });
}
