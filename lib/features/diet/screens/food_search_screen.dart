import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

/// Busca unificada TACO + Open Food Facts (mock — endpoint `GET /diet/foods/?q=`).
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  String _query = 'frango';

  @override
  Widget build(BuildContext context) {
    final results = MockData.foods
        .where((f) => f.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Buscar Alimento', onBack: () => context.pop()),
            const SizedBox(height: 18),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'frango grelhado',
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(children: [
              FtTag('TACO', color: AppColors.primary),
              SizedBox(width: 8),
              FtTag('Open Food Facts', color: AppColors.blueAccent),
            ]),
            const SizedBox(height: 18),
            const Text('Resultados · valores por 100g',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            for (final food in results) ...[
              FtCard(
                onTap: () => context.push('/dieta/refeicao'),
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(food.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14.5, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          FtTag(food.source, color: food.sourceColor),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          Text('P ${food.protein}g',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.blueAccent)),
                          const SizedBox(width: 10),
                          Text('C ${food.carbs}g',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.accent)),
                          const SizedBox(width: 10),
                          Text('G ${food.fat}g',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.error)),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GroteskText('${food.kcal}',
                          fontSize: 16, color: AppColors.primary),
                      const Text('kcal/100g',
                          style:
                              TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
