import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/features/auth/screens/onboarding_screen.dart';
import 'package:fittrack/features/body_metrics/screens/evolution_screen.dart';
import 'package:fittrack/features/dashboard/dashboard_screen.dart';
import 'package:fittrack/features/workouts/screens/my_workouts_screen.dart';
import 'package:fittrack/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _wrap(Widget child) => MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
      ]),
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

  testWidgets('dashboard mostra CTA de treino e macros', (tester) async {
    await tester.pumpWidget(_wrap(const DashboardScreen()));
    expect(find.text('Treino A · Peito e Tríceps'), findsOneWidget);
    expect(find.text('Proteína'), findsOneWidget);
    expect(find.text('Refeições de hoje'), findsOneWidget);
  });

  testWidgets('meus treinos lista divisão ABC', (tester) async {
    await tester.pumpWidget(_wrap(const MyWorkoutsScreen()));
    expect(find.text('Treino A'), findsOneWidget);
    expect(find.text('Treino B'), findsOneWidget);
    expect(find.text('Treino C'), findsOneWidget);
  });

  testWidgets('evolução troca métrica nas tabs', (tester) async {
    await tester.pumpWidget(_wrap(const EvolutionScreen()));
    expect(find.text('Peso atual'), findsOneWidget);
    await tester.tap(find.text('Gordura'));
    await tester.pump();
    expect(find.text('Gordura atual'), findsOneWidget);
  });
}
