import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/dashboard/presentation/providers/dashboard_summary_provider.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/data/repositories/transacao_repository_impl.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/usecases/ajustar_saldo_usecase.dart';

void main() {
  late AppDatabase db;
  late TransacaoRepositoryImpl repo;
  late AjustarSaldoUseCase ajustar;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TransacaoRepositoryImpl(TransacaoLocalDataSource(db));
    ajustar = AjustarSaldoUseCase(repo, agora: () => DateTime(2026, 11, 5));
  });
  tearDown(() => db.close());

  Future<List<Transacao>> todas() => repo.observarTodas().first;
  Future<double> saldo() async => (await todas()).fold<double>(0, (a, t) => a + t.valor);

  test('faz o saldo do app bater com o saldo real, com a data no início do histórico', () async {
    await repo.criar(descricao: 'Compra', valor: -1629.05, data: DateTime(2026, 10, 3));

    await ajustar(2000);

    expect(await saldo(), closeTo(2000, .001));
    final ajuste = (await todas()).singleWhere((t) => t.categoria == kCategoriaAjusteSaldo);
    expect(ajuste.valor, closeTo(3629.05, .001));
    expect(ajuste.data, DateTime(2026, 10, 3));
  });

  test('ajustar de novo atualiza o mesmo lançamento (não cria outro)', () async {
    await repo.criar(descricao: 'Compra', valor: -100, data: DateTime(2026, 10, 3));
    await ajustar(500);
    await ajustar(300);

    final lista = await todas();
    expect(lista.where((t) => t.categoria == kCategoriaAjusteSaldo), hasLength(1));
    expect(await saldo(), closeTo(300, .001));
  });

  test('saldo real igual ao do app remove o ajuste', () async {
    await repo.criar(descricao: 'Compra', valor: -100, data: DateTime(2026, 10, 3));
    await ajustar(500);

    await ajustar(-100);

    expect((await todas()).where((t) => t.categoria == kCategoriaAjusteSaldo), isEmpty);
  });

  test('sem histórico o ajuste fica em hoje', () async {
    await ajustar(1000);

    expect((await todas()).single.data, DateTime(2026, 11, 5));
  });

  test('o ajuste não vira receita nem despesa no relatório mensal', () async {
    await repo.criar(descricao: 'Mercado', valor: -100, data: DateTime(2026, 10, 3), categoria: 'Mercado');
    await ajustar(5000);

    final relatorio = RelatorioMensal.de(await todas(), ano: 2026, mes: 10);

    expect(relatorio.receitas, 0);
    expect(relatorio.despesas, 100);
    expect(kCategoriaAjusteSaldo, isNotEmpty);
    expect(DashboardSummary, isNotNull);
  });
}
