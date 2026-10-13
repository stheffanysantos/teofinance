import 'package:flutter/material.dart';

/// Paleta base do design system TeoFinance ("direção 1" — petróleo + lima).
/// Fonte: Design System.dc.html exportado em 2026-10.
class AppColors {
  AppColors._();

  static const Color petroleo = Color(0xFF0F3D44);
  static const Color lima = Color(0xFFC6F135);
  static const Color positivo = Color(0xFF1A8A57);
  static const Color positivoEscuro = Color(0xFF4CD08A);
  static const Color alerta = Color(0xFFD9483A);
  static const Color alertaFundo = Color(0xFFFDEAE7);

  static const Color fundoClaro = Color(0xFFF6F7F5);
  static const Color cardClaro = Color(0xFFFFFFFF);
  static const Color inkClaro = Color(0xFF0E1F22);
  static const Color subClaro = Color(0xFF5E6F72);
  static const Color lineClaro = Color(0xFFE3E8E6);
  static const Color trackClaro = Color(0xFFE3E8E6);

  static const Color fundoEscuro = Color(0xFF0A1517);
  static const Color cardEscuro = Color(0xFF12262A);
  static const Color inkEscuro = Color(0xFFEEF4F2);
  static const Color subEscuro = Color(0xFF93A8AB);
  static const Color lineEscuro = Color(0xFF1E3438);
  static const Color heroEscuro = Color(0xFF174F58);
  static const Color trackEscuro = Color(0xFF1E3438);
}

/// Tokens de superfície que variam por tema — espelha o objeto `t` usado
/// nos protótipos .dc (bg/card/ink/sub/line/hero/accent/track/on).
class AppSurfaceTokens extends ThemeExtension<AppSurfaceTokens> {
  const AppSurfaceTokens({
    required this.bg,
    required this.card,
    required this.ink,
    required this.sub,
    required this.line,
    required this.hero,
    required this.accent,
    required this.accentInk,
    required this.track,
    required this.on,
    required this.off,
    required this.pos,
    required this.posBg,
    required this.posOnHero,
    required this.neg,
    required this.negBg,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color sub;
  final Color line;
  final Color hero;
  final Color accent;
  final Color accentInk;
  final Color track;
  final Color on;
  final Color off;

  /// Verde de valores positivos (receita, progresso, variação boa).
  final Color pos;
  final Color posBg;
  final Color posOnHero;

  /// Vermelho de valores negativos/alerta (despesa, limite estourado).
  final Color neg;
  final Color negBg;

  static const light = AppSurfaceTokens(
    bg: AppColors.fundoClaro,
    card: AppColors.cardClaro,
    ink: AppColors.inkClaro,
    sub: AppColors.subClaro,
    line: AppColors.lineClaro,
    hero: AppColors.petroleo,
    accent: AppColors.lima,
    accentInk: Color(0xFF1B2300),
    track: AppColors.trackClaro,
    on: AppColors.positivo,
    off: Color(0xFFB9C4C2),
    pos: AppColors.positivo,
    posBg: Color(0xFFE3F4EB),
    posOnHero: Color(0xFF7BE3AB),
    neg: AppColors.alerta,
    negBg: AppColors.alertaFundo,
  );

  static const dark = AppSurfaceTokens(
    bg: AppColors.fundoEscuro,
    card: AppColors.cardEscuro,
    ink: AppColors.inkEscuro,
    sub: AppColors.subEscuro,
    line: AppColors.lineEscuro,
    hero: AppColors.heroEscuro,
    accent: AppColors.lima,
    accentInk: Color(0xFF1B2300),
    track: AppColors.trackEscuro,
    on: AppColors.positivoEscuro,
    off: Color(0xFF3A5358),
    pos: AppColors.positivoEscuro,
    posBg: Color(0xFF14352A),
    posOnHero: Color(0xFF7BE3AB),
    neg: Color(0xFFFF7A6B),
    negBg: Color(0xFF3A1F1D),
  );

  @override
  AppSurfaceTokens copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? sub,
    Color? line,
    Color? hero,
    Color? accent,
    Color? accentInk,
    Color? track,
    Color? on,
    Color? off,
    Color? pos,
    Color? posBg,
    Color? posOnHero,
    Color? neg,
    Color? negBg,
  }) {
    return AppSurfaceTokens(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      sub: sub ?? this.sub,
      line: line ?? this.line,
      hero: hero ?? this.hero,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      track: track ?? this.track,
      on: on ?? this.on,
      off: off ?? this.off,
      pos: pos ?? this.pos,
      posBg: posBg ?? this.posBg,
      posOnHero: posOnHero ?? this.posOnHero,
      neg: neg ?? this.neg,
      negBg: negBg ?? this.negBg,
    );
  }

  @override
  AppSurfaceTokens lerp(ThemeExtension<AppSurfaceTokens>? other, double t) {
    if (other is! AppSurfaceTokens) return this;
    return AppSurfaceTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      sub: Color.lerp(sub, other.sub, t)!,
      line: Color.lerp(line, other.line, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      track: Color.lerp(track, other.track, t)!,
      on: Color.lerp(on, other.on, t)!,
      off: Color.lerp(off, other.off, t)!,
      pos: Color.lerp(pos, other.pos, t)!,
      posBg: Color.lerp(posBg, other.posBg, t)!,
      posOnHero: Color.lerp(posOnHero, other.posOnHero, t)!,
      neg: Color.lerp(neg, other.neg, t)!,
      negBg: Color.lerp(negBg, other.negBg, t)!,
    );
  }
}
