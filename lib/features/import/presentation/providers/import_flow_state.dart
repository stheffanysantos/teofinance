import 'dart:typed_data';

import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/formato_extrato.dart';
import '../../domain/entities/perfil_banco.dart';
import '../../domain/entities/preview_arquivo.dart';
import '../../domain/entities/transacao_importada.dart';

enum ImportEtapa { selecionandoArquivo, mapeandoColunas, revisando, concluido }

class ImportFlowState {
  const ImportFlowState({
    this.etapa = ImportEtapa.selecionandoArquivo,
    this.carregando = false,
    this.erro,
    this.bytes,
    this.nomeArquivo,
    this.preview,
    this.nomePerfil = '',
    this.mapeamentoRascunho = const {},
    this.formatoData = 'dd/MM/yyyy',
    this.separadorDecimalVirgula = true,
    this.transacoes = const [],
    this.perfilUsado,
    this.paraReconciliacao = false,
    this.formato = FormatoExtrato.csv,
    this.instituicao,
    this.saldoFinal,
    this.ehCartao = false,
    this.cartaoId,
    this.ignoradas = const {},
    this.ajustarSaldo = false,
  });

  final ImportEtapa etapa;
  final bool carregando;
  final String? erro;

  final Uint8List? bytes;
  final String? nomeArquivo;
  final PreviewArquivo? preview;

  final String nomePerfil;
  final Map<int, CampoColuna> mapeamentoRascunho;
  final String formatoData;
  final bool separadorDecimalVirgula;

  final List<TransacaoImportada> transacoes;
  final PerfilBanco? perfilUsado;
  final bool paraReconciliacao;
  final FormatoExtrato formato;

  /// Banco informado pelo próprio arquivo (OFX); no CSV vem do Perfil de Banco.
  final String? instituicao;

  /// Saldo final informado pelo banco no OFX de conta corrente.
  final double? saldoFinal;

  /// O arquivo é uma fatura de cartão.
  final bool ehCartao;

  /// Cartão ao qual as compras importadas serão vinculadas; nulo = nenhum.
  final String? cartaoId;

  /// Posições (em [transacoes]) que o usuário tirou da importação — começa com
  /// os pagamentos de fatura, que já estão contados nas compras do cartão.
  final Set<int> ignoradas;

  /// Ajustar o "Saldo total" do app ao [saldoFinal] depois de importar.
  final bool ajustarSaldo;

  /// O que de fato será importado.
  List<TransacaoImportada> get efetivas => [
    for (var i = 0; i < transacoes.length; i++)
      if (!ignoradas.contains(i)) transacoes[i],
  ];

  double get entradas => efetivas.where((t) => t.valor > 0).fold(0.0, (a, t) => a + t.valor);
  double get saidas => efetivas.where((t) => t.valor < 0).fold(0.0, (a, t) => a + t.valor.abs());

  int get quantidadeSemCategoria => efetivas.where((t) => t.precisaCategoria).length;

  ImportFlowState copyWith({
    ImportEtapa? etapa,
    bool? carregando,
    String? erro,
    bool limparErro = false,
    Uint8List? bytes,
    String? nomeArquivo,
    PreviewArquivo? preview,
    String? nomePerfil,
    Map<int, CampoColuna>? mapeamentoRascunho,
    String? formatoData,
    bool? separadorDecimalVirgula,
    List<TransacaoImportada>? transacoes,
    PerfilBanco? perfilUsado,
    bool? paraReconciliacao,
    FormatoExtrato? formato,
    String? instituicao,
    double? saldoFinal,
    bool? ehCartao,
    String? cartaoId,
    bool limparCartao = false,
    Set<int>? ignoradas,
    bool? ajustarSaldo,
  }) {
    return ImportFlowState(
      etapa: etapa ?? this.etapa,
      carregando: carregando ?? this.carregando,
      erro: limparErro ? null : (erro ?? this.erro),
      bytes: bytes ?? this.bytes,
      nomeArquivo: nomeArquivo ?? this.nomeArquivo,
      preview: preview ?? this.preview,
      nomePerfil: nomePerfil ?? this.nomePerfil,
      mapeamentoRascunho: mapeamentoRascunho ?? this.mapeamentoRascunho,
      formatoData: formatoData ?? this.formatoData,
      separadorDecimalVirgula: separadorDecimalVirgula ?? this.separadorDecimalVirgula,
      transacoes: transacoes ?? this.transacoes,
      perfilUsado: perfilUsado ?? this.perfilUsado,
      paraReconciliacao: paraReconciliacao ?? this.paraReconciliacao,
      formato: formato ?? this.formato,
      instituicao: instituicao ?? this.instituicao,
      saldoFinal: saldoFinal ?? this.saldoFinal,
      ehCartao: ehCartao ?? this.ehCartao,
      cartaoId: limparCartao ? null : (cartaoId ?? this.cartaoId),
      ignoradas: ignoradas ?? this.ignoradas,
      ajustarSaldo: ajustarSaldo ?? this.ajustarSaldo,
    );
  }
}
