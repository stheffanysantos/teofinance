import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/discreet_mode_provider.dart';

/// Texto de valor monetário que respeita o Modo Discreto: com o modo ligado,
/// mostra [kMascaraValor] no lugar de [text]. [prefix] e [suffix] (rótulos como
/// "meta " ou " / mês") continuam visíveis.
class AppAmountText extends ConsumerWidget {
  const AppAmountText(
    this.text, {
    super.key,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discreto = ref.watch(modoDiscretoProvider);
    return Text(
      '$prefix${discreto ? kMascaraValor : text}$suffix',
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
