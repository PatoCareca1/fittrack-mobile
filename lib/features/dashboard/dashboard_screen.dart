import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../mock/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE · d MMM', 'pt_BR').format(DateTime.now());
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(toBeginningOfSentenceCase(today) ?? today,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    const Text('Olá, Lucas',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  ],
                ),
              ),
              SquareIconButton(
                icon: Icons.chat_bubble_outline,
                size: 42,
                color: AppColors.textSecondary,
                badgeColor: AppColors.accent,
                onTap: () => context.push('/chat'),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.go('/perfil'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Center(
                    child: Text('L',
                        style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // CTA Iniciar Treino
          InkWell(
            onTap: () => context.push('/treinos/A/execucao'),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFFEA580C)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TREINO DE HOJE',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .5,
                              color: Color(0xFF451A03))),
                      const SizedBox(height: 4),
                      const Text('Treino A · Peito e Tríceps',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.3,
                              color: AppColors.onAccent)),
                      const SizedBox(height: 3),
                      Text('8 exercícios · ~50 min',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C2D12))),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .18), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: AppColors.onAccent),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),

          // anel de calorias + macros
          FtCard(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 98,
                    height: 98,
                    child: CircularProgressIndicator(
                      value: MockData.kcalConsumed / MockData.kcalGoal,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: AppColors.primary,
                      backgroundColor: AppColors.cardAlt,
                    ),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    const GroteskText('${MockData.kcalConsumed}', fontSize: 26),
                    const Text('de ${MockData.kcalGoal} kcal',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ]),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(children: [
                  for (final m in MockData.macros) ...[
                    _MacroBar(name: m.$1, color: m.$2, value: m.$3, goal: m.$4),
                    if (m != MockData.macros.last) const SizedBox(height: 13),
                  ],
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Refeições de hoje',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () => context.go('/dieta'),
                child: const Text('Ver tudo',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          for (final meal in MockData.meals) ...[
            _MealRow(meal: meal, onTap: () => context.go('/dieta')),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),

          Row(children: [
            Expanded(
              child: _Shortcut(
                label: 'Adicionar Refeição',
                icon: Icons.add,
                iconColor: AppColors.primary,
                iconBg: AppColors.greenBgSoft,
                onTap: () => context.push('/dieta/buscar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Shortcut(
                label: 'Registrar Peso',
                icon: Icons.schedule,
                iconColor: AppColors.accent,
                iconBg: AppColors.orangeBgSoft,
                onTap: () => context.push('/bioimpedancia'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.name, required this.color, required this.value, required this.goal});

  final String name;
  final Color color;
  final int value;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          Text('$value / ${goal}g',
              style: AppTheme.grotesk(
                  fontSize: 12.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (value / goal).clamp(0, 1),
          minHeight: 7,
          color: color,
          backgroundColor: AppColors.cardAlt,
        ),
      ),
    ]);
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onTap});

  final MockMeal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: meal.done ? AppColors.greenBgSoft : AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: meal.done ? AppColors.primaryDark : AppColors.border),
          ),
          child: Icon(meal.done ? Icons.check : Icons.circle_outlined,
              size: 17, color: meal.done ? AppColors.primary : AppColors.textMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: meal.done ? AppColors.textPrimary : AppColors.textSecondary)),
              Text(meal.time,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        GroteskText('${meal.kcal} kcal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: meal.done ? AppColors.textPrimary : AppColors.textMuted),
      ]),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      onTap: onTap,
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
