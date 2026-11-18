import 'package:drift/drift.dart' show Value;
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/meta/data/datasources/meta_local_datasource.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_local_data_source.dart';
import 'package:teofinance/features/parcelamento/data/repositories/parcelamento_repository_impl.dart';
import 'package:teofinance/features/reconciliation/data/datasources/reconciliation_local_data_source.dart';
import 'package:teofinance/features/renda/data/datasources/renda_local_datasource.dart';
import 'package:teofinance/features/renda/domain/entities/renda.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

double _centavos(double v) => (v * 100).roundToDouble() / 100;

/// Preenche o banco local com dados fictícios, só se ele estiver vazio.
///
/// Tudo nasce de uma única lista de lançamentos, então os números batem entre as
/// telas: conta paga = despesa de mesmo valor e data; salário = receita + entrada
/// no saldo; fatura paga = soma das compras daquele cartão; extrato = os mesmos
/// lançamentos da conta; reserva de emergência = Tesouro Selic + poupança. As
/// datas são relativas a hoje, e nada é lançado depois de hoje (só contas a pagar).
Future<void> semearDadosDemo(AppDatabase db) async {
  final transacoes = TransacaoLocalDataSource(db);
  if ((await transacoes.observarTodas().first).isNotEmpty) return;

  final hoje = DateTime.now();
  final hojeDia = DateTime(hoje.year, hoje.month, hoje.day);
  const meses = [3, 2, 1, 0]; // do mais antigo ao atual

  DateTime dia(int d, int mesesAtras) {
    final base = DateTime(hoje.year, hoje.month - mesesAtras, 1);
    final ultimo = DateTime(base.year, base.month + 1, 0).day;
    return DateTime(base.year, base.month, d.clamp(1, ultimo));
  }

  bool jaPassou(DateTime d) => !d.isAfter(hojeDia);

  // --------------------------------------------------------------- cartões
  const nubank = Cartao(id: 'demo-nubank', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 4500);
  const inter = Cartao(id: 'demo-inter', nome: 'Inter', diaFechamento: 10, diaVencimento: 17, limite: 3000);
  final cartoes = CartaoLocalDataSource(db);
  await cartoes.salvarCartao(nubank);
  await cartoes.salvarCartao(inter);

  // Lançamentos da conta corrente do mês (alimentam também o extrato).
  final daConta = <({Transacao t, bool credito})>[];

  Future<Transacao?> lancar(
    String nome,
    double valor,
    String categoria,
    DateTime data, {
    Cartao? cartao,
  }) async {
    if (!jaPassou(data)) return null;
    final t = await transacoes.criar(descricao: nome, valor: valor, data: data, categoria: categoria);
    if (cartao != null) await transacoes.definirCartao(id: t.id, cartaoId: cartao.id);
    if (cartao == null) daConta.add((t: t, credito: valor > 0));
    return t;
  }

  Future<void> dividir(Transacao? t, List<String> com) async {
    if (t == null) return;
    final partes = com.length + 1;
    await transacoes.definirDivisao(id: t.id, minhaParte: _centavos(t.valor.abs() / partes), divididoCom: com);
  }

  // ---------------------------------------------------------------- receitas
  final rendas = RendaLocalDataSource(db);
  Future<void> receita(String nome, double valor, TipoRenda tipo, DateTime data, {RecorrenciaRenda? rec}) async {
    if (!jaPassou(data)) return;
    await rendas.criar(descricao: nome, valor: valor, tipo: tipo, dataRecebimento: data, recorrencia: rec);
    await lancar(nome, valor, 'Receitas', data);
  }

  for (final m in meses) {
    await receita('Salário', 5200, TipoRenda.fixa, dia(5, m), rec: RecorrenciaRenda.mensal);
    await receita('Rendimentos de FIIs', 96.4 + (3 - m) * 2.1, TipoRenda.variavel, dia(15, m));
  }
  await receita('Freelance de design', 1100, TipoRenda.variavel, dia(15, 3));
  await receita('Freelance de design', 600, TipoRenda.variavel, dia(20, 1));
  await receita('Freelance de design', 850, TipoRenda.variavel, dia(4, 0));
  await receita('Venda de bicicleta usada', 700, TipoRenda.variavel, dia(9, 2));

  // ------------------------------------------------- contas a pagar (mensais)
  final contas = ContaLocalDataSource(db);
  final series = <({String nome, int dia, double Function(int m) valor, String categoria, List<String> com})>[
    (nome: 'Aluguel', dia: 8, valor: (m) => 1450, categoria: 'Moradia', com: const []),
    (nome: 'Conta de luz', dia: 10, valor: (m) => _centavos(138.4 + (3 - m) * 6.3), categoria: 'Moradia', com: const ['Mãe']),
    (nome: 'Internet', dia: 12, valor: (m) => 99.9, categoria: 'Moradia', com: const []),
    (nome: 'Plano de saúde', dia: 15, valor: (m) => 289.9, categoria: 'Saúde', com: const []),
  ];

  Future<void> criarConta(String nome, double valor, DateTime venc, String categoria, int diaBase) {
    return contas.criar(
      descricao: nome,
      valor: valor,
      vencimento: venc,
      categoria: categoria,
      recorrencia: RecorrenciaConta.mensal,
      diasAntesLembrete: 2,
      diaBase: diaBase,
    );
  }

  for (final s in series) {
    for (final m in meses) {
      final venc = dia(s.dia, m);
      final valor = s.valor(m);
      if (!jaPassou(venc)) {
        await criarConta(s.nome, valor, venc, s.categoria, s.dia);
        continue;
      }
      final conta = await contas.criar(
        descricao: s.nome,
        valor: valor,
        vencimento: venc,
        categoria: s.categoria,
        recorrencia: RecorrenciaConta.mensal,
        diasAntesLembrete: 2,
        diaBase: s.dia,
      );
      final despesa = await lancar(s.nome, -valor, s.categoria, venc);
      await contas.marcarComoPaga(id: conta.id, valorPago: valor, dataPagamento: venc, transacaoId: despesa?.id);
      // Só a conta de luz é dividida com a mãe; nos meses antigos já foi reembolsada.
      if (s.com.isNotEmpty) {
        final pago = m >= 2;
        await transacoes.definirDivisao(
          id: despesa!.id,
          minhaParte: _centavos(valor / 2),
          divididoCom: pago ? [for (final p in s.com) '✓ $p'] : s.com,
        );
      }
    }
    // Depois da última paga, o app já deixa a próxima aberta.
    if (jaPassou(dia(s.dia, 0))) {
      await criarConta(s.nome, s.valor(0), dia(s.dia, -1), s.categoria, s.dia);
    }
  }

  // ----------------------------------------------- gastos da conta (débito/pix)
  for (final m in meses) {
    final mercado = await lancar('Mercado', -_centavos(412.35 - m * 14), 'Alimentação', dia(6, m));
    // Mercado do mês retrasado e do passado dividido com a mãe: um reembolsado, um pendente.
    if (m == 2 && mercado != null) {
      await transacoes.definirDivisao(
        id: mercado.id,
        minhaParte: _centavos(mercado.valor.abs() / 2),
        divididoCom: const ['✓ Mãe'],
      );
    } else if (m == 1) {
      await dividir(mercado, const ['Mãe']);
    }
    await lancar('Feira', -86.5, 'Alimentação', dia(14, m));
    await lancar('Combustível', -220, 'Transporte', dia(9, m));
    await lancar('Academia', -119.9, 'Saúde', dia(11, m));
  }
  await lancar('Restaurante Sabor', -47.5, 'Alimentação', dia(7, 0));
  await lancar('Tarifa bancária', -12.9, 'Outros', dia(10, 0));

  // ------------------------------------------------------ compras nos cartões
  final comprasCartao = <({Cartao cartao, Transacao t})>[];
  Future<Transacao?> noCartao(String nome, double valor, String categoria, DateTime data, Cartao c) async {
    final t = await lancar(nome, -valor, categoria, data, cartao: c);
    if (t != null) comprasCartao.add((cartao: c, t: t));
    return t;
  }

  for (final m in meses) {
    await noCartao('iFood', 62.9 + m * 3, 'Alimentação', dia(3, m), nubank);
    await noCartao('Netflix', 55.9, 'Lazer', dia(4, m), nubank);
    await noCartao('Farmácia', 74.2 + m * 5, 'Saúde', dia(7, m), nubank);
    await noCartao('Uber', 31.8 + m * 4, 'Transporte', dia(15, m), nubank);
    await noCartao('Amazon Prime', 19.9, 'Lazer', dia(18, m), nubank);
    await noCartao('Spotify', 21.9, 'Lazer', dia(2, m), inter);
    await noCartao('Posto Shell', 180 + m * 10, 'Transporte', dia(8, m), inter);
    await noCartao('Roupas', 249.9 - m * 20, 'Vestuário', dia(12, m), inter);
  }
  await noCartao('Cinema', 68, 'Lazer', dia(13, 0), nubank);

  // Compra dividida com a mãe: presente, 156 no total, 78 para cada.
  final presente = await noCartao('Presente de aniversário', 156, 'Lazer', dia(10, 0), nubank);
  await dividir(presente, const ['Mãe']);

  // Jantar de família: três pessoas, cada uma paga 71,33.
  final jantar = await noCartao('Jantar em família', 214, 'Alimentação', dia(11, 1), inter);
  await dividir(jantar, const ['Mãe', 'Irmão']);
  final pizza = await noCartao('Pizza de domingo', 96.9, 'Alimentação', dia(14, 0), inter);
  await dividir(pizza, const ['Mãe']);

  // Compra parcelada em 2x no Nubank, dividida com a mãe (a das gatinhas).
  final shopee = await lancar('Shopee - ração e areia dos gatos', -156, 'Pets', dia(5, 1), cartao: nubank);
  if (shopee != null) {
    final parcelamentos = ParcelamentoRepositoryImpl(ParcelamentoLocalDataSourceImpl(db), transacoes);
    await parcelamentos.criarParcelamento(
      transacaoId: shopee.id,
      totalOriginal: 156,
      numeroParcelas: 2,
      dataPrimeira: dia(5, 1),
    );
    for (final p in (await transacoes.observarTodas().first).where((t) => t.ehParcela)) {
      await transacoes.definirDivisao(
        id: p.id,
        minhaParte: _centavos(p.valorCobrado.abs() / 2),
        divididoCom: const ['Mãe'],
      );
    }
  }

  // Faturas antigas pagas: valor = soma do que o banco cobrou naquele ciclo.
  final cartaoPorId = {for (final c in [nubank, inter]) c.id: c};
  final totais = <(String, int, int), double>{};
  for (final todas in await transacoes.observarTodas().first) {
    final c = cartaoPorId[todas.cartaoId];
    if (c == null) continue;
    final f = faturaDaData(diaFechamento: c.diaFechamento, diaVencimento: c.diaVencimento, data: todas.data);
    final chave = (c.id, f.ano, f.mes);
    totais[chave] = (totais[chave] ?? 0) - todas.valorCobrado;
  }
  for (final e in totais.entries) {
    final (cartaoId, ano, mes) = e.key;
    final venc = DateTime(ano, mes, cartaoPorId[cartaoId]!.diaVencimento);
    // Toda fatura que já venceu foi paga: a demo não mostra cartão atrasado.
    if (!venc.isAfter(hojeDia)) {
      await cartoes.registrarPagamento(
        FaturaPaga(cartaoId: cartaoId, ano: ano, mes: mes, valor: _centavos(e.value), dataPagamento: venc),
      );
    }
  }

  // ------------------------------------------------------------- investimentos
  final investimentos = InvestimentoLocalDataSource(db);
  Future<void> aplicar(String id, String nome, TipoInvestimento tipo, double investido, double atual, DateTime data) {
    return investimentos.salvar(
      Investimento(
        id: id,
        nome: nome,
        tipo: tipo,
        valorInvestido: investido,
        valorAtual: atual,
        dataAplicacao: data,
      ),
    );
  }

  const tesouroAtual = 5412.30;
  const poupancaAtual = 826.40;
  await aplicar('demo-inv-1', 'Tesouro Selic 2029', TipoInvestimento.tesouroDireto, 5000, tesouroAtual, dia(10, 3));
  await aplicar('demo-inv-2', 'CDB Banco Inter 110% CDI', TipoInvestimento.cdb, 3000, 3198.75, dia(20, 3));
  await aplicar('demo-inv-3', 'Poupança', TipoInvestimento.poupanca, 800, poupancaAtual, dia(1, 3));
  await aplicar('demo-inv-4', 'ITSA4 e PETR4', TipoInvestimento.acoes, 2000, 2243.10, dia(15, 2));
  await aplicar('demo-inv-5', 'MXRF11', TipoInvestimento.fiis, 1500, 1488.20, dia(5, 2));
  await aplicar('demo-inv-6', 'Bitcoin', TipoInvestimento.cripto, 500, 612.90, dia(22, 1));

  // ------------------------------------------------------------------- metas
  final metas = MetaLocalDataSource(db);
  // A reserva é o Tesouro Selic mais a poupança, igual à tela de investimentos.
  await metas.criar(
    nome: 'Reserva de emergência',
    valorAlvo: 15000,
    prazo: DateTime(hoje.year + 1, hoje.month, 1),
    valorAtual: _centavos(tesouroAtual + poupancaAtual),
  );
  await metas.criar(
    nome: 'Viagem de férias',
    valorAlvo: 4000,
    prazo: DateTime(hoje.year, hoje.month + 6, 1),
    valorAtual: 1350,
  );
  await metas.criar(
    nome: 'Notebook novo',
    valorAlvo: 6500,
    prazo: DateTime(hoje.year, hoje.month + 9, 1),
    valorAtual: 2100,
  );

  // -------------------------------------------------------------- orçamentos
  final orcamentos = OrcamentoLocalDataSource(db);
  await orcamentos.definirLimite(categoria: 'Alimentação', limite: 1200);
  await orcamentos.definirLimite(categoria: 'Moradia', limite: 2300);
  await orcamentos.definirLimite(categoria: 'Transporte', limite: 600);
  await orcamentos.definirLimite(categoria: 'Lazer', limite: 400);
  await orcamentos.definirLimite(categoria: 'Saúde', limite: 500);

  // ---------------------------------------------------------------- lembretes
  final lembretes = LembreteLocalDataSource(db);
  await lembretes.salvar(
    const LembretePersonalizado(id: 'demo-lem-1', titulo: 'Fatura Nubank fecha', tipo: TipoLembrete.faturaFecha, dia: 25),
  );
  await lembretes.salvar(
    const LembretePersonalizado(id: 'demo-lem-2', titulo: 'Fatura Nubank vence', tipo: TipoLembrete.faturaVence, dia: 5),
  );
  await lembretes.salvar(
    const LembretePersonalizado(id: 'demo-lem-3', titulo: 'Fatura Inter vence', tipo: TipoLembrete.faturaVence, dia: 17),
  );
  await lembretes.salvar(
    const LembretePersonalizado(id: 'demo-lem-4', titulo: 'Aportar na reserva', tipo: TipoLembrete.outro, dia: 6),
  );

  // ------------------------------------------------- extrato (conciliação)
  // As mesmas movimentações da conta, como o banco as descreveria, mais duas que
  // o app ainda não conhece (para mostrar "criar lançamento a partir do extrato").
  final reconciliacao = ReconciliationLocalDataSourceImpl(db);
  final linhas = <ExtratoLinhasTableCompanion>[];
  var n = 0;
  void linhaDoExtrato(String descricao, double valor, DateTime data, bool credito) {
    n++;
    linhas.add(
      ExtratoLinhasTableCompanion(
        id: Value('demo-ext-$n'),
        importId: Value('demo-import-${data.year}-${data.month}'),
        descricao: Value(descricao),
        valor: Value(valor.abs()),
        data: Value(data),
        tipo: Value(credito ? 'C' : 'D'),
        nomeBancoOriginal: Value(descricao),
        fitid: Value('DEMO$n'),
      ),
    );
  }

  final limiteExtrato = dia(1, 1);
  for (final l in daConta) {
    if (l.t.data.isBefore(limiteExtrato)) continue;
    final nome = l.credito ? 'PIX RECEBIDO ${l.t.descricao.toUpperCase()}' : 'DEB ${l.t.descricao.toUpperCase()}';
    linhaDoExtrato(nome, l.t.valor, l.t.data, l.credito);
  }
  if (jaPassou(dia(9, 0))) linhaDoExtrato('PIX ENVIADO PADARIA PAO QUENTE', 23.8, dia(9, 0), false);
  if (jaPassou(dia(3, 0))) linhaDoExtrato('IOF E ENCARGOS', 8.4, dia(3, 0), false);
  if (linhas.isNotEmpty) await reconciliacao.salvarLinhasExtrato(linhas);
}
