import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perfil',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              SquareIconButton(
                icon: Icons.settings_outlined,
                size: 42,
                color: AppColors.textSecondary,
                onTap: () => context.push('/configuracoes'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Stack(children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('L',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child:
                      const Icon(Icons.edit, size: 14, color: AppColors.onAccent),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          const Text(MockData.userName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text(MockData.userEmail,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          const Row(children: [
            _InfoChip(label: 'Objetivo', value: 'Hipertrofia', highlight: true),
            SizedBox(width: 10),
            _InfoChip(label: 'Nível', value: 'Intermediário'),
            SizedBox(width: 10),
            _InfoChip(label: 'Atividade', value: 'Ativo'),
          ]),
          const SizedBox(height: 22),
          _MenuItem(
            icon: Icons.person_outline,
            title: 'Dados Físicos',
            subtitle: 'Peso, altura, objetivo',
            onTap: () => context.push('/dados-fisicos'),
          ),
          _MenuItem(
            icon: Icons.monitor_weight_outlined,
            title: 'Bioimpedância',
            subtitle: '% gordura, massa magra, TMB',
            onTap: () => context.push('/bioimpedancia'),
          ),
          _MenuItem(
            icon: Icons.groups_outlined,
            title: 'Meus Profissionais',
            subtitle: 'Personal e nutricionista',
            badge: '2',
            onTap: () => context.push('/profissionais'),
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            subtitle: 'Assinatura, preferências',
            onTap: () => context.push('/configuracoes'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FtCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.primary : AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FtCard(
        onTap: onTap,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.greenBgSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        ]),
      ),
    );
  }
}
