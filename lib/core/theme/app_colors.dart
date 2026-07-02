import 'package:flutter/material.dart';

/// Design tokens do FitTrack — seção 6 do README / FitTrack_Decisoes_v2.pdf.
/// Não introduzir cores fora desta paleta.
abstract class AppColors {
  static const primary = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF15803D);
  static const accent = Color(0xFFF97316);
  static const background = Color(0xFF0F172A);
  static const card = Color(0xFF111C2C);
  static const cardAlt = Color(0xFF1E293B);
  static const surfaceDeep = Color(0xFF0C1220);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const textDisabled = Color(0xFF475569);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFEAB308);
  static const error = Color(0xFFEF4444);
  static const blueAccent = Color(0xFF3B82F6);
  static const border = Color(0xFF334155);

  // Tons de apoio usados no protótipo aprovado
  static const greenBgSoft = Color(0xFF0F2A1A); // fundo suave verde
  static const orangeBgSoft = Color(0xFF1E1505); // fundo suave laranja
  static const blueBgSoft = Color(0xFF0D1F3A); // fundo suave azul
  static const blueBorder = Color(0xFF1D4ED8);
  static const onAccent = Color(0xFF1A0C02); // texto sobre laranja
  static const onPrimary = Color(0xFF05140A); // texto sobre verde
}
