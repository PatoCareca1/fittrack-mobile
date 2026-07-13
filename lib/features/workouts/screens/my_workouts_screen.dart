import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

class MyWorkoutsScreen extends ConsumerWidget {
  const MyWorkoutsScreen({super.key});

  static const _letterColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.blueAccent,
    AppColors.warning,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(workoutsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text('Meus Treinos',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            const SizedBox(height: 6),
            const Text('Monte sua divisão de treinos',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            workoutsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(children: [
                  const Text('Não foi possível carregar.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                      onPressed: () => ref.invalidate(workoutsProvider),
                      child: const Text('Tentar de novo')),
                ]),
              ),
              data: (workouts) => Column(children: [
                if (workouts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(children: [
                      const Icon(Icons.fitness_center,
                          size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('Nenhum treino ainda',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Crie seu primeiro treino abaixo',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      PillButton(
                        label: 'Montar meu treino com o assistente',
                        icon: Icons.smart_toy_outlined,
                        height: 46,
                        onPressed: () => context.push(Uri(
                          path: '/chat',
                          queryParameters: {
                            'initial': 'Monte um treino novo para mim.',
                          },
                        ).toString()),
                      ),
                    ]),
                  )
                else
                  for (var i = 0; i < workouts.length; i++) ...[
                    _WorkoutCard(
                      workout: workouts[i],
                      letter: String.fromCharCode(65 + (i % 26)),
                      color: _letterColors[i % _letterColors.length],
                      onTap: () => context.push('/treinos/${workouts[i].id}'),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => context.push('/treinos/criar'),
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
                        Text('Criar treino',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.letter,
    required this.color,
    required this.onTap,
  });

  final WorkoutModel workout;
  final String letter;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .33)),
          ),
          child: Center(
              child: Text(letter, style: AppTheme.grotesk(fontSize: 22, color: color))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                  '${workout.exercises.length} exercícios · ${workout.totalSets} séries',
                  style:
                      const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textDisabled),
      ]),
    );
  }
}
