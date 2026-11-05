import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/categoria/data/datasources/categoria_local_data_source.dart';
import 'package:teofinance/features/categoria/data/repositories/categoria_repository_impl.dart';
import 'package:teofinance/features/categoria/domain/usecases/renomear_categoria_usecase.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/data/repositories/transacao_repository_impl.dart';

void main() {
  test(
    'renomear categoria leva as transações junto e recusa nome repetido',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final categorias = CategoriaRepositoryImpl(CategoriaLocalDataSource(db));
      final transacoes = TransacaoRepositoryImpl(TransacaoLocalDataSource(db));
      await categorias.adicionar('Pets');
      await categorias.adicionar('Viagem');
      await transacoes.criar(
        descricao: 'Ração',
        valor: -50,
        data: DateTime(2026, 10, 1),
        categoria: 'Pets',
      );

      final uc = RenomearCategoriaUseCase(categorias, transacoes);
      expect(
        (await uc(
          nomeAtual: 'Pets',
          novoNome: 'viagem',
          existentes: ['Pets', 'Viagem'],
        )).isLeft(),
        isTrue,
      );

      final ok = await uc(
        nomeAtual: 'Pets',
        novoNome: 'Animais',
        existentes: ['Pets', 'Viagem'],
      );
      expect(ok.isRight(), isTrue);
      expect(
        (await categorias.listar()).getOrElse((_) => []),
        unorderedEquals(['Animais', 'Viagem']),
      );
      expect(
        (await transacoes.observarTodas().first).single.categoria,
        'Animais',
      );
    },
  );
}
