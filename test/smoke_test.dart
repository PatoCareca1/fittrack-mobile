import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/features/auth/screens/onboarding_screen.dart';
import 'package:fittrack/features/body_metrics/data.dart';
import 'package:fittrack/features/body_metrics/screens/evolution_screen.dart';
import 'package:fittrack/features/dashboard/dashboard_screen.dart';
import 'package:fittrack/features/diet/data.dart';
import 'package:fittrack/features/profile/data.dart';
import 'package:fittrack/features/workouts/data.dart';
import 'package:fittrack/features/workouts/screens/my_workouts_screen.dart';
import 'package:fittrack/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

final _me = Me(
  id: 1,
  email: 'lucas@email.com',
  firstName: 'Lucas',
  lastName: 'Andrade',
  accountType: 'user',
  profile: const ProfileData(heightCm: 178, sex: 'M', goal: 'hypertrophy'),
);

final _metric = BodyMetric(
  id: 1,
  date: DateTime(2026, 7, 1),
  weightKg: 78.5,
  bmrCalculated: 1780,
  tdee: 2760,
  calorieGoal: 2400,
  proteinG: 180,
  carbsG: 270,
  fatG: 67,
);

const _plan = MealPlanModel(id: 1, name: 'Meu plano', meals: [
  MealModel(
      id: 1,
      name: 'Almoço',
      time: '12:30:00',
      items: [],
      totals: Macros(kcal: 680, proteinG: 42, carbsG: 70, fatG: 12)),
]);

const _workout = WorkoutModel(id: 1, name: 'Treino A · Peito', exercises: [
  WorkoutExerciseModel(
    id: 1,
    exercise: ExerciseModel(id: 1, name: 'Supino Reto', muscleGroup: 'chest'),
    order: 1,
    sets: 4,
    reps: 10,
    restSeconds: 90,
  ),
]);

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        meProvider.overrideWith((ref) async => _me),
        bodyMetricsProvider.overrideWith((ref) async => [_metric]),
        myPlanProvider.overrideWith((ref) async => _plan),
        todayDoneMealsProvider.overrideWith((ref) async => {1}),
        workoutsProvider.overrideWith((ref) async => [_workout]),
        sessionsProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp.router(
        theme: AppTheme.dark(),
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
        ]),
      ),
    );

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('onboarding renderiza e navega entre páginas', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    expect(find.text('Desbloqueie seu Potencial'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pump();
    expect(find.text('Controle Total da Dieta'), findsOneWidget);
  });

  testWidgets('dashboard mostra treino do dia, kcal e refeições', (tester) async {
    await tester.pumpWidget(_wrap(const DashboardScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Lucas'), findsOneWidget);
    expect(find.text('Treino A · Peito'), findsOneWidget);
    expect(find.text('de 2400 kcal'), findsOneWidget);
    expect(find.text('Almoço'), findsOneWidget);
    // almoço marcado → 680 kcal consumidas no anel
    expect(find.text('680'), findsOneWidget);
  });

  testWidgets('meus treinos lista treinos reais', (tester) async {
    await tester.pumpWidget(_wrap(const MyWorkoutsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Treino A · Peito'), findsOneWidget);
    expect(find.text('1 exercícios · 4 séries'), findsOneWidget);
  });

  testWidgets('evolução mostra peso atual e troca de métrica', (tester) async {
    await tester.pumpWidget(_wrap(const EvolutionScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Peso atual'), findsOneWidget);
    expect(find.text('78,5'), findsOneWidget);
    await tester.tap(find.text('Gordura'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sem registros de gordura'), findsOneWidget);
  });
}
