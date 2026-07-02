import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

/// Linha de exercício usada no detalhe do treino e no plano atribuído.
/// `readOnly` mostra cadeado no lugar do chevron (RN10 — plano de personal).
class ExerciseRow extends StatelessWidget {
  const ExerciseRow({
    super.key,
    required this.exercise,
    this.readOnly = false,
    this.onTap,
  });

  final MockExercise exercise;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: readOnly ? null : onTap,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardAlt),
          ),
          child: Center(child: MuscleIcon(color: exercise.color, size: 30)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.name,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                FtTag(exercise.muscle, color: exercise.color),
                const SizedBox(width: 6),
                FtTag(exercise.equipment, color: AppColors.textSecondary, filled: false),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(exercise.scheme,
                style: AppTheme.grotesk(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 1),
            Text('${exercise.load} · ${exercise.rest}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(width: 4),
        Icon(readOnly ? Icons.lock_outline : Icons.chevron_right,
            size: readOnly ? 15 : 20, color: AppColors.textDisabled),
      ]),
    );
  }
}
