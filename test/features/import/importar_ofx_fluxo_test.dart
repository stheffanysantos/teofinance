import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/import/data/repositories/import_repository_impl.dart';
import 'package:teofinance/features/import/data/services/bank_profile_matcher.dart';
import 'package:teofinance/features/import/data/services/csv_dialect_detector.dart';
import 'package:teofinance/features/import/data/services/csv_table_parser.dart';
import 'package:teofinance/features/import/data/services/valor_celula_parser.dart';
import 'package:teofinance/features/import/domain/entities/formato_extrato.dart';
import 'package:teofinance/features/import/domain/entities/perfil_banco.dart';
import 'package:teofinance/features/import/domain/repositories/perfil_banco_repository.dart';
import 'package:teofinance/features/import/domain/usecases/importar_extrato_usecase.dart';
import 'package:teofinance/features/import/presentation/providers/import_flow_notifier.dart';
import 'package:teofinance/features/import/presentation/providers/import_flow_state.dart';
import 'package:teofinance/features/import/presentation/providers/import_providers.dart';
import 'package:teofinance/features/reconciliation/domain/entities/extrato_linha.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/reconciliation/presentation/providers/reconciliation_providers.dart';

class _PerfisVazios implements PerfilBancoRepository {
  @override
  Future<Either<Failure, List<PerfilBanco>>> listarTodos() async => const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReconciliacaoEspia implements ReconciliationRepository {
  List<Map<String, dynamic>>? linhasRecebidas;

  @override
  Future<Either<Failure, List<ExtratoLinha>>> importarExtrato({
    required String importId,
    required List<Map<String, dynamic>> linhas,
  }) async {
    linhasRecebidas = linhas;
    return const Right([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ImportRepositoryImpl _repositorio() => ImportRepositoryImpl(
      detector: CsvDialectDetector(),
      parser: CsvTableParser(),
      matcher: BankProfileMatcher(),
      valorParser: ValorCelulaParser(),
      perfilBancoRepository: _PerfisVazios(),
    );

Uint8List _bytes(String s) => Uint8List.fromList(utf8.encode(s));

final _ofx = _bytes('''OFXHEADER:100
<OFX><FI><ORG>Banco Exemplo</FI>
<BANKTRANLIST>
<STMTTRN><DTPOSTED>20261005<TRNAMT>-52.30<MEMO>MERCADO</STMTTRN>
<STMTTRN><DTPOSTED>20261010<TRNAMT>3500.00<NAME>SALARIO</STMTTRN>
</BANKTRANLIST></OFX>''');

final _csv = _bytes('Data;Descricao;Valor\n05/10/2026;Mercado;-52,30\n10/10/2026;Salario;3500,00\n');

void main() {
  group('ImportRepositoryImpl', () {
    final repo = _repositorio();

    test('detecta o formato pelo conteúdo', () {
      expect(repo.detectarFormato(_ofx), FormatoExtrato.ofx);
      expect(repo.detectarFormato(_csv), FormatoExtrato.csv);
    });

    test('importarOfx devolve as transações e a instituição', () async {
      final r = (await repo.importarOfx(_ofx)).getOrElse((f) => throw StateError(f.message));

      expect(r.transacoes, hasLength(2));
      expect(r.instituicao, 'Banco Exemplo');
    });

    test('OFX inválido vira ValidationFailure com o motivo', () async {
      final r = await repo.importarOfx(_bytes('OFXHEADER:100\n<OFX><STMTTRN><DTPOSTED>20261005<MEMO>x</STMTTRN></OFX>'));

      final falha = r.swap().getOrElse((_) => throw StateError('esperava Left'));
      expect(falha, isA<ValidationFailure>());
      expect(falha.message, contains('TRNAMT'));
    });
  });

  group('ImportFlowNotifier', () {
    late ProviderContainer container;
    late _ReconciliacaoEspia reconciliacao;

    setUp(() {
      reconciliacao = _ReconciliacaoEspia();
      container = ProviderContainer(overrides: [
        importarExtratoUseCaseProvider.overrideWithValue(ImportarExtratoUseCase(_repositorio())),
        reconciliationRepositoryProvider.overrideWithValue(reconciliacao),
      ]);
      addTearDown(container.dispose);
    });

    ImportFlowNotifier notifier() => container.read(importFlowProvider.notifier);
    ImportFlowState estado() => container.read(importFlowProvider);

    test('OFX pula o mapeamento de colunas e vai direto para a revisão', () async {
      await notifier().analisarArquivo(bytes: _ofx, nomeArquivo: 'extrato.ofx');

      expect(estado().etapa, ImportEtapa.revisando);
      expect(estado().formato, FormatoExtrato.ofx);
      expect(estado().transacoes, hasLength(2));
      expect(estado().preview, isNull);
      expect(estado().carregando, isFalse);
      expect(estado().erro, isNull);
    });

    test('OFX com defeito fica na seleção de arquivo e mostra o erro', () async {
      await notifier().analisarArquivo(
        bytes: _bytes('OFXHEADER:100\n<OFX><BANKTRANLIST></BANKTRANLIST></OFX>'),
        nomeArquivo: 'ruim.ofx',
      );

      expect(estado().etapa, ImportEtapa.selecionandoArquivo);
      expect(estado().erro, contains('Nenhuma transação'));
      expect(estado().carregando, isFalse);
    });

    test('CSV continua indo para o mapeamento de colunas', () async {
      await notifier().analisarArquivo(bytes: _csv, nomeArquivo: 'extrato.csv');

      expect(estado().etapa, ImportEtapa.mapeandoColunas);
      expect(estado().formato, FormatoExtrato.csv);
      expect(estado().preview, isNotNull);
    });

    test('OFX enviado para a reconciliação leva banco e sentido de cada linha', () async {
      await notifier().analisarArquivo(bytes: _ofx, nomeArquivo: 'extrato.ofx');

      await notifier().confirmarParaReconciliacao();

      final linhas = reconciliacao.linhasRecebidas!;
      expect(linhas, hasLength(2));
      expect(linhas.every((l) => l['nomeBancoOriginal'] == 'Banco Exemplo'), isTrue);
      expect(linhas[0]['tipo'], 'D');
      expect(linhas[0]['valor'], 52.30);
      expect(linhas[1]['tipo'], 'C');
      expect(estado().paraReconciliacao, isTrue);
    });

    test('reiniciar volta ao formato padrão', () async {
      await notifier().analisarArquivo(bytes: _ofx, nomeArquivo: 'extrato.ofx');

      notifier().reiniciar();

      expect(estado().formato, FormatoExtrato.csv);
      expect(estado().instituicao, isNull);
    });
  });
}
