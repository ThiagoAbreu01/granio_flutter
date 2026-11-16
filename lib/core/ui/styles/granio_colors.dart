import 'package:flutter/material.dart';

/// Paleta da marca Granio (login, cadastro e home).
///
/// Escuro é o tema padrão do app; o claro reaproveita os mesmos acentos.
/// Use `GranioColors.of(context)` para pegar a variante do tema atual.
class GranioColors {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color textMuted;

  const GranioColors._({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.textMuted,
  });

  static const dark = GranioColors._(
    background: Color(0xFF0B0F14),
    surface: Color(0xFF141A22),
    surfaceAlt: Color(0xFF1B232D),
    border: Color(0xFF263040),
    text: Color(0xFFF1F5F9),
    textMuted: Color(0xFF8A97A8),
  );

  static const light = GranioColors._(
    background: Color(0xFFF4F7F6),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDF2F0),
    border: Color(0xFFDCE4E1),
    text: Color(0xFF0B1A14),
    textMuted: Color(0xFF5F6F69),
  );

  static GranioColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  // Acentos (iguais nos dois temas).
  static const emerald = Color(0xFF10B981);
  static const teal = Color(0xFF22D3EE);
  static const gold = Color(0xFFF5C451);
  static const income = Color(0xFF34D399);
  static const expense = Color(0xFFF87171);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF0EA5B7)],
  );
}
