import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_providers.dart';

/// Dispara uma sincronização assim que o `AppShell` é exibido (equivalente
/// a "pull ao abrir tela" — ver `.claude/agents/firebase-sync-engineer.md`).
/// Não bloqueia a UI: o app abre normalmente com o cache local enquanto a
/// sincronização roda em segundo plano.
class SyncGate extends ConsumerStatefulWidget {
  const SyncGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncGate> createState() => _SyncGateState();
}

class _SyncGateState extends ConsumerState<SyncGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncUiStateProvider.notifier).sincronizarAgora();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
