import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_session_providers.dart';

/// Exigida antes de liberar o dashboard quando a biometria está habilitada
/// (ver `.claude/docs/AUTH_FLOW.md`).
class BiometriaGateScreen extends ConsumerStatefulWidget {
  const BiometriaGateScreen({super.key});

  @override
  ConsumerState<BiometriaGateScreen> createState() => _BiometriaGateScreenState();
}

class _BiometriaGateScreenState extends ConsumerState<BiometriaGateScreen> {
  bool _tentando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tentarDesbloquear());
  }

  Future<void> _tentarDesbloquear() async {
    setState(() {
      _tentando = true;
      _erro = null;
    });

    final resultado = await ref.read(verificarBiometriaUseCaseProvider).autenticar();
    if (!mounted) return;

    resultado.match(
      (failure) => setState(() {
        _erro = failure.message;
        _tentando = false;
      }),
      (_) => ref.read(biometriaDesbloqueadaProvider.notifier).marcarDesbloqueada(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(Icons.fingerprint, size: 56, color: t.hero),
                Text(
                  'Confirme sua identidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.ink),
                ),
                if (_erro != null)
                  Text(_erro!, textAlign: TextAlign.center, style: TextStyle(color: t.neg, fontSize: 13)),
                FilledButton(
                  onPressed: _tentando ? null : _tentarDesbloquear,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.hero,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_tentando ? 'Verificando...' : 'Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
