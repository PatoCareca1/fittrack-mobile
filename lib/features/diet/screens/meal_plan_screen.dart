import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../body_metrics/data.dart';
import '../data.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  Future<void> _addMealDialog(BuildContext context, WidgetRef ref, int planId) async {
    final name = TextEditingController();
    final time = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova refeição',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nome (ex.: Café da manhã)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: time,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(hintText: 'Horário (ex.: 07:30)'),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      await ref
          .read(dietRepositoryProvider)
          .addMeal(planId, name.text.trim(), time.text.trim());
      ref.invalidate(myPlanProvider);
    }
    name.dispose();
    time.dispose();
  }

  Future<void> _toggleDone(WidgetRef ref, MealModel meal, bool done) async {
    final repo = ref.read(dietRepositoryProvider);
    if (done) {
      await repo.unmark(meal.id);
    } else {
      await repo.markDone(meal.id);
    }
    ref.invalidate(todayDoneMealsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('EEEE · d MMM', 'pt_BR').format(DateTime.now());
    final planAsync = ref.watch(myPlanProvider);
    final doneIds = ref.watch(todayDoneMealsProvider).valueOrNull ?? {};
    final goal = ref.watch(latestMetricProvider).valueOrNull?.calorieGoal;

    return Scaffold(
      floatingActionButton: planAsync.valueOrNull == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: const CircleBorder(),
                onPressed: () =>
                    _addMealDialog(context, ref, planAsync.value!.id),
                child: const Icon(Icons.add, size: 26),
              ),
            ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(myPlanProvider);
            ref.invalidate(todayDoneMealsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dieta',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  const SizedBox(height: 3),
                  Text(toBeginningOfSentenceCase(today) ?? today,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 18),
              planAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (e, _) => _ErrorRetry(
                    onRetry: () => ref.invalidate(myPlanProvider)),
                data: (plan) {
                  double consumed = 0;
                  for (final meal in plan.meals) {
                    if (doneIds.contains(meal.id)) consumed += meal.totals.kcal;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KcalSummary(consumed: consumed, goal: goal),
                      const SizedBox(height: 18),
                      const Text('Refeições do dia',
                          style:
                              TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      if (plan.meals.isEmpty)
                        const _EmptyMeals()
                      else
                        for (final meal in plan.meals) ...[
                          _MealCard(
                            meal: meal,
                            done: doneIds.contains(meal.id),
                            onToggle: () => _toggleDone(
                                ref, meal, doneIds.contains(meal.id)),
                            onTap: () =>
                                context.push('/dieta/refeicao/${meal.id}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KcalSummary extends StatelessWidget {
  const _KcalSummary({required this.consumed, required this.goal});

  final double consumed;
  final int? goal;

  @override
  Widget build(BuildContext context) {
    final remaining = goal == null ? null : goal! - consumed.round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.greenBgSoft, Color(0xFF0D1F17)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consumido hoje',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    GroteskText('${consumed.round()}', fontSize: 28),
                    Text(goal == null ? ' kcal' : ' / $goal kcal',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            if (remaining != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Restante',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  GroteskText('$remaining',
                      fontSize: 20,
                      color: remaining >= 0 ? AppColors.primary : AppColors.error),
                ],
              ),
          ],
        ),
        if (goal != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (consumed / goal!).clamp(0, 1),
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceDeep,
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          const Text('Preencha seus dados físicos para calcular a meta diária',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ]),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.done,
    required this.onToggle,
    required this.onTap,
  });

  final MealModel meal;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      borderColor: done ? AppColors.primaryDark : AppColors.cardAlt,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: done ? null : Border.all(color: AppColors.border),
                ),
                child: done
                    ? const Icon(Icons.check, size: 18, color: AppColors.onPrimary)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w700)),
                  if (meal.timeLabel.isNotEmpty)
                    Text(meal.timeLabel,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            GroteskText('${meal.totals.kcal.round()} kcal',
                fontSize: 15, fontWeight: FontWeight.w600),
          ]),
          if (meal.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final item in meal.items)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(item.food.name,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ),
            ]),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Toque para adicionar alimentos',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(children: [
        Icon(Icons.restaurant_outlined, size: 40, color: AppColors.textMuted),
        SizedBox(height: 12),
        Text('Nenhuma refeição ainda',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('Toque no + para montar seu dia',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(children: [
        const Text('Não foi possível carregar.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Tentar de novo')),
      ]),
    );
  }
}
