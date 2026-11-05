import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cartao/presentation/providers/cartao_providers.dart';
import '../../../reconciliation/presentation/screens/reconciliation_screen.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/modelo_partida_banco.dart';
import '../../domain/entities/perfil_banco.dart';
import '../../domain/services/pagamento_fatura.dart';
import '../../domain/usecases/detectar_duplicatas_usecase.dart';
import '../providers/import_flow_notifier.dart';
import '../providers/import_flow_state.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

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
    // Sem filtro por extensão: o seletor do Android filtra por tipo MIME, e
    // `.ofx` não tem um — o arquivo aparecia desabilitado. O formato (OFX ou
    // CSV) é detectado pelo conteúdo em `ImportarExtratoUseCase.detectarFormato`.
    final arquivo = await FilePicker.pickFile();
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
              'Escolha o extrato exportado pelo seu banco, em OFX ou CSV. O OFX é lido '
              'direto; no CSV (Nubank, Banco do Brasil ou qualquer outro) você '
              'mapeia as colunas na próxima tela.',
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

  /// Se parte do arquivo já foi importada, pergunta antes de duplicar. Nunca
  /// descarta nada sozinho: quem decide é o usuário.
  Future<void> _confirmar(BuildContext context, WidgetRef ref, DestinoImportacao destino) async {
    final notifier = ref.read(importFlowProvider.notifier);
    final repetidas = await notifier.contarDuplicadas(destino);
    if (!context.mounted) return;

    var pular = false;
    if (repetidas > 0) {
      final escolha = await showDialog<_EscolhaDuplicadas>(
        context: context,
        builder: (_) => _DuplicadasDialog(repetidas: repetidas, total: state.transacoes.length),
      );
      if (escolha == null || escolha == _EscolhaDuplicadas.cancelar) return;
      pular = escolha == _EscolhaDuplicadas.soNovas;
    }

    if (destino == DestinoImportacao.transacoes) {
      await notifier.confirmarImportacao(pularDuplicadas: pular);
    } else {
      await notifier.confirmarParaReconciliacao(pularDuplicadas: pular);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final notifier = ref.read(importFlowProvider.notifier);
    final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
    final saldoFinal = state.saldoFinal;
    final saldoArquivo = state.entradas - state.saidas;
    final ignoradas = state.ignoradas.length;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(
            '${state.efetivas.length} transações para importar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.ink),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              spacing: 6,
              children: [
                _LinhaTotal(rotulo: 'Entradas', valor: formatCurrency(state.entradas), cor: t.pos),
                _LinhaTotal(rotulo: 'Saídas', valor: formatCurrency(state.saidas), cor: t.neg),
                Divider(color: t.line, height: 8),
                _LinhaTotal(rotulo: 'Saldo do arquivo', valor: formatCurrency(saldoArquivo, comSinal: true), cor: t.ink, forte: true),
                if (saldoFinal != null && !state.ehCartao)
                  _LinhaTotal(rotulo: 'Saldo final no banco', valor: formatCurrency(saldoFinal), cor: t.ink),
              ],
            ),
          ),
          if (ignoradas > 0)
            Text(
              '$ignoradas ${ignoradas == 1 ? 'linha fora' : 'linhas fora'} da importação: pagamento de fatura de cartão. '
              'As compras do cartão já contam como despesa, então não entram de novo. Marque a linha para incluir.',
              style: TextStyle(color: t.sub, fontSize: 12.5),
            ),
          if (saldoFinal != null && !state.ehCartao)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: state.ajustarSaldo,
              onChanged: (v) => notifier.definirAjustarSaldo(v ?? false),
              title: Text('Ajustar meu saldo para ${formatCurrency(saldoFinal)}', style: TextStyle(color: t.ink, fontSize: 14)),
              subtitle: Text('Use se este for o extrato mais recente da conta.', style: TextStyle(color: t.sub, fontSize: 12)),
            ),
          if (state.ehCartao || cartoes.isNotEmpty)
            DropdownButtonFormField<String?>(
              initialValue: cartoes.any((c) => c.id == state.cartaoId) ? state.cartaoId : null,
              decoration: InputDecoration(
                labelText: state.ehCartao ? 'Esta é uma fatura de cartão: qual cartão?' : 'Vincular a um cartão (opcional)',
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Nenhum')),
                for (final c in cartoes) DropdownMenuItem<String?>(value: c.id, child: Text(c.nome)),
              ],
              onChanged: notifier.definirCartao,
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
                final fora = state.ignoradas.contains(i);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: !fora,
                  onChanged: (_) => notifier.alternarIgnorada(i),
                  secondary: AppAmountText(
                    transacao.valor.toStringAsFixed(2),
                    style: TextStyle(
                      color: fora ? t.sub : (transacao.valor < 0 ? t.neg : t.pos),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  title: Text(transacao.descricao, style: TextStyle(color: t.ink)),
                  subtitle: Text(
                    '${transacao.data.day.toString().padLeft(2, '0')}/'
                    '${transacao.data.month.toString().padLeft(2, '0')}/${transacao.data.year}'
                    '${transacao.precisaCategoria ? '' : ' · ${transacao.categoria}'}'
                    '${pareceTransferenciaDeFatura(transacao.descricao) ? ' · pagamento de fatura' : ''}',
                    style: TextStyle(color: t.sub),
                  ),
                );
              },
            ),
          ),
          FilledButton(
            onPressed: () => _confirmar(context, ref, DestinoImportacao.transacoes),
            style: FilledButton.styleFrom(
              backgroundColor: t.hero,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar importação'),
          ),
          OutlinedButton(
            onPressed: () => _confirmar(context, ref, DestinoImportacao.reconciliacao),
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

class _LinhaTotal extends StatelessWidget {
  const _LinhaTotal({required this.rotulo, required this.valor, required this.cor, this.forte = false});

  final String rotulo;
  final String valor;
  final Color cor;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(child: Text(rotulo, style: TextStyle(color: t.sub, fontSize: 13.5))),
        AppAmountText(valor, style: TextStyle(color: cor, fontWeight: forte ? FontWeight.w800 : FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

enum _EscolhaDuplicadas { soNovas, todas, cancelar }

class _DuplicadasDialog extends StatelessWidget {
  const _DuplicadasDialog({required this.repetidas, required this.total});

  final int repetidas;
  final int total;

  @override
  Widget build(BuildContext context) {
    final novas = total - repetidas;
    return AlertDialog(
      title: const Text('Parte do arquivo já foi importada'),
      content: Text(
        '$repetidas de $total linhas têm a mesma data, valor e descrição de algo que já está no app. '
        '${novas == 0 ? 'Nenhuma é nova.' : 'Só $novas ${novas == 1 ? 'é nova' : 'são novas'}.'}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_EscolhaDuplicadas.cancelar),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_EscolhaDuplicadas.todas),
          child: const Text('Importar todas'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_EscolhaDuplicadas.soNovas),
          child: Text(novas == 0 ? 'Não importar' : 'Só as novas'),
        ),
      ],
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
