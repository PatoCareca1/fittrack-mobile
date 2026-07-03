import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';

class BodyMetric {
  const BodyMetric({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPct,
    this.muscleMassKg,
    this.bodyWaterPct,
    this.visceralFat,
    this.bmrDevice,
    required this.bmrCalculated,
    required this.tdee,
    required this.calorieGoal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPct;
  final double? muscleMassKg;
  final double? bodyWaterPct;
  final int? visceralFat;
  final int? bmrDevice;
  final int bmrCalculated;
  final int tdee;
  final int calorieGoal;
  final int proteinG;
  final int carbsG;
  final int fatG;

  factory BodyMetric.fromJson(Map<String, dynamic> json) => BodyMetric(
        id: json['id'] as int,
        date: DateTime.parse(json['date'] as String),
        weightKg: double.parse('${json['weight_kg']}'),
        bodyFatPct: json['body_fat_pct'] == null
            ? null
            : double.parse('${json['body_fat_pct']}'),
        muscleMassKg: json['muscle_mass_kg'] == null
            ? null
            : double.parse('${json['muscle_mass_kg']}'),
        bodyWaterPct: json['body_water_pct'] == null
            ? null
            : double.parse('${json['body_water_pct']}'),
        visceralFat: json['visceral_fat'] as int?,
        bmrDevice: json['bmr_device'] as int?,
        bmrCalculated: json['bmr_calculated'] as int,
        tdee: json['tdee'] as int,
        calorieGoal: json['calorie_goal'] as int,
        proteinG: json['protein_g'] as int,
        carbsG: json['carbs_g'] as int,
        fatG: json['fat_g'] as int,
      );
}

class BodyMetricsRepository {
  BodyMetricsRepository(this._ref);

  final Ref _ref;

  Future<List<BodyMetric>> list() async {
    final res = await _ref.read(apiClientProvider).dio.get('/me/body-metrics/');
    final metrics = (res.data as List)
        .map((json) => BodyMetric.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return metrics;
  }

  Future<BodyMetric> create({
    required num weightKg,
    num? bodyFatPct,
    num? muscleMassKg,
    num? bodyWaterPct,
    int? visceralFat,
    int? bmrDevice,
    String? date,
  }) async {
    final res =
        await _ref.read(apiClientProvider).dio.post('/me/body-metrics/', data: {
      'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (muscleMassKg != null) 'muscle_mass_kg': muscleMassKg,
      if (bodyWaterPct != null) 'body_water_pct': bodyWaterPct,
      if (visceralFat != null) 'visceral_fat': visceralFat,
      if (bmrDevice != null) 'bmr_device': bmrDevice,
      if (date != null) 'date': date,
    });
    return BodyMetric.fromJson(res.data as Map<String, dynamic>);
  }
}

final bodyMetricsRepositoryProvider = Provider((ref) => BodyMetricsRepository(ref));

/// Histórico ordenado por data crescente (para os gráficos).
final bodyMetricsProvider = FutureProvider<List<BodyMetric>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(bodyMetricsRepositoryProvider).list();
});

/// Medição mais recente — fonte da meta calórica/macros do dashboard.
final latestMetricProvider = Provider<AsyncValue<BodyMetric?>>((ref) {
  return ref.watch(bodyMetricsProvider).whenData(
        (metrics) => metrics.isEmpty ? null : metrics.last,
      );
});
