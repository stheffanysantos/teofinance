import 'package:flutter/material.dart';

/// Na web o app tem layout de celular: em telas largas ele fica numa coluna
/// central, com uma faixa avisando que os dados são fictícios.
class MolduraDemo extends StatelessWidget {
  const MolduraDemo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF101418),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ClipRect(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFC857),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: const Text(
                    'Demonstração · dados fictícios, salvos só no seu navegador',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF1B1B1B), fontSize: 11, fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
