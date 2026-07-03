import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE · d MMM', 'pt_BR').format(DateTime.now());
    const remaining = MockData.kcalGoal - MockData.kcalConsumed;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: const CircleBorder(),
          onPressed: () => context.push('/dieta/buscar'),
          child: const Icon(Icons.add, size: 26),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                SquareIconButton(
                  icon: Icons.chat_bubble_outline,
                  size: 42,
                  color: AppColors.textSecondary,
                  badgeColor: AppColors.blueAccent,
                  onTap: () => context.push('/chat'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // resumo calorias
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.greenBgSoft, Color(0xFF0D1F17)]),
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
                            style:
                                TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              GroteskText('${MockData.kcalConsumed}', fontSize: 28),
                              const Text(' / ${MockData.kcalGoal} kcal',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.textSecondary)),
                            ]),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Restante',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        GroteskText('$remaining',
                            fontSize: 20, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: MockData.kcalConsumed / MockData.kcalGoal,
                    minHeight: 8,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceDeep,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),

            const Text('Refeições do dia',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final meal in MockData.meals) ...[
              FtCard(
                onTap: () => context.push('/dieta/refeicao'),
                borderColor: meal.done ? AppColors.primaryDark : AppColors.cardAlt,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: meal.done ? AppColors.primary : AppColors.surfaceDeep,
                          borderRadius: BorderRadius.circular(10),
                          border: meal.done
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: meal.done
                            ? const Icon(Icons.check,
                                size: 18, color: AppColors.onPrimary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meal.name,
                                style: const TextStyle(
                                    fontSize: 15.5, fontWeight: FontWeight.w700)),
                            Text(meal.time,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      GroteskText('${meal.kcal} kcal',
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final f in meal.foods)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDeep,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                        ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
