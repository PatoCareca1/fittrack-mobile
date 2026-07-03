import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

const _goalLabels = {
  'weight_loss': 'Emagrecimento',
  'hypertrophy': 'Hipertrofia',
  'maintenance': 'Manutenção',
  'general_health': 'Saúde geral',
};

const _activityLabels = {
  'sedentary': 'Sedentário',
  'light': 'Leve',
  'moderate': 'Moderado',
  'intense': 'Intenso',
  'very_intense': 'Atleta',
};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    final me = meAsync.valueOrNull;
    final initial =
        (me?.firstName.isNotEmpty ?? false) ? me!.firstName[0].toUpperCase() : '?';

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
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimary)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(me?.fullName ?? '...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(me?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(children: [
            _InfoChip(
                label: 'Objetivo',
                value: _goalLabels[me?.profile.goal] ?? '—',
                highlight: true),
            const SizedBox(width: 10),
            _InfoChip(
                label: 'Altura',
                value: me?.profile.heightCm == null
                    ? '—'
                    : '${me!.profile.heightCm} cm'),
            const SizedBox(width: 10),
            _InfoChip(
                label: 'Atividade',
                value: _activityLabels[me?.profile.activityLevel] ?? '—'),
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
            title: 'Registrar Medição',
            subtitle: 'Peso, % gordura, massa magra',
            onTap: () => context.push('/bioimpedancia'),
          ),
          _MenuItem(
            icon: Icons.groups_outlined,
            title: 'Meus Profissionais',
            subtitle: 'Em breve — fora da demo',
            enabled: false,
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            subtitle: 'Preferências, sair da conta',
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
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: enabled ? 1 : .45,
        child: FtCard(
          onTap: enabled ? onTap : null,
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
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textDisabled),
          ]),
        ),
      ),
    );
  }
}
