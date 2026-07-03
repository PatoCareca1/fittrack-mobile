import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';

/// Vínculo com no máximo 1 personal e 1 nutricionista (RN05).
/// Personal = verde/CREF · Nutricionista = azul/CRN (README 6.6).
class MyProfessionalsScreen extends StatelessWidget {
  const MyProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Meus Profissionais', onBack: () => context.pop()),
            const SizedBox(height: 20),
            _ProfessionalCard(
              initial: 'R',
              name: 'Rafael Souza',
              badge: 'CREF 012345',
              role: 'Personal Trainer',
              accent: AppColors.primary,
              accentBg: AppColors.greenBgSoft,
              accentBorder: AppColors.primaryDark,
              stats: const [('3', 'treinos'), ('87%', 'aderência'), ('8', 'semanas')],
              statColors: const [AppColors.primary, AppColors.textPrimary, AppColors.textPrimary],
              onChat: () => context.push('/chat'),
              footer: OutlinedButton(
                onPressed: () => context.push('/plano-atribuido'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textSecondary,
                  textStyle:
                      const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('Ver plano atribuído'),
              ),
            ),
            const SizedBox(height: 14),
            _ProfessionalCard(
              initial: 'C',
              name: 'Camila Reis',
              badge: 'CRN 56789',
              role: 'Nutricionista',
              accent: AppColors.blueAccent,
              accentBg: AppColors.blueBgSoft,
              accentBorder: AppColors.blueBorder,
              stats: const [('2400', 'meta kcal'), ('72%', 'aderência'), ('4', 'refeições')],
              statColors: const [AppColors.blueAccent, AppColors.warning, AppColors.textPrimary],
              onChat: () => context.push('/chat'),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () => context.push('/aceitar-convite'),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.greenBgSoft,
                    child: Icon(Icons.add, size: 22, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text('Adicionar profissional',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Use um código de convite',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.initial,
    required this.name,
    required this.badge,
    required this.role,
    required this.accent,
    required this.accentBg,
    required this.accentBorder,
    required this.stats,
    required this.statColors,
    required this.onChat,
    this.footer,
  });

  final String initial;
  final String name;
  final String badge;
  final String role;
  final Color accent;
  final Color accentBg;
  final Color accentBorder;
  final List<(String, String)> stats;
  final List<Color> statColors;
  final VoidCallback onChat;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      radius: 18,
      borderColor: accentBorder,
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentBorder),
            ),
            child: Center(
              child: Text(initial,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: accent)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  FtTag(badge, color: accent),
                ]),
                const SizedBox(height: 3),
                Text(role,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SquareIconButton(
            icon: Icons.chat_bubble_outline,
            color: accent,
            background: accentBg,
            borderColor: accentBorder,
            onTap: onChat,
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text(stats[i].$1,
                      style: AppTheme.grotesk(fontSize: 17, color: statColors[i])),
                  const SizedBox(height: 1),
                  Text(stats[i].$2,
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary)),
                ]),
              ),
            ),
            if (i < stats.length - 1) const SizedBox(width: 8),
          ],
        ]),
        if (footer != null) ...[const SizedBox(height: 12), footer!],
      ]),
    );
  }
}
