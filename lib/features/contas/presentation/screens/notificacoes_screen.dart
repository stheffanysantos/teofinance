import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/contas/presentation/providers/lembretes_providers.dart';

/// Lembretes de contas a pagar: liga/desliga, horário e um teste na hora.
class NotificacoesScreen extends ConsumerStatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  ConsumerState<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends ConsumerState<NotificacoesScreen> {
  bool? _permissao;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _conferirPermissao();
  }

  Future<void> _conferirPermissao() async {
    final ok = await ref.read(notificacaoServiceProvider).permissaoConcedida();
    if (mounted) setState(() => _permissao = ok);
  }

  Future<void> _alternar(bool ligar) async {
    if (ligar && _permissao != true) {
      final ok = await ref.read(notificacaoServiceProvider).pedirPermissao();
      if (!mounted) return;
      setState(() => _permissao = ok);
      if (!ok) {
        setState(() => _aviso = 'Sem a permissão do sistema não dá para avisar. Libere em Configurações > Apps > teofinance > Notificações.');
        return;
      }
    }
    setState(() => _aviso = null);
    await ref.read(configLembretesProvider.notifier).definirAtivo(ligar);
  }

  Future<void> _testar() async {
    final service = ref.read(notificacaoServiceProvider);
    if (!await service.permissaoConcedida() && !await service.pedirPermissao()) {
      if (mounted) setState(() => _aviso = 'Permissão de notificação negada.');
      return;
    }
    await service.mostrarAgora(titulo: 'Teste do TeoFinance', corpo: 'Se você leu isto, os lembretes funcionam.');
    if (mounted) setState(() => _aviso = null);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final config = ref.watch(configLembretesProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Notificações', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Lembretes de vencimento das suas contas a pagar. São agendados no próprio aparelho, '
              'funcionam sem internet e nada sai do seu celular.',
              style: TextStyle(fontSize: 13.5, color: t.sub, height: 1.4),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: config.ativo && _permissao == true,
              onChanged: _alternar,
              title: Text('Lembretes de contas', style: TextStyle(color: t.ink, fontWeight: FontWeight.w600)),
              subtitle: Text(
                _permissao == false ? 'Permissão do sistema pendente' : 'Aviso antes do vencimento e no dia',
                style: TextStyle(color: t.sub),
              ),
            ),
            ListTile(
              title: Text('Horário do aviso', style: TextStyle(color: t.ink, fontWeight: FontWeight.w600)),
              trailing: DropdownButton<int>(
                value: config.hora,
                items: [
                  for (var h = 6; h <= 21; h++) DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00')),
                ],
                onChanged: config.ativo ? (h) => ref.read(configLembretesProvider.notifier).definirHora(h ?? config.hora) : null,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _testar,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Enviar notificação de teste'),
            ),
            if (_aviso != null) ...[
              const SizedBox(height: 12),
              Text(_aviso!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            Text(
              'Em alguns celulares a economia de bateria pode atrasar os avisos. Se isso acontecer, '
              'tire o TeoFinance da otimização de bateria nas configurações do sistema.',
              style: TextStyle(fontSize: 12.5, color: t.sub, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
