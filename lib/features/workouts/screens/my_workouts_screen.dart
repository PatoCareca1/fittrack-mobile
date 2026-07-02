import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

class MyWorkoutsScreen extends StatelessWidget {
  const MyWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Meus Treinos',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              SquareIconButton(
                icon: Icons.search,
                size: 42,
                color: AppColors.textSecondary,
                onTap: () => context.push('/treinos/explorar'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Divisão ABC · Hipertrofia',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          for (final w in MockData.workouts) ...[
            FtCard(
              onTap: () => context.push('/treinos/${w.letter}'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: w.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: w.color.withValues(alpha: .33)),
                  ),
                  child: Center(
                      child: Text(w.letter,
                          style: AppTheme.grotesk(fontSize: 22, color: w.color))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Treino ${w.letter}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(w.name,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 3),
                      Text('${w.exerciseCount} exercícios · ${w.sets} séries',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textDisabled),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          InkWell(
            onTap: () => context.push('/treinos/explorar'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Criar ou explorar rotina',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
