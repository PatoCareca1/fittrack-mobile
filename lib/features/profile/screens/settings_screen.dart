import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _metric = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Configurações', onBack: () => context.pop()),
            const SizedBox(height: 20),

            // assinatura (estrutura freemium — fluxo de cobrança fora do MVP)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.orangeBgSoft, Color(0xFF1A1208)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent),
              ),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.workspace_premium_outlined,
                      size: 24, color: AppColors.onAccent),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitTrack Pro',
                          style:
                              TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Renova em 12 jul · R\$ 19,90/mês',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    foregroundColor: AppColors.accent,
                    textStyle:
                        const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Gerenciar'),
                ),
              ]),
            ),
            const SizedBox(height: 22),

            const Text('PREFERÊNCIAS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: AppColors.textMuted)),
            const SizedBox(height: 10),
            FtCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _SettingRow(
                  icon: Icons.straighten,
                  label: 'Unidades',
                  divider: true,
                  trailing: _UnitToggle(
                    metric: _metric,
                    onChanged: (v) => setState(() => _metric = v),
                  ),
                ),
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  trailing: Switch(
                    value: _notifications,
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 22),

            const Text('SEGURANÇA',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: AppColors.textMuted)),
            const SizedBox(height: 10),
            FtCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _SettingRow(
                    icon: Icons.shield_outlined,
                    label: 'Privacidade e dados',
                    divider: true,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textDisabled)),
                _SettingRow(
                    icon: Icons.lock_outline,
                    label: 'Alterar senha',
                    divider: true,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textDisabled)),
                // Exportação/remoção de dados — LGPD (RN12)
                _SettingRow(
                    icon: Icons.download_outlined,
                    label: 'Exportar meus dados',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textDisabled)),
              ]),
            ),
            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                label: const Text('Sair da conta'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A0E0E),
                  foregroundColor: AppColors.error,
                  textStyle:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.divider = false,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppColors.cardAlt))
            : null,
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        ),
        trailing,
      ]),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.metric, required this.onChanged});

  final bool metric;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final u in const [(true, 'KG·CM'), (false, 'LB·IN')])
          GestureDetector(
            onTap: () => onChanged(u.$1),
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: metric == u.$1 ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Text(u.$2,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: metric == u.$1
                            ? AppColors.onPrimary
                            : AppColors.textMuted)),
              ),
            ),
          ),
      ]),
    );
  }
}
