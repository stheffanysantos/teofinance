import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/import/data/repositories/import_repository_impl.dart';
import 'package:teofinance/features/import/data/services/bank_profile_matcher.dart';
import 'package:teofinance/features/import/data/services/csv_dialect_detector.dart';
import 'package:teofinance/features/import/data/services/csv_table_parser.dart';
import 'package:teofinance/features/import/data/services/valor_celula_parser.dart';
import 'package:teofinance/features/import/domain/entities/campo_coluna.dart';
import 'package:teofinance/features/import/domain/entities/perfil_banco.dart';
import 'package:teofinance/features/import/domain/repositories/perfil_banco_repository.dart';

/// Repositório de perfis em memória — evita depender do drift real nos
/// testes de parsing.
class _FakePerfilBancoRepository implements PerfilBancoRepository {
  final List<PerfilBanco> perfis = [];

  @override
  Future<Either<Failure, List<PerfilBanco>>> listarTodos() async => Right(perfis);

  @override
  Future<PerfilBanco?> buscarCompativel(List<String> assinaturaCabecalho) async =>
      BankProfileMatcher().encontrarCompativel(perfis, assinaturaCabecalho);

  @override
  Future<Either<Failure, PerfilBanco>> salvar(PerfilBanco perfil) async {
    perfis.removeWhere((p) => p.id == perfil.id);
    final salvo = perfil.id.isEmpty ? perfil.copyWith() : perfil;
    perfis.add(salvo);
    return Right(salvo);
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    perfis.removeWhere((p) => p.id == id);
    return const Right(unit);
  }

  @override
  Future<List<PerfilBanco>> listarPendentesDeSincronizacao() async => [];

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) async {}

  @override
  Future<void> aplicarRemoto(PerfilBanco perfil) async {}
}

ImportRepositoryImpl _buildRepository(_FakePerfilBancoRepository perfilRepo) {
  return ImportRepositoryImpl(
    detector: CsvDialectDetector(),
    parser: CsvTableParser(),
    matcher: BankProfileMatcher(),
    valorParser: ValorCelulaParser(),
    perfilBancoRepository: perfilRepo,
  );
}

Uint8List _bytes(String conteudo, {bool latin1Encoding = false}) {
  return Uint8List.fromList(latin1Encoding ? latin1.encode(conteudo) : utf8.encode(conteudo));
}

void main() {
  group('CsvDialectDetector', () {
    final detector = CsvDialectDetector();

    test('detecta delimitador vírgula', () {
      expect(detector.detectarDelimitador('Data,Valor,Descrição'), ',');
    });

    test('detecta delimitador ponto e vírgula', () {
      expect(detector.detectarDelimitador('Data;Valor;Histórico;Documento'), ';');
    });

    test('detecta UTF-8 como padrão', () {
      expect(detector.detectarCodificacaoLatin1(_bytes('Histórico')), false);
    });

    test('detecta Latin-1 quando os bytes não são UTF-8 válido', () {
      final bytesLatin1 = _bytes('Histórico', latin1Encoding: true);
      expect(detector.detectarCodificacaoLatin1(bytesLatin1), true);
    });
  });

  group('ImportRepositoryImpl — fluxo Nubank-like (vírgula, UTF-8, yyyy-MM-dd)', () {
    test('analisa e importa corretamente', () async {
      final repo = _buildRepository(_FakePerfilBancoRepository());
      const csv = 'Data,Valor,Identificador,Descrição\n'
          '2026-01-15,-123.45,abc,Supermercado Dia\n'
          '2026-01-16,6200,def,Salário\n';

      final preview = await repo.analisarArquivo(_bytes(csv));
      expect(preview.isRight(), true);
      final p = preview.getRight().toNullable()!;
      expect(p.cabecalho, ['Data', 'Valor', 'Identificador', 'Descrição']);
      expect(p.delimitador, ',');
      expect(p.codificacaoLatin1, false);
      expect(p.perfilCompativel, isNull);

      final perfil = PerfilBanco(
        id: 'nubank-conta',
        nomeBanco: 'Nubank',
        delimitador: ',',
        codificacaoLatin1: false,
        temCabecalho: true,
        formatoData: 'yyyy-MM-dd',
        separadorDecimalVirgula: false,
        mapeamentoColunas: const {
          0: CampoColuna.data,
          1: CampoColuna.valor,
          2: CampoColuna.ignorar,
          3: CampoColuna.descricao,
        },
        assinaturaCabecalho: p.cabecalho,
      );

      final resultado = await repo.importar(bytes: _bytes(csv), perfil: perfil);
      expect(resultado.isRight(), true);
      final transacoes = resultado.getRight().toNullable()!;
      expect(transacoes, hasLength(2));
      expect(transacoes[0].descricao, 'Supermercado Dia');
      expect(transacoes[0].valor, -123.45);
      expect(transacoes[0].data, DateTime(2026, 1, 15));
      expect(transacoes[1].valor, 6200);
    });
  });

  group('ImportRepositoryImpl — fluxo Banco do Brasil-like (ponto e vírgula, Latin-1, dd/MM/yyyy, vírgula decimal)', () {
    test('importa corretamente e reconhece o perfil salvo na próxima vez', () async {
      final perfilRepo = _FakePerfilBancoRepository();
      final repo = _buildRepository(perfilRepo);

      const csv = 'Data;Dependência Origem;Histórico;Número do documento;Valor\n'
          '15/01/2026;0001;Pagamento de boleto;123456;-1.850,00\n'
          '16/01/2026;0001;Transferência recebida;123457;2.400,50\n';

      final perfil = PerfilBanco(
        id: '',
        nomeBanco: 'Banco do Brasil',
        delimitador: ';',
        codificacaoLatin1: true,
        temCabecalho: true,
        formatoData: 'dd/MM/yyyy',
        separadorDecimalVirgula: true,
        mapeamentoColunas: const {
          0: CampoColuna.data,
          1: CampoColuna.ignorar,
          2: CampoColuna.descricao,
          3: CampoColuna.ignorar,
          4: CampoColuna.valor,
        },
        assinaturaCabecalho: const [
          'Data',
          'Dependência Origem',
          'Histórico',
          'Número do documento',
          'Valor',
        ],
      );
      await perfilRepo.salvar(perfil.copyWith());

      final bytes = _bytes(csv, latin1Encoding: true);
      final resultado = await repo.importar(bytes: bytes, perfil: perfil);
      expect(resultado.isRight(), true);
      final transacoes = resultado.getRight().toNullable()!;
      expect(transacoes[0].valor, -1850.0);
      expect(transacoes[0].data, DateTime(2026, 1, 15));
      expect(transacoes[1].valor, 2400.50);

      // Uma nova análise do mesmo layout deve reconhecer o perfil salvo.
      final preview = await repo.analisarArquivo(bytes);
      final p = preview.getRight().toNullable()!;
      expect(p.perfilCompativel?.nomeBanco, 'Banco do Brasil');
    });
  });

  group('Perfil incompatível — nunca mapeia colunas erradas silenciosamente', () {
    test('falha explicitamente quando o número de colunas não bate', () async {
      final repo = _buildRepository(_FakePerfilBancoRepository());

      final perfilAntigo = PerfilBanco(
        id: 'x',
        nomeBanco: 'Banco X',
        delimitador: ',',
        codificacaoLatin1: false,
        temCabecalho: true,
        formatoData: 'yyyy-MM-dd',
        separadorDecimalVirgula: false,
        mapeamentoColunas: const {0: CampoColuna.data, 1: CampoColuna.valor, 2: CampoColuna.descricao},
        assinaturaCabecalho: const ['Data', 'Valor', 'Descrição'],
      );

      // Arquivo novo tem uma coluna a mais — layout do banco mudou.
      const csvNovoLayout = 'Data,Valor,Descrição,Categoria\n2026-01-01,-10,Teste,Lazer\n';

      final resultado = await repo.importar(bytes: _bytes(csvNovoLayout), perfil: perfilAntigo);
      expect(resultado.isLeft(), true);
      expect(resultado.getLeft().toNullable(), isA<ValidationFailure>());
    });
  });
}
