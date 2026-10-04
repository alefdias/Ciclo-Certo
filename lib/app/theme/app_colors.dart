import 'package:flutter/material.dart';

import '../../models/enums.dart';

/// Paleta oficial do Velix Med (layout v2: fundo branco + degradê
/// violeta → azul → turquesa + tons pastel nas categorias).
abstract final class AppColors {
  // Marca (Feminino focado em Rosa)
  static const violet = Color(0xFFF43F5E); // Rose 500
  static const blue = Color(0xFFFB7185); // Rose 400
  static const teal = Color(0xFFE11D48); // Rose 600

  // Superfícies
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF7F6FE); // lavanda quase branca
  static const border = Color(0xFFECEAF5);

  // Texto
  static const textPrimary = Color(0xFF0F172A); // azul-marinho
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  // Estados
  static const success = Color(0xFF10B981);
  static const successSoft = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFEF3C7);
  static const danger = Color(0xFFF43F5E); // coral
  static const dangerSoft = Color(0xFFFFE4E6);
  static const info = blue;
  static const infoSoft = Color(0xFFDBEAFE);
  static const pause = Color(0xFF7DD3FC);
  static const pauseSoft = Color(0xFFE0F2FE);

  static const brandGradient = LinearGradient(
    colors: [violet, blue, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Variação mais curta
  static const heroGradient = LinearGradient(
    colors: [Color(0xFFBE123C), Color(0xFFE11D48), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Cor + fundo pastel + ícone de cada categoria.
class CategoryStyle {
  const CategoryStyle(this.color, this.soft, this.icon);
  final Color color;
  final Color soft;
  final IconData icon;

  static CategoryStyle of(MedicationCategory c) => switch (c) {
        MedicationCategory.pill =>
          const CategoryStyle(Color(0xFFEC4899), Color(0xFFFCE7F3), Icons.favorite_rounded),
        MedicationCategory.injection =>
          const CategoryStyle(Color(0xFF8B5CF6), Color(0xFFEDE9FE), Icons.vaccines_rounded),
        MedicationCategory.patch =>
          const CategoryStyle(Color(0xFFF43F5E), Color(0xFFFFE4E6), Icons.healing_rounded),
        MedicationCategory.ring =>
          const CategoryStyle(Color(0xFFD946EF), Color(0xFFFAE8FF), Icons.data_usage_rounded),
        MedicationCategory.iud =>
          const CategoryStyle(Color(0xFF14B8A6), Color(0xFFCCFBF1), Icons.device_thermostat_rounded),
        MedicationCategory.contraceptive =>
          const CategoryStyle(Color(0xFFEC4899), Color(0xFFFCE7F3), Icons.favorite_rounded),
        MedicationCategory.continuousUse =>
          const CategoryStyle(Color(0xFF8B5CF6), Color(0xFFEDE9FE), Icons.loop_rounded),
        MedicationCategory.painFever =>
          const CategoryStyle(Color(0xFFEF4444), Color(0xFFFEE2E2), Icons.local_fire_department_rounded),
        MedicationCategory.antibiotic =>
          const CategoryStyle(Color(0xFF3B82F6), Color(0xFFDBEAFE), Icons.medication_rounded),
        MedicationCategory.vitamins =>
          const CategoryStyle(Color(0xFFF59E0B), Color(0xFFFEF3C7), Icons.wb_sunny_rounded),
        MedicationCategory.other =>
          const CategoryStyle(Color(0xFFF59E0B), Color(0xFFFEF3C7), Icons.stars_rounded),
      };
}
