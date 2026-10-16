import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../reconciliation/presentation/screens/reconciliation_screen.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/modelo_partida_banco.dart';
import '../../domain/entities/perfil_banco.dart';
import '../providers/import_flow_notifier.dart';
import '../providers/import_flow_state.dart';

/// Tela de importação de extrato — cobre os passos 1-7 de
/// `.claude/docs/IMPORT_FLOW.md`. Serve para qualquer banco: a diferença
/// entre eles é só o `PerfilBanco` que o usuário confirma aqui.
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final state = ref.watch(importFlowProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Importar extrato', style: TextStyle(color: t.ink)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      body: SafeArea(
        child: switch (state.etapa) {
          ImportEtapa.selecionandoArquivo => _SelecaoArquivo(state: state),
          ImportEtapa.mapeandoColunas => _MapeamentoColunas(state: state),
          ImportEtapa.revisando => _Revisao(state: state),
          ImportEtapa.concluido => _Concluido(state: state),
        },
      ),
    );
  }
}

class _SelecaoArquivo extends ConsumerWidget {
  const _SelecaoArquivo({required this.state});

  final ImportFlowState state;

  Future<void> _escolherArquivo(WidgetRef ref) async {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    if (arquivo == null) return;

    final bytes = await arquivo.readAsBytes();
    await ref.read(importFlowProvider.notifier).analisarArquivo(
          bytes: bytes,
          nomeArquivo: arquivo.name,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(Icons.upload_file_outlined, size: 48, color: t.hero),
            Text(
              'Escolha o arquivo CSV exportado pelo seu banco (Nubank, Banco do Brasil, '
              'ou qualquer outro — o mapeamento de colunas é feito na próxima tela).',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.sub, fontSize: 13.5, height: 1.5),
            ),
            if (state.erro != null)
              Text(state.erro!, style: TextStyle(color: t.neg, fontSize: 13)),
            FilledButton(
              onPressed: state.carregando ? null : () => _escolherArquivo(ref),
              style: FilledButton.styleFrom(
                backgroundColor: t.hero,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(state.carregando ? 'Lendo arquivo...' : 'Selecionar arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapeamentoColunas extends ConsumerWidget {
  const _MapeamentoColunas({required this.state});

  final ImportFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final preview = state.preview!;
    final notifier = ref.read(importFlowProvider.notifier);
    final perfilSugerido = preview.perfilCompativel != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          if (perfilSugerido)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: t.posBg, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Reconhecemos o perfil "${preview.perfilCompativel!.nomeBanco}" — mapeamento aplicado '
                'automaticamente. Confira e ajuste se precisar.',
                style: TextStyle(color: t.pos, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          Text(
            'Modelos de partida (opcional)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: t.sub),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final modelo in kModelosPartidaBanco)
                ActionChip(
                  label: Text(modelo.nomeBanco),
                  onPressed: () => notifier.aplicarModeloPartida(modelo),
                  backgroundColor: t.track,
                  labelStyle: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w700),
                ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Nome do perfil (ex.: Nubank, Banco X)'),
            controller: TextEditingController(text: state.nomePerfil)
              ..selection = TextSelection.collapsed(offset: state.nomePerfil.length),
            onChanged: notifier.definirNomePerfil,
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: state.formatoData,
                  decoration: const InputDecoration(labelText: 'Formato de data'),
                  items: kFormatosDataSuportados
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => v != null ? notifier.definirFormatoData(v) : null,
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<bool>(
                  initialValue: state.separadorDecimalVirgula,
                  decoration: const InputDecoration(labelText: 'Decimal'),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('1.234,56')),
                    DropdownMenuItem(value: false, child: Text('1234.56')),
                  ],
                  onChanged: (v) => v != null ? notifier.definirSeparadorDecimal(v) : null,
                ),
              ),
            ],
          ),
          Text(
            'Diga o que cada coluna significa',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
          ),
          Container(
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < preview.cabecalho.length; i++)
                  _LinhaColuna(
                    indice: i,
                    titulo: preview.cabecalho[i],
                    amostra: preview.linhasAmostra.isNotEmpty && i < preview.linhasAmostra.first.length
                        ? preview.linhasAmostra.first[i]
                        : '',
                    valor: state.mapeamentoRascunho[i] ?? CampoColuna.ignorar,
                    showTopBorder: i > 0,
                    onChanged: (campo) => notifier.definirCampoColuna(i, campo),
                  ),
              ],
            ),
          ),
          if (state.erro != null)
            Text(state.erro!, style: TextStyle(color: t.neg, fontSize: 13)),
          FilledButton(
            onPressed: state.carregando ? null : notifier.confirmarMapeamentoEImportar,
            style: FilledButton.styleFrom(
              backgroundColor: t.hero,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(state.carregando ? 'Importando...' : 'Salvar perfil e importar'),
          ),
        ],
      ),
    );
  }
}

class _LinhaColuna extends StatelessWidget {
  const _LinhaColuna({
    required this.indice,
    required this.titulo,
    required this.amostra,
    required this.valor,
    required this.showTopBorder,
    required this.onChanged,
  });

  final int indice;
  final String titulo;
  final String amostra;
  final CampoColuna valor;
  final bool showTopBorder;
  final ValueChanged<CampoColuna> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: showTopBorder ? Border(top: BorderSide(color: t.line)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: t.ink)),
                Text(
                  amostra,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: t.sub),
                ),
              ],
            ),
          ),
          DropdownButton<CampoColuna>(
            value: valor,
            underline: const SizedBox.shrink(),
            items: CampoColuna.values
                .map((c) => DropdownMenuItem(value: c, child: Text(_rotulo(c))))
                .toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ],
      ),
    );
  }

  String _rotulo(CampoColuna campo) => switch (campo) {
        CampoColuna.data => 'Data',
        CampoColuna.descricao => 'Descrição',
        CampoColuna.valor => 'Valor',
        CampoColuna.categoria => 'Categoria',
        CampoColuna.ignorar => 'Ignorar',
      };
}

class _Revisao extends ConsumerWidget {
  const _Revisao({required this.state});

  final ImportFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final notifier = ref.read(importFlowProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(
            '${state.transacoes.length} transações encontradas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.ink),
          ),
          if (state.quantidadeSemCategoria > 0)
            Text(
              '${state.quantidadeSemCategoria} ficarão marcadas como "sem categoria" — você categoriza '
              'depois em Transações.',
              style: TextStyle(color: t.sub, fontSize: 13),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: state.transacoes.length,
              separatorBuilder: (_, _) => Divider(color: t.line, height: 1),
              itemBuilder: (context, i) {
                final transacao = state.transacoes[i];
                return ListTile(
                  title: Text(transacao.descricao, style: TextStyle(color: t.ink)),
                  subtitle: Text(
                    '${transacao.data.day.toString().padLeft(2, '0')}/'
                    '${transacao.data.month.toString().padLeft(2, '0')}/${transacao.data.year}'
                    '${transacao.precisaCategoria ? '' : ' · ${transacao.categoria}'}',
                    style: TextStyle(color: t.sub),
                  ),
                  trailing: Text(
                    transacao.valor.toStringAsFixed(2),
                    style: TextStyle(
                      color: transacao.valor < 0 ? t.neg : t.pos,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
          FilledButton(
            onPressed: notifier.confirmarImportacao,
            style: FilledButton.styleFrom(
              backgroundColor: t.hero,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar importação'),
          ),
          OutlinedButton(
            onPressed: notifier.confirmarParaReconciliacao,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reconciliar com minhas transações'),
          ),
        ],
      ),
    );
  }
}

class _Concluido extends ConsumerWidget {
  const _Concluido({required this.state});

  final ImportFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(Icons.check_circle_outline, size: 56, color: t.pos),
            Text(
              state.paraReconciliacao
                  ? '${state.transacoes.length} linhas do extrato prontas para reconciliar!'
                  : '${state.transacoes.length} transações importadas!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.ink),
            ),
            Text(
              state.paraReconciliacao
                  ? 'Elas não viram transações: serão comparadas com os lançamentos que você cadastrou.'
                  : 'Elas já aparecem em Contas. A sincronização com a nuvem acontece automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.sub, fontSize: 13),
            ),
            if (state.paraReconciliacao)
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ReconciliationScreen()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Abrir reconciliação'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: FilledButton.styleFrom(
                backgroundColor: t.hero,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Concluir'),
            ),
          ],
        ),
      ),
    );
  }
}
