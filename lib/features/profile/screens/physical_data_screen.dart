import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';

/// Dados físicos usados no cálculo de TMB/macros (RN01–RN03, calculados no
/// backend em `apps/body/services.py`).
class PhysicalDataScreen extends StatefulWidget {
  const PhysicalDataScreen({super.key, this.fromOnboarding = false});

  /// Vindo do cadastro: "Salvar" leva ao dashboard em vez de voltar.
  final bool fromOnboarding;

  @override
  State<PhysicalDataScreen> createState() => _PhysicalDataScreenState();
}

class _PhysicalDataScreenState extends State<PhysicalDataScreen> {
  String _sex = 'M';
  String _goal = 'hipertrofia';

  static const _goals = [
    ('emagrecimento', 'Emagrecimento'),
    ('hipertrofia', 'Hipertrofia'),
    ('manutencao', 'Manutenção'),
    ('saude', 'Saúde'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(
              title: 'Dados Físicos',
              onBack: widget.fromOnboarding ? null : () => context.pop(),
            ),
            Padding(
              padding: EdgeInsets.only(left: widget.fromOnboarding ? 0 : 54, top: 4),
              child: const Text('Usamos para calcular suas metas',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: _NumberField(label: 'Peso (kg)', initial: '78,5')),
              const SizedBox(width: 12),
              Expanded(child: _NumberField(label: 'Altura (cm)', initial: '178')),
            ]),
            const SizedBox(height: 14),
            _NumberField(label: 'Idade', initial: '28'),
            const SizedBox(height: 20),
            const Text('Sexo biológico',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardAlt),
              ),
              child: Row(children: [
                for (final s in const [('M', 'Masculino'), ('F', 'Feminino')])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sex = s.$1),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _sex == s.$1 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(s.$2,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _sex == s.$1
                                      ? AppColors.onPrimary
                                      : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Objetivo',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.1,
              children: [
                for (final g in _goals)
                  GestureDetector(
                    onTap: () => setState(() => _goal = g.$1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _goal == g.$1 ? AppColors.greenBgSoft : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                _goal == g.$1 ? AppColors.primary : AppColors.border,
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(g.$2,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _goal == g.$1
                                    ? AppColors.primary
                                    : AppColors.textSecondary)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            PillButton(
              label: 'Salvar dados',
              onPressed: () {
                if (widget.fromOnboarding) {
                  context.go('/inicio');
                } else {
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.initial});

  final String label;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initial),
          keyboardType: TextInputType.number,
          style: AppTheme.grotesk(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
