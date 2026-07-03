import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

/// Busca real no catálogo (`GET /diet/foods/?q=`). Quando aberta com `meal`,
/// tocar num alimento pergunta a quantidade e adiciona à refeição.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, this.mealId});

  final int? mealId;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  List<Food> _results = [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final results = await ref.read(dietRepositoryProvider).searchFoods(query);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(Food food) async {
    if (widget.mealId == null) return;
    final controller = TextEditingController(text: '100');
    final quantity = await showDialog<num>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(food.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: AppTheme.grotesk(fontSize: 20),
            decoration: const InputDecoration(suffixText: 'gramas'),
          ),
          const SizedBox(height: 10),
          Text(
            '${food.kcal.round()} kcal · P ${food.proteinG}g · C ${food.carbsG}g · G ${food.fatG}g por 100g',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary),
            onPressed: () => Navigator.pop(
                context, num.tryParse(controller.text.replaceAll(',', '.'))),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (quantity != null && quantity > 0) {
      await ref.read(dietRepositoryProvider).addItem(widget.mealId!, food.id, quantity);
      ref.invalidate(myPlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${food.name} adicionado (${quantity.round()}g)')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Buscar Alimento', onBack: () => context.pop()),
            const SizedBox(height: 18),
            TextField(
              onChanged: _onChanged,
              autofocus: widget.mealId != null,
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
              FtTag('Open Food Facts · em breve', color: AppColors.textSecondary,
                  filled: false),
            ]),
            const SizedBox(height: 18),
            const Text('Resultados · valores por 100g',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_results.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('Nenhum alimento encontrado',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else
              for (final food in _results) ...[
                FtCard(
                  onTap: widget.mealId == null ? null : () => _pick(food),
                  radius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            FtTag(food.sourceLabel, color: food.sourceColor),
                          ]),
                          const SizedBox(height: 5),
                          Row(children: [
                            Text('P ${food.proteinG}g',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.blueAccent)),
                            const SizedBox(width: 10),
                            Text('C ${food.carbsG}g',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.accent)),
                            const SizedBox(width: 10),
                            Text('G ${food.fatG}g',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.error)),
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GroteskText('${food.kcal.round()}',
                            fontSize: 16, color: AppColors.primary),
                        const Text('kcal/100g',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
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
