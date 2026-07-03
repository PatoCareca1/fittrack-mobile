import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../body_metrics/data.dart';
import '../diet/data.dart';
import '../profile/data.dart';
import '../workouts/data.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('EEEE · d MMM', 'pt_BR').format(DateTime.now());
    final me = ref.watch(meProvider).valueOrNull;
    final metric = ref.watch(latestMetricProvider).valueOrNull;
    final plan = ref.watch(myPlanProvider).valueOrNull;
    final doneIds = ref.watch(todayDoneMealsProvider).valueOrNull ?? {};
    final workouts = ref.watch(workoutsProvider).valueOrNull;

    // Consumo do dia = soma dos totais das refeições marcadas hoje.
    var consumed = const Macros();
    if (plan != null) {
      for (final meal in plan.meals) {
        if (doneIds.contains(meal.id)) consumed = consumed + meal.totals;
      }
    }

    final firstName = me?.firstName ?? '';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '·';
    final todayWorkout = (workouts?.isNotEmpty ?? false) ? workouts!.first : null;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref
            ..invalidate(meProvider)
            ..invalidate(bodyMetricsProvider)
            ..invalidate(myPlanProvider)
            ..invalidate(todayDoneMealsProvider)
            ..invalidate(workoutsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(toBeginningOfSentenceCase(today) ?? today,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(firstName.isEmpty ? 'Olá!' : 'Olá, $firstName',
                          style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.5)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/perfil'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(initial,
                          style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // CTA treino do dia
            if (todayWorkout != null)
              InkWell(
                onTap: () => context.push('/treinos/${todayWorkout.id}'),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFEA580C)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TREINO DE HOJE',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .5,
                                  color: Color(0xFF451A03))),
                          const SizedBox(height: 4),
                          Text(todayWorkout.name,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.3,
                                  color: AppColors.onAccent)),
                          const SizedBox(height: 3),
                          Text(
                              '${todayWorkout.exercises.length} exercícios · ${todayWorkout.totalSets} séries',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C2D12))),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .18),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: AppColors.onAccent),
                    ),
                  ]),
                ),
              )
            else
              InkWell(
                onTap: () => context.push('/treinos/criar'),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(children: [
                    Icon(Icons.add_circle_outline,
                        size: 32, color: AppColors.accent),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crie seu primeiro treino',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Monte sua divisão com a biblioteca de exercícios',
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            const SizedBox(height: 18),

            // anel de calorias + macros
            FtCard(
              padding: const EdgeInsets.all(18),
              child: metric == null
                  ? Row(children: [
                      const Icon(Icons.calculate_outlined,
                          size: 34, color: AppColors.textMuted),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sem meta calórica ainda',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () => context.push('/dados-fisicos'),
                              child: const Text(
                                  'Preencha seus dados físicos para calcular →',
                                  style: TextStyle(
                                      fontSize: 13, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ])
                  : Row(children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: Stack(alignment: Alignment.center, children: [
                          SizedBox(
                            width: 98,
                            height: 98,
                            child: CircularProgressIndicator(
                              value: (consumed.kcal / metric.calorieGoal)
                                  .clamp(0.0, 1.0),
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              color: AppColors.primary,
                              backgroundColor: AppColors.cardAlt,
                            ),
                          ),
                          FittedBox(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              GroteskText('${consumed.kcal.round()}', fontSize: 26),
                              Text('de ${metric.calorieGoal} kcal',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textMuted)),
                            ]),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(children: [
                          _MacroBar(
                              name: 'Proteína',
                              color: AppColors.blueAccent,
                              value: consumed.proteinG.round(),
                              goal: metric.proteinG),
                          const SizedBox(height: 13),
                          _MacroBar(
                              name: 'Carbo',
                              color: AppColors.accent,
                              value: consumed.carbsG.round(),
                              goal: metric.carbsG),
                          const SizedBox(height: 13),
                          _MacroBar(
                              name: 'Gordura',
                              color: AppColors.error,
                              value: consumed.fatG.round(),
                              goal: metric.fatG),
                        ]),
                      ),
                    ]),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Refeições de hoje',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => context.go('/dieta'),
                  child: const Text('Ver tudo',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
            if (plan == null || plan.meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  plan == null
                      ? 'Carregando...'
                      : 'Monte suas refeições na aba Dieta.',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              )
            else
              for (final meal in plan.meals) ...[
                _MealRow(
                  meal: meal,
                  done: doneIds.contains(meal.id),
                  onTap: () => context.go('/dieta'),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 8),

            Row(children: [
              Expanded(
                child: _Shortcut(
                  label: 'Adicionar Refeição',
                  icon: Icons.add,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.greenBgSoft,
                  onTap: () => context.go('/dieta'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Shortcut(
                  label: 'Registrar Peso',
                  icon: Icons.monitor_weight_outlined,
                  iconColor: AppColors.accent,
                  iconBg: AppColors.orangeBgSoft,
                  onTap: () => context.push('/bioimpedancia'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.name, required this.color, required this.value, required this.goal});

  final String name;
  final Color color;
  final int value;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          Text('$value / ${goal}g',
              style: AppTheme.grotesk(
                  fontSize: 12.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: goal == 0 ? 0 : (value / goal).clamp(0.0, 1.0),
          minHeight: 7,
          color: color,
          backgroundColor: AppColors.cardAlt,
        ),
      ),
    ]);
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.done, required this.onTap});

  final MealModel meal;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: done ? AppColors.greenBgSoft : AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: done ? AppColors.primaryDark : AppColors.border),
          ),
          child: Icon(done ? Icons.check : Icons.circle_outlined,
              size: 17, color: done ? AppColors.primary : AppColors.textMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: done ? AppColors.textPrimary : AppColors.textSecondary)),
              if (meal.timeLabel.isNotEmpty)
                Text(meal.timeLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        GroteskText('${meal.totals.kcal.round()} kcal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: done ? AppColors.textPrimary : AppColors.textMuted),
      ]),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
