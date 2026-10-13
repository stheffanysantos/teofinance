import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/perfil_banco.dart';
import '../../domain/entities/preview_arquivo.dart';
import '../../domain/entities/transacao_importada.dart';
import '../../domain/repositories/import_repository.dart';
import '../../domain/repositories/perfil_banco_repository.dart';
import '../services/bank_profile_matcher.dart';
import '../services/csv_dialect_detector.dart';
import '../services/csv_table_parser.dart';
import '../services/valor_celula_parser.dart';

const _kLinhasAmostra = 5;

class ImportRepositoryImpl implements ImportRepository {
  ImportRepositoryImpl({
    required CsvDialectDetector detector,
    required CsvTableParser parser,
    required BankProfileMatcher matcher,
    required ValorCelulaParser valorParser,
    required PerfilBancoRepository perfilBancoRepository,
  }) : _detector = detector,
       _parser = parser,
       _matcher = matcher,
       _valorParser = valorParser,
       _perfilBancoRepository = perfilBancoRepository;

  final CsvDialectDetector _detector;
  final CsvTableParser _parser;
  final BankProfileMatcher _matcher;
  final ValorCelulaParser _valorParser;
  final PerfilBancoRepository _perfilBancoRepository;

  @override
  Future<Either<Failure, PreviewArquivo>> analisarArquivo(Uint8List bytes) async {
    try {
      final latin1Encoding = _detector.detectarCodificacaoLatin1(bytes);
      final conteudo = _detector.decodificar(bytes, latin1Encoding: latin1Encoding);
      final delimitador = _detector.detectarDelimitador(conteudo);
      final linhas = _parser.parsear(conteudo, delimitador: delimitador);

      if (linhas.isEmpty) {
        return const Left(ValidationFailure('O arquivo está vazio ou não pôde ser lido como CSV.'));
      }

      final temCabecalho = _detector.detectarTemCabecalho(linhas);
      final cabecalho = temCabecalho
          ? linhas.first
          : List.generate(linhas.first.length, (i) => 'Coluna ${i + 1}');
      final linhasDeDado = temCabecalho ? linhas.skip(1).toList() : linhas;

      final perfisSalvos = await _perfilBancoRepository.listarTodos();
      final perfilCompativel = perfisSalvos.match(
        (_) => null,
        (perfis) => _matcher.encontrarCompativel(perfis, cabecalho),
      );

      return Right(
        PreviewArquivo(
          cabecalho: cabecalho,
          linhasAmostra: linhasDeDado.take(_kLinhasAmostra).toList(),
          delimitador: delimitador,
          codificacaoLatin1: latin1Encoding,
          temCabecalho: temCabecalho,
          perfilCompativel: perfilCompativel,
        ),
      );
    } catch (e) {
      return Left(ValidationFailure('Não foi possível ler o arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransacaoImportada>>> importar({
    required Uint8List bytes,
    required PerfilBanco perfil,
  }) async {
    try {
      final conteudo = _detector.decodificar(bytes, latin1Encoding: perfil.codificacaoLatin1);
      final linhas = _parser.parsear(conteudo, delimitador: perfil.delimitador);
      final linhasDeDado = perfil.temCabecalho ? linhas.skip(1).toList() : linhas;

      if (linhasDeDado.isNotEmpty &&
          !_matcher.compativel(perfil, linhasDeDado.first.length)) {
        return Left(
          ValidationFailure(
            'O arquivo tem ${linhasDeDado.first.length} colunas, mas o perfil "${perfil.nomeBanco}" '
            'espera ${perfil.numeroColunasEsperado}. O layout do banco pode ter mudado — remapeie as colunas.',
          ),
        );
      }

      final indiceData = _indicePara(perfil, CampoColuna.data);
      final indiceDescricao = _indicePara(perfil, CampoColuna.descricao);
      final indiceValor = _indicePara(perfil, CampoColuna.valor);
      final indiceCategoria = _indiceOpcionalPara(perfil, CampoColuna.categoria);

      final transacoes = <TransacaoImportada>[];
      for (final linha in linhasDeDado) {
        if (linha.every((c) => c.trim().isEmpty)) continue;
        transacoes.add(
          TransacaoImportada(
            data: _valorParser.parsearData(linha[indiceData], formato: perfil.formatoData),
            descricao: linha[indiceDescricao].trim(),
            valor: _valorParser.parsearValor(
              linha[indiceValor],
              separadorDecimalVirgula: perfil.separadorDecimalVirgula,
            ),
            categoria: indiceCategoria != null ? linha[indiceCategoria].trim() : null,
          ),
        );
      }
      return Right(transacoes);
    } catch (e) {
      return Left(ValidationFailure('Falha ao interpretar o arquivo com este perfil: $e'));
    }
  }

  int _indicePara(PerfilBanco perfil, CampoColuna campo) {
    return perfil.mapeamentoColunas.entries.firstWhere((e) => e.value == campo).key;
  }

  int? _indiceOpcionalPara(PerfilBanco perfil, CampoColuna campo) {
    for (final entry in perfil.mapeamentoColunas.entries) {
      if (entry.value == campo) return entry.key;
    }
    return null;
  }
}
