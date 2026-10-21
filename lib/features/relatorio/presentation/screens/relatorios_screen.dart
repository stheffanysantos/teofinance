import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/relatorio/data/services/relatorio_csv_service.dart';
import 'package:teofinance/features/relatorio/data/services/relatorio_pdf_service.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Exporta o resumo de um mês em PDF (para ler/compartilhar) ou CSV (planilha).
class RelatoriosScreen extends ConsumerStatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  ConsumerState<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends ConsumerState<RelatoriosScreen> {
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  bool _gerando = false;

  void _mover(int meses) =>
      setState(() => _mes = DateTime(_mes.year, _mes.month + meses));

  String _nomeBase(RelatorioMensal r) =>
      'teofinance_${r.ano}_${r.mes.toString().padLeft(2, '0')}';

  Future<void> _exportar(RelatorioMensal relatorio, {required bool pdf}) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _gerando = true);
    try {
      final bytes = pdf
          ? await const RelatorioPdfService().gerar(relatorio)
          // BOM para o Excel reconhecer UTF-8 e não quebrar os acentos.
          : Uint8List.fromList(
              utf8.encode('﻿${const RelatorioCsvService().gerar(relatorio)}'),
            );
      final salvo = await FilePicker.saveFile(
        fileName: '${_nomeBase(relatorio)}.${pdf ? 'pdf' : 'csv'}',
        bytes: bytes,
        mimeType: pdf ? 'application/pdf' : 'text/csv',
        dialogTitle: 'Salvar relatório',
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            salvo == null ? 'Exportação cancelada.' : 'Relatório salvo.',
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível gerar o relatório.')),
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final transacoes = ref.watch(transacoesStreamProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(
          'Relatórios',
          style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: transacoes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              'Não foi possível carregar as transações.',
              style: TextStyle(color: t.neg),
            ),
          ),
          data: (todas) {
            final r = RelatorioMensal.de(
              todas,
              ano: _mes.year,
              mes: _mes.month,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _mover(-1),
                      icon: Icon(Icons.chevron_left, color: t.ink),
                    ),
                    Text(
                      RelatorioPdfService.titulo(r),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _mover(1),
                      icon: Icon(Icons.chevron_right, color: t.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.card,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      _Linha('Receitas', formatCurrency(r.receitas), t.pos),
                      _Linha('Despesas', formatCurrency(r.despesas), t.neg),
                      _Linha('Saldo', formatCurrency(r.saldo), t.ink),
                      _Linha('Lançamentos', '${r.transacoes.length}', t.sub),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (r.vazio)
                  Text(
                    'Nenhum lançamento neste mês.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.sub),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: _gerando ? null : () => _exportar(r, pdf: true),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Exportar PDF'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _gerando ? null : () => _exportar(r, pdf: false),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Exportar CSV (planilha)'),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Compras divididas entram só com a sua parte. O arquivo é gerado no aparelho '
                  'e só vai para onde você escolher salvar.',
                  style: TextStyle(fontSize: 12, color: t.sub, height: 1.4),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: TextStyle(color: context.tokens.sub)),
        Text(
          valor,
          style: TextStyle(fontWeight: FontWeight.w700, color: cor),
        ),
      ],
    );
  }
}
