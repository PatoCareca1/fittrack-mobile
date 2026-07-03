import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final int workoutId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir treino?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Excluir', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(workoutsRepositoryProvider).deleteWorkout(workoutId);
      ref.invalidate(workoutsProvider);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref
        .watch(workoutsProvider)
        .valueOrNull
        ?.where((w) => w.id == workoutId)
        .firstOrNull;

    if (workout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final estMinutes = (workout.totalSets * 2.1).round();
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              ScreenHeader(
                title: workout.name,
                onBack: () => context.pop(),
                trailing: SquareIconButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: () => _delete(context, ref),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                _Stat(value: '${workout.exercises.length}', label: 'exercícios'),
                const SizedBox(width: 10),
                _Stat(value: '~$estMinutes', label: 'minutos'),
                const SizedBox(width: 10),
                _Stat(value: '${workout.totalSets}', label: 'séries'),
              ]),
              const SizedBox(height: 20),
              const Text('Exercícios',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final we in workout.exercises) ...[
                FtCard(
                  radius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDeep,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardAlt),
                      ),
                      child: Center(
                          child: MuscleIcon(
                              color: we.exercise.muscleColor, size: 30)),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(we.exercise.name,
                              style: const TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          FtTag(we.exercise.muscleLabel.toUpperCase(),
                              color: we.exercise.muscleColor),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(we.scheme,
                            style: AppTheme.grotesk(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 1),
                        Text('${we.loadLabel} · ${we.restSeconds}s',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ]),
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
                onPressed: workout.exercises.isEmpty
                    ? null
                    : () => context.push('/treinos/$workoutId/execucao'),
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
