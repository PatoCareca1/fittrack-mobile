import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

/// Detalhe da refeição: itens reais, adicionar/remover alimento.
class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final int mealId;

  Future<void> _removeItem(WidgetRef ref, int itemId) async {
    await ref.read(dietRepositoryProvider).removeItem(itemId);
    ref.invalidate(myPlanProvider);
  }

  Future<void> _deleteMeal(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir refeição?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        content: const Text('Os alimentos e o histórico dela serão removidos.',
            style: TextStyle(color: AppColors.textSecondary)),
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
      await ref.read(dietRepositoryProvider).deleteMeal(mealId);
      ref.invalidate(myPlanProvider);
      ref.invalidate(todayDoneMealsProvider);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(myPlanProvider);
    final meal = planAsync.valueOrNull?.meals
        .where((m) => m.id == mealId)
        .firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: meal == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  ScreenHeader(
                    title: meal.name,
                    onBack: () => context.pop(),
                    trailing: SquareIconButton(
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onTap: () => _deleteMeal(context, ref),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FtCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total da refeição',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary)),
                          GroteskText('${meal.totals.kcal.round()} kcal',
                              fontSize: 24, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        _MacroBox(
                            label: 'Proteína',
                            value: meal.totals.proteinG,
                            color: AppColors.blueAccent),
                        const SizedBox(width: 10),
                        _MacroBox(
                            label: 'Carbo',
                            value: meal.totals.carbsG,
                            color: AppColors.accent),
                        const SizedBox(width: 10),
                        _MacroBox(
                            label: 'Gordura',
                            value: meal.totals.fatG,
                            color: AppColors.error),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  const Text('Alimentos',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (meal.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Nenhum alimento ainda — adicione abaixo.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted)),
                    )
                  else
                    for (final item in meal.items) ...[
                      FtCard(
                        radius: 14,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.food.name,
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600)),
                                Text('${item.quantityG.round()}g',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          GroteskText('${item.macros.kcal.round()} kcal',
                              fontSize: 14, fontWeight: FontWeight.w600),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => _removeItem(ref, item.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.cardAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: AppColors.error),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => context.push('/dieta/buscar?meal=$mealId'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 48,
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
                          Text('Adicionar alimento',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDeep,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          GroteskText('${value.round()}g', fontSize: 17, color: color),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
