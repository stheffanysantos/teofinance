import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Tela de login/cadastro — e-mail e senha via Firebase Authentication.
/// Ver `.claude/docs/AUTH_FLOW.md`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isCadastro = false;
  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submeter() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    final email = _emailController.text;
    final senha = _senhaController.text;
    final resultado = _isCadastro
        ? await ref.read(cadastrarUseCaseProvider).call(email: email, senha: senha)
        : await ref.read(loginUseCaseProvider).call(email: email, senha: senha);

    if (!mounted) return;
    resultado.match(
      (failure) => setState(() {
        _erro = failure.message;
        _loading = false;
      }),
      (_) => setState(() => _loading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: Icon(Icons.savings_outlined, color: t.accent, size: 30),
                ),
                Text(
                  _isCadastro ? 'Criar conta' : 'Entrar no TeoFinance',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: t.ink),
                ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                if (_erro != null)
                  Text(_erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
                FilledButton(
                  onPressed: _loading ? null : _submeter,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.hero,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isCadastro ? 'Criar conta' : 'Entrar',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                ),
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _isCadastro = !_isCadastro),
                  child: Text(
                    _isCadastro ? 'Já tenho conta · Entrar' : 'Não tenho conta · Criar uma',
                    style: TextStyle(color: t.sub, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
