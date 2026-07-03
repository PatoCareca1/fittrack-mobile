import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';
import '../../workouts/widgets/exercise_row.dart';

/// Plano atribuído pelo personal — estrutura somente leitura (RN04/RN10),
/// aluno apenas registra execução.
class AssignedPlanScreen extends StatelessWidget {
  const AssignedPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = MockData.assignedWorkout;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              ScreenHeader(title: 'Plano Hipertrofia 12sem', onBack: () => context.pop()),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.greenBgSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('SOMENTE LEITURA',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                          color: AppColors.primary)),
                  Spacer(),
                  Text('Atribuído por Rafael · CREF',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 18),
              Text('Treino ${workout.letter} · ${workout.name}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final ex in workout.exercises) ...[
                ExerciseRow(exercise: ex, readOnly: true),
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
                label: 'Registrar execução',
                onPressed: () => context.push('/treinos/${workout.letter}/execucao'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
