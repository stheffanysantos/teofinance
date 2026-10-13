import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema Material 3 do TeoFinance. Fonte: Manrope, números grandes em peso 800
/// com algarismos tabulares — ver `.claude/memory/design-system.md`.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppSurfaceTokens.light);

  static ThemeData dark() => _build(Brightness.dark, AppSurfaceTokens.dark);

  static ThemeData _build(Brightness brightness, AppSurfaceTokens tokens) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: tokens.ink,
      displayColor: tokens.ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor: tokens.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.petroleo,
        onPrimary: Colors.white,
        secondary: AppColors.lima,
        onSecondary: const Color(0xFF1B2300),
        error: AppColors.alerta,
        onError: Colors.white,
        surface: tokens.card,
        onSurface: tokens.ink,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: tokens.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: tokens.line, thickness: 1),
      extensions: [tokens],
    );
  }
}

extension AppSurfaceTokensX on BuildContext {
  AppSurfaceTokens get tokens =>
      Theme.of(this).extension<AppSurfaceTokens>() ?? AppSurfaceTokens.light;
}
