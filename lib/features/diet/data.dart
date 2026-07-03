import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../auth/providers.dart';

class Food {
  const Food({
    required this.id,
    required this.name,
    required this.source,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int id;
  final String name;
  final String source; // taco | off | custom
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  String get sourceLabel => switch (source) {
        'taco' => 'TACO',
        'off' => 'OFF',
        _ => 'MEU',
      };

  Color get sourceColor => switch (source) {
        'taco' => AppColors.primary,
        'off' => AppColors.blueAccent,
        _ => AppColors.accent,
      };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'] as int,
        name: json['name'] as String,
        source: json['source'] as String? ?? 'custom',
        kcal: double.parse('${json['kcal']}'),
        proteinG: double.parse('${json['protein_g']}'),
        carbsG: double.parse('${json['carbs_g']}'),
        fatG: double.parse('${json['fat_g']}'),
      );
}

class Macros {
  const Macros({this.kcal = 0, this.proteinG = 0, this.carbsG = 0, this.fatG = 0});

  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory Macros.fromJson(Map<String, dynamic> json) => Macros(
        kcal: double.parse('${json['kcal']}'),
        proteinG: double.parse('${json['protein_g']}'),
        carbsG: double.parse('${json['carbs_g']}'),
        fatG: double.parse('${json['fat_g']}'),
      );

  Macros operator +(Macros other) => Macros(
        kcal: kcal + other.kcal,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
      );
}

class MealItemModel {
  const MealItemModel({
    required this.id,
    required this.food,
    required this.quantityG,
    required this.macros,
  });

  final int id;
  final Food food;
  final double quantityG;
  final Macros macros;

  factory MealItemModel.fromJson(Map<String, dynamic> json) => MealItemModel(
        id: json['id'] as int,
        food: Food.fromJson(json['food_detail'] as Map<String, dynamic>),
        quantityG: double.parse('${json['quantity_g']}'),
        macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
      );
}

class MealModel {
  const MealModel({
    required this.id,
    required this.name,
    this.time,
    required this.items,
    required this.totals,
  });

  final int id;
  final String name;
  final String? time; // HH:MM:SS
  final List<MealItemModel> items;
  final Macros totals;

  String get timeLabel =>
      time == null ? '' : time!.split(':').take(2).join(':');

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
        id: json['id'] as int,
        name: json['name'] as String,
        time: json['time'] as String?,
        items: (json['items'] as List? ?? [])
            .map((i) => MealItemModel.fromJson(i as Map<String, dynamic>))
            .toList(),
        totals: Macros.fromJson(json['totals'] as Map<String, dynamic>),
      );
}

class MealPlanModel {
  const MealPlanModel({required this.id, required this.name, required this.meals});

  final int id;
  final String name;
  final List<MealModel> meals;

  factory MealPlanModel.fromJson(Map<String, dynamic> json) => MealPlanModel(
        id: json['id'] as int,
        name: json['name'] as String,
        meals: (json['meals'] as List? ?? [])
            .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

class DietRepository {
  DietRepository(this._ref);

  final Ref _ref;

  Future<List<Food>> searchFoods(String query) async {
    final res = await _ref
        .read(apiClientProvider)
        .dio
        .get('/diet/foods/', queryParameters: {if (query.isNotEmpty) 'q': query});
    return (res.data as List)
        .map((json) => Food.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Plano único do usuário na demo: pega o primeiro ou cria "Meu plano".
  Future<MealPlanModel> fetchMyPlan() async {
    final dio = _ref.read(apiClientProvider).dio;
    final res = await dio.get('/diet/meal-plans/');
    final plans = res.data as List;
    if (plans.isNotEmpty) {
      return MealPlanModel.fromJson(plans.first as Map<String, dynamic>);
    }
    final created =
        await dio.post('/diet/meal-plans/', data: {'name': 'Meu plano'});
    return MealPlanModel.fromJson(created.data as Map<String, dynamic>);
  }

  Future<void> addMeal(int planId, String name, String? time) =>
      _ref.read(apiClientProvider).dio.post('/diet/meals/', data: {
        'plan': planId,
        'name': name,
        if (time != null && time.isNotEmpty) 'time': time,
      });

  Future<void> deleteMeal(int mealId) =>
      _ref.read(apiClientProvider).dio.delete('/diet/meals/$mealId/');

  Future<void> addItem(int mealId, int foodId, num quantityG) =>
      _ref.read(apiClientProvider).dio.post('/diet/meals/$mealId/items/', data: {
        'food': foodId,
        'quantity_g': quantityG,
      });

  Future<void> removeItem(int itemId) =>
      _ref.read(apiClientProvider).dio.delete('/diet/meal-items/$itemId/');

  Future<void> markDone(int mealId, {String comment = ''}) =>
      _ref.read(apiClientProvider).dio.post('/diet/meals/$mealId/mark-done/',
          data: {if (comment.isNotEmpty) 'comment': comment});

  Future<void> unmark(int mealId) =>
      _ref.read(apiClientProvider).dio.post('/diet/meals/$mealId/unmark/');

  /// IDs das refeições concluídas hoje.
  Future<Set<int>> todayDoneMealIds() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final res = await _ref
        .read(apiClientProvider)
        .dio
        .get('/diet/meal-logs/', queryParameters: {'date': today});
    return (res.data as List).map((log) => log['meal'] as int).toSet();
  }
}

final dietRepositoryProvider = Provider((ref) => DietRepository(ref));

final myPlanProvider = FutureProvider<MealPlanModel>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(dietRepositoryProvider).fetchMyPlan();
});

final todayDoneMealsProvider = FutureProvider<Set<int>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(dietRepositoryProvider).todayDoneMealIds();
});
