import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';
import '../widgets/exercise_row.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final workout = MockData.workouts.firstWhere(
      (w) => w.letter == letter,
      orElse: () => MockData.workouts.first,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              ScreenHeader(
                title: 'Treino ${workout.letter} · ${workout.name}',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 16),
              Row(children: [
                _Stat(value: '${workout.exerciseCount}', label: 'exercícios'),
                const SizedBox(width: 10),
                const _Stat(value: '~50', label: 'minutos'),
                const SizedBox(width: 10),
                _Stat(value: '${workout.sets}', label: 'séries'),
              ]),
              const SizedBox(height: 20),
              const Text('Exercícios',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final ex in workout.exercises) ...[
                ExerciseRow(
                  exercise: ex,
                  onTap: () => context.push('/treinos/${workout.letter}/execucao'),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
              ),
              child: PillButton(
                label: 'Iniciar Treino',
                color: AppColors.accent,
                foreground: AppColors.onAccent,
                onPressed: () => context.push('/treinos/${workout.letter}/execucao'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FtCard(
        radius: 12,
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text(value, style: AppTheme.grotesk(fontSize: 20, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
