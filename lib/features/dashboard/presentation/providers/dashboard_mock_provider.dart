import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Cor do anel de progresso de uma meta no carrossel "Metas ativas" do
/// Dashboard. Dados reais já vêm de `metasStreamProvider`
/// (ver `features/meta/`) — este arquivo só guarda esse helper visual.
Color goalRingColor(AppSurfaceTokens tokens, String key) {
  switch (key) {
    case 'accent':
      return AppColors.lima;
    case 'neg':
      return tokens.neg;
    default:
      return tokens.pos;
  }
}
