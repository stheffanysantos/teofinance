import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/demo/dados_demo.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/services/construir_contexto.dart';
import 'package:teofinance/features/ai_assistant/domain/services/montar_prompt.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/meta/data/datasources/meta_local_datasource.dart';
import 'package:teofinance/features/reconciliation/data/datasources/reconciliation_local_data_source.dart';
import 'package:teofinance/features/renda/data/datasources/renda_local_datasource.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('os dados da demonstração batem entre as telas', () async {
    await semearDadosDemo(db);
    await semearDadosDemo(db); // idempotente: não duplica

    final transacoes = await TransacaoLocalDataSource(db).observarTodas().first;
    final cartoes = await CartaoLocalDataSource(db).listarCartoes();
    final pagamentos = await CartaoLocalDataSource(db).listarPagamentos();
    final contas = await ContaLocalDataSource(db).observarTodas().first;
    final rendas = await RendaLocalDataSource(db).observarTodas().first;
    final invest = await InvestimentoLocalDataSource(db).listar();
    final metas = await MetaLocalDataSource(db).observarTodas().first;
    final extrato = await ReconciliationLocalDataSourceImpl(db).obterTodasAsLinhas();

    expect(cartoes, hasLength(2));
    expect(transacoes.length, greaterThan(60));
    expect(rendas, isNotEmpty);
    expect(invest, hasLength(6));
    expect(extrato, isNotEmpty);

    // Conta paga = uma despesa de mesmo valor e data.
    final pagas = contas.where((c) => c.paga);
    expect(pagas, isNotEmpty);
    for (final c in pagas) {
      final casa = transacoes.where((t) => t.descricao == c.descricao && t.valor == -(c.valorPago ?? c.valor));
      expect(casa, isNotEmpty, reason: 'sem despesa para ${c.descricao}');
    }
    expect(contas.where((c) => !c.paga), isNotEmpty);

    // Receita cadastrada = entrada no saldo.
    for (final r in rendas) {
      expect(transacoes.any((t) => t.descricao == r.descricao && t.valor == r.valor), isTrue, reason: r.descricao);
    }

    // Reserva de emergência = Tesouro Selic + poupança.
    final reserva = metas.firstWhere((m) => m.nome == 'Reserva de emergência');
    final soma = invest
        .where((i) => i.nome.startsWith('Tesouro') || i.nome == 'Poupança')
        .fold<double>(0, (a, i) => a + i.valorAtual);
    expect(reserva.valorAtual, closeTo(soma, 0.005));

    // Faturas: toda compra no cartão cai numa fatura, e há pagas e em aberto.
    for (final c in cartoes) {
      final faturas = resumirFaturas(cartao: c, transacoes: transacoes, pagamentos: pagamentos);
      expect(faturas, isNotEmpty);
      for (final f in faturas.where((f) => !f.emAberto)) {
        final pago = pagamentos.firstWhere((p) => p.cartaoId == c.id && p.ano == f.ano && p.mes == f.mes);
        expect(pago.valor, closeTo(f.total, 0.01));
      }
    }
    expect(pagamentos, isNotEmpty);

    // Reembolsos: há pendentes e já pagos.
    expect(transacoes.where((t) => t.ehDividida && t.aReceber > 0), isNotEmpty);
    expect(transacoes.where((t) => t.ehDividida && t.aReceber == 0), isNotEmpty);
  });

  test('o assistente enxerga os dados da demonstração e responde com eles', () async {
    await semearDadosDemo(db);
    final contexto = construirContexto(
      mes: DateTime.now(),
      limites: const [],
      metas: await MetaLocalDataSource(db).observarTodas().first,
      transacoes: await TransacaoLocalDataSource(db).observarTodas().first,
      cartoes: await CartaoLocalDataSource(db).listarCartoes(),
      pagamentos: await CartaoLocalDataSource(db).listarPagamentos(),
      contas: await ContaLocalDataSource(db).observarTodas().first,
      investimentos: await InvestimentoLocalDataSource(db).listar(),
    );

    expect(contexto.cartoes, hasLength(2));
    expect(contexto.reembolsos, isNotEmpty);
    expect(contexto.contasAPagar, isNotEmpty);
    expect(contexto.investimentos, hasLength(6));
    expect(contexto.historico, isNotEmpty);

    const motor = MotorRespostaPorRegras();
    for (final q in [
      'quanto minha mãe me deve?',
      'como estão as faturas dos cartões?',
      'quais contas vencem?',
      'como estão meus investimentos?',
      'gastei mais que no mês passado?',
    ]) {
      final r = (await motor.responder(pergunta: q, contexto: contexto)).getOrElse((_) => '');
      // ignore: avoid_print
      print('P: $q -> R: $r');
      expect(r, isNotEmpty);
    }
    // ignore: avoid_print
    print(montarPrompt(pergunta: 'oi', contexto: contexto).mensagem);
  });
}
