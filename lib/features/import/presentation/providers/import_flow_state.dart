import 'dart:typed_data';

import '../../domain/entities/campo_coluna.dart';
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

  int get quantidadeSemCategoria => transacoes.where((t) => t.precisaCategoria).length;

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
    );
  }
}
