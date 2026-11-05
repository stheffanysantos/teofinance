import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/categoria/data/datasources/categoria_local_data_source.dart';
import 'package:teofinance/features/categoria/data/repositories/categoria_repository_impl.dart';
import 'package:teofinance/features/categoria/domain/usecases/adicionar_categoria_usecase.dart';
import 'package:teofinance/features/categoria/domain/usecases/remover_categoria_usecase.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/investimento/data/repositories/investimento_repository_impl.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/domain/usecases/salvar_investimento_usecase.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/data/repositories/lembrete_repository_impl.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/domain/services/planejar_lembretes_personalizados.dart';
import 'package:teofinance/features/lembrete/domain/usecases/salvar_lembrete_usecase.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('categorias', () {
    test('adiciona, lista sem diferenciar maiúsculas e recusa duplicada ou padrão', () async {
      final repo = CategoriaRepositoryImpl(CategoriaLocalDataSource(db));
      final adicionar = AdicionarCategoriaUseCase(repo);

      expect((await adicionar('  Pets ', existentes: const [])).isRight(), isTrue);
      expect((await repo.listar()).getOrElse((_) => []), ['Pets']);

      expect((await adicionar('pets', existentes: ['Pets'])).isLeft(), isTrue);
      expect((await adicionar('mercado', existentes: const [])).isLeft(), isTrue);
      expect((await adicionar('   ', existentes: const [])).isLeft(), isTrue);
    });

    test('remove a própria e recusa remover a padrão', () async {
      final repo = CategoriaRepositoryImpl(CategoriaLocalDataSource(db));
      await AdicionarCategoriaUseCase(repo).call('Pets', existentes: const []);

      expect((await RemoverCategoriaUseCase(repo).call('Mercado')).isLeft(), isTrue);
      expect((await RemoverCategoriaUseCase(repo).call('Pets')).isRight(), isTrue);
      expect((await repo.listar()).getOrElse((_) => []), isEmpty);
    });
  });

  group('investimentos', () {
    test('cadastra, edita (mesmo id) e exclui', () async {
      final repo = InvestimentoRepositoryImpl(InvestimentoLocalDataSource(db));
      final salvar = SalvarInvestimentoUseCase(repo);

      final criado = await salvar(
        nome: 'CDB Banco X',
        tipo: TipoInvestimento.cdb,
        valorInvestido: 1000,
        valorAtual: 1050,
        dataAplicacao: DateTime(2026, 10, 1),
      );
      expect(criado.isRight(), isTrue);

      var itens = (await repo.listar()).getOrElse((_) => []);
      expect(itens, hasLength(1));
      expect(itens.single.tipo, TipoInvestimento.cdb);
      expect(itens.single.rentabilidadePercentual, closeTo(5, .001));

      await salvar(
        id: itens.single.id,
        nome: 'CDB Banco X',
        tipo: TipoInvestimento.cdb,
        valorInvestido: 1000,
        valorAtual: 1100,
        dataAplicacao: DateTime(2026, 10, 1),
      );
      itens = (await repo.listar()).getOrElse((_) => []);
      expect(itens, hasLength(1));
      expect(itens.single.valorAtual, 1100);

      await repo.excluir(itens.single.id);
      expect((await repo.listar()).getOrElse((_) => []), isEmpty);
    });

    test('valida nome e valor investido', () async {
      final salvar = SalvarInvestimentoUseCase(InvestimentoRepositoryImpl(InvestimentoLocalDataSource(db)));

      final semNome = await salvar(
        nome: ' ',
        tipo: TipoInvestimento.outro,
        valorInvestido: 10,
        valorAtual: 10,
        dataAplicacao: DateTime(2026, 1, 1),
      );
      final semValor = await salvar(
        nome: 'X',
        tipo: TipoInvestimento.outro,
        valorInvestido: 0,
        valorAtual: 0,
        dataAplicacao: DateTime(2026, 1, 1),
      );

      expect(semNome.isLeft(), isTrue);
      expect(semValor.isLeft(), isTrue);
    });

    test('resumo soma investido e atual', () {
      final resumo = ResumoInvestimentos.de([
        Investimento(
          id: '1',
          nome: 'A',
          tipo: TipoInvestimento.acoes,
          valorInvestido: 100,
          valorAtual: 120,
          dataAplicacao: DateTime(2026, 1, 1),
        ),
        Investimento(
          id: '2',
          nome: 'B',
          tipo: TipoInvestimento.fiis,
          valorInvestido: 100,
          valorAtual: 80,
          dataAplicacao: DateTime(2026, 1, 1),
        ),
      ]);

      expect(resumo.totalInvestido, 200);
      expect(resumo.totalAtual, 200);
      expect(resumo.rentabilidadePercentual, 0);
    });
  });

  group('lembretes personalizados', () {
    test('cria, alterna ativo, edita e exclui', () async {
      final repo = LembreteRepositoryImpl(LembreteLocalDataSource(db));
      final salvar = SalvarLembreteUseCase(repo);

      await salvar(const LembretePersonalizado(id: '', titulo: 'Nubank', tipo: TipoLembrete.faturaFecha, dia: 12));
      var itens = (await repo.listar()).getOrElse((_) => []);
      expect(itens.single.ativo, isTrue);
      expect(itens.single.id, isNotEmpty);

      await salvar(itens.single.copyWith(ativo: false, dia: 15));
      itens = (await repo.listar()).getOrElse((_) => []);
      expect(itens.single.ativo, isFalse);
      expect(itens.single.dia, 15);

      await repo.excluir(itens.single.id);
      expect((await repo.listar()).getOrElse((_) => []), isEmpty);
    });

    test('valida título e dia', () async {
      final salvar = SalvarLembreteUseCase(LembreteRepositoryImpl(LembreteLocalDataSource(db)));

      expect((await salvar(const LembretePersonalizado(id: '', titulo: '', tipo: TipoLembrete.outro, dia: 5))).isLeft(), isTrue);
      expect((await salvar(const LembretePersonalizado(id: '', titulo: 'A', tipo: TipoLembrete.outro, dia: 32))).isLeft(), isTrue);
    });

    test('planejamento: próximos meses, dia 31 vira o último dia e inativo fica de fora', () {
      const ativo = LembretePersonalizado(id: '1', titulo: 'Fatura', tipo: TipoLembrete.faturaVence, dia: 31);
      const inativo = LembretePersonalizado(id: '2', titulo: 'Off', tipo: TipoLembrete.outro, dia: 5, ativo: false);

      final lista = planejarLembretesPersonalizados(
        [ativo, inativo],
        agora: DateTime(2026, 1, 31, 10),
        hora: 9,
      );

      expect(lista, hasLength(kMesesAgendadosPersonalizados));
      // 31/01 09:00 já passou; fevereiro tem 28 dias em 2026.
      expect(lista.first.quando, DateTime(2026, 2, 28, 9));
      expect(lista[1].quando, DateTime(2026, 3, 31, 9));
      expect(lista.map((l) => l.id).toSet(), hasLength(lista.length));
    });
  });

  test('banco novo já tem as tabelas locais (criação e migração usam o mesmo SQL)', () async {
    final tabelas = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'table'").get();
    final nomes = tabelas.map((t) => t.read<String>('name')).toSet();

    expect(nomes, containsAll(['categorias_personalizadas', 'investimentos_manuais', 'lembretes_personalizados']));
  });
}
