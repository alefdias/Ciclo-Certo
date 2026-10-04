import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../models/enums.dart';

/// Card branco com borda suave e sombra leve.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Botão com o degradê da marca.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícone colorido da categoria do medicamento.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 48});

  final MedicationCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = CategoryStyle.of(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: s.soft,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(s.icon, color: s.color, size: size * 0.5),
    );
  }
}

/// Selo de status (sempre com ícone + texto — não depende só da cor, §42).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.late = false});

  final DoseStatus status;
  final bool late;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, IconData icon, String label) = switch (status) {
      DoseStatus.taken => (AppColors.success, AppColors.successSoft, Icons.check_circle_rounded, 'Tomado'),
      DoseStatus.skipped => (AppColors.textSecondary, AppColors.surfaceSoft, Icons.redo_rounded, 'Pulado'),
      DoseStatus.snoozed => (AppColors.blue, AppColors.infoSoft, Icons.snooze_rounded, 'Adiado'),
      DoseStatus.missed => (AppColors.danger, AppColors.dangerSoft, Icons.close_rounded, 'Não registrado'),
      DoseStatus.pending when late =>
        (AppColors.danger, AppColors.dangerSoft, Icons.schedule_rounded, 'Atrasado'),
      DoseStatus.pending => (AppColors.warning, AppColors.warningSoft, Icons.schedule_rounded, 'Aguardando'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Título de seção com ação opcional.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Logo "V" com degradê + nome.
class VelixLogo extends StatelessWidget {
  const VelixLogo({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (r) => AppColors.brandGradient.createShader(r),
          child: Text('C',
              style: TextStyle(
                  fontSize: size * 1.3, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
        ),
        const SizedBox(width: 6),
        Text('Ciclo ',
            style: TextStyle(
                fontSize: size, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text('Certo',
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: AppColors.teal)),
      ],
    );
  }
}

/// Barra de progresso com degradê.
class GradientProgress extends StatelessWidget {
  const GradientProgress({super.key, required this.value, this.height = 8, this.danger = false});

  final double value;
  final double height;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.surfaceSoft,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: danger
                    ? const LinearGradient(colors: [Color(0xFFFB7185), AppColors.danger])
                    : AppColors.brandGradient,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vazio padrão.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: AppColors.surfaceSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: AppColors.violet),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
