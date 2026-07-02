import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// CTA pill grande, full width (README seção 6.5).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.foreground = AppColors.onPrimary,
    this.icon,
    this.outlined = false,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color foreground;
  final IconData? icon;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: outlined ? AppColors.textSecondary : foreground),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            foregroundColor: AppColors.textSecondary,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: child,
      ),
    );
  }
}

/// Botão quadrado de ícone no header (voltar, chat, config...).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.color = AppColors.textPrimary,
    this.background = AppColors.card,
    this.borderColor = AppColors.border,
    this.badgeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color background;
  final Color borderColor;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 19, color: color)),
            if (badgeColor != null)
              Positioned(
                top: 7,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card padrão do design system.
class FtCard extends StatelessWidget {
  const FtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = AppColors.cardAlt,
    this.background = AppColors.card,
    this.radius = 16,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final Color background;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Ink(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: card,
    );
  }
}

/// Header de tela com botão voltar + título.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          SquareIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack!),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Badge/tag pequena (grupo muscular, TACO/OFF, CREF/CRN...).
class FtTag extends StatelessWidget {
  const FtTag(this.label, {super.key, required this.color, this.filled = true});

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: .12) : AppColors.cardAlt,
        borderRadius: BorderRadius.circular(6),
        border: filled ? Border.all(color: color.withValues(alpha: .45)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
          color: filled ? color : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Ícone consistente de grupo muscular: elipse anatômica + linhas de simetria.
/// Nunca fotos/imagens geradas (README seção 6.6).
class MuscleIcon extends StatelessWidget {
  const MuscleIcon({super.key, required this.color, this.size = 30});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MusclePainter(color),
    );
  }
}

class _MusclePainter extends CustomPainter {
  _MusclePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color.withValues(alpha: .15);
    final rect = Rect.fromCenter(
      center: Offset(16 * s, 15.5 * s),
      width: 20 * s,
      height: 25 * s,
    );
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, stroke);
    final thin = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(16 * s, 3.5 * s), Offset(16 * s, 27.5 * s), thin);
    final left = Path()
      ..moveTo(9.5 * s, 9.5 * s)
      ..cubicTo(11.7 * s, 11.9 * s, 11.7 * s, 17.1 * s, 9.5 * s, 20.5 * s);
    final right = Path()
      ..moveTo(22.5 * s, 9.5 * s)
      ..cubicTo(20.3 * s, 11.9 * s, 20.3 * s, 17.1 * s, 22.5 * s, 20.5 * s);
    canvas.drawPath(left, thin);
    canvas.drawPath(right, thin);
  }

  @override
  bool shouldRepaint(covariant _MusclePainter old) => old.color != color;
}

/// Logo do FitTrack (haltere em gradiente verde).
class FtLogo extends StatelessWidget {
  const FtLogo({super.key, this.size = 30, this.radius = 9});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.fitness_center, size: size * .55, color: AppColors.onPrimary),
    );
  }
}

/// Número grande em Space Grotesk (reps, cargas, calorias, timers).
class GroteskText extends StatelessWidget {
  const GroteskText(
    this.text, {
    super.key,
    this.fontSize = 20,
    this.color = AppColors.textPrimary,
    this.fontWeight = FontWeight.w700,
  });

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.grotesk(fontSize: fontSize, color: color, fontWeight: fontWeight),
    );
  }
}
