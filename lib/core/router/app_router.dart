import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/recover_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/body_metrics/screens/bioimpedance_screen.dart';
import '../../features/body_metrics/screens/evolution_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/diet/screens/food_search_screen.dart';
import '../../features/diet/screens/meal_detail_screen.dart';
import '../../features/diet/screens/meal_plan_screen.dart';
import '../../features/profile/screens/physical_data_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/workout_session/execution_screen.dart';
import '../../features/workouts/screens/create_workout_screen.dart';
import '../../features/workouts/screens/my_workouts_screen.dart';
import '../../features/workouts/screens/workout_detail_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/widgets.dart';

// Fora da demo (MVP.md): vínculo profissional, plano atribuído e explorar
// templates — telas preservadas em features/, sem rota. Chat (FitTrack
// Coach/IA) tem rota própria abaixo — ligado ao apps/coach do backend.

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<AuthStatus>(AuthStatus.unknown);
  ref
    ..onDispose(auth.dispose)
    ..listen(authControllerProvider, (_, next) => auth.value = next.status);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.value;
      final onAuthScreen = ['/splash', '/onboarding', '/login', '/cadastro', '/recuperar']
          .contains(state.matchedLocation);
      if (status == AuthStatus.unknown) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.signedOut && !onAuthScreen) return '/login';
      if (status == AuthStatus.signedIn && state.matchedLocation == '/splash') {
        return '/inicio';
      }
      if (status == AuthStatus.signedOut && state.matchedLocation == '/splash') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/recuperar', builder: (_, _) => const RecoverScreen()),

      // 5 tabs com bottom nav persistente
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/inicio', builder: (_, _) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/treinos', builder: (_, _) => const MyWorkoutsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/dieta', builder: (_, _) => const MealPlanScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/evolucao', builder: (_, _) => const EvolutionScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/perfil', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),

      // telas fora do shell (fullscreen, sem bottom nav)
      GoRoute(
          path: '/treinos/criar',
          builder: (_, _) => const CreateWorkoutScreen()),
      GoRoute(
        path: '/treinos/:id',
        builder: (_, state) => WorkoutDetailScreen(
            workoutId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/treinos/:id/execucao',
        builder: (_, state) =>
            ExecutionScreen(workoutId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, state) =>
            ChatScreen(initialMessage: state.uri.queryParameters['initial']),
      ),
      GoRoute(
        path: '/dieta/buscar',
        builder: (_, state) => FoodSearchScreen(
            mealId: int.tryParse(state.uri.queryParameters['meal'] ?? '')),
      ),
      GoRoute(
        path: '/dieta/refeicao/:id',
        builder: (_, state) =>
            MealDetailScreen(mealId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
          path: '/bioimpedancia', builder: (_, _) => const BioimpedanceScreen()),
      GoRoute(
        path: '/dados-fisicos',
        builder: (_, state) => PhysicalDataScreen(
            fromOnboarding: state.uri.queryParameters['onboarding'] == '1'),
      ),
      GoRoute(path: '/configuracoes', builder: (_, _) => const SettingsScreen()),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FtLogo(size: 88, radius: 26),
          SizedBox(height: 20),
          Text('FitTrack',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ]),
      ),
    );
  }
}

class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.grid_view_outlined, 'Início'),
    (Icons.fitness_center, 'Treino'),
    (Icons.restaurant_outlined, 'Dieta'),
    (Icons.monitor_heart_outlined, 'Evolução'),
    (Icons.person_outline, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDeep,
          border: Border(top: BorderSide(color: AppColors.cardAlt)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => shell.goBranch(i,
                        initialLocation: i == shell.currentIndex),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_tabs[i].$1,
                            size: 23,
                            color: shell.currentIndex == i
                                ? AppColors.primary
                                : AppColors.textMuted),
                        const SizedBox(height: 5),
                        Text(_tabs[i].$2,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: shell.currentIndex == i
                                    ? AppColors.primary
                                    : AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
