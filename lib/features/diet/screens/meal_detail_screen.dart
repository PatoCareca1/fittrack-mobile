import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

/// Detalhe/edição de refeição ("Adicionar Refeição" no protótipo).
class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = MockData.mealItems.fold<int>(0, (a, b) => a + b.$3);
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              ScreenHeader(title: 'Almoço', onBack: () => context.pop()),
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
                      GroteskText('$total kcal',
                          fontSize: 24, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    for (final m in MockData.mealMacros) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDeep,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            GroteskText('${m.$3}g', fontSize: 17, color: m.$2),
                            const SizedBox(height: 2),
                            Text(m.$1,
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary)),
                          ]),
                        ),
                      ),
                      if (m != MockData.mealMacros.last) const SizedBox(width: 10),
                    ],
                  ]),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('Alimentos selecionados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final item in MockData.mealItems) ...[
                FtCard(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1,
                              style: const TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w600)),
                          Text(item.$2,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    GroteskText('${item.$3} kcal',
                        fontSize: 14, fontWeight: FontWeight.w600),
                    const SizedBox(width: 12),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.cardAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.close, size: 16, color: AppColors.error),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              InkWell(
                onTap: () => context.push('/dieta/buscar'),
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
                label: 'Salvar refeição',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Refeição salva!')));
                  context.go('/dieta');
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
