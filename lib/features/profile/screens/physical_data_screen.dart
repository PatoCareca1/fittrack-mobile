import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../body_metrics/data.dart';
import '../data.dart';

/// Dados físicos usados no cálculo de TMB/macros (RN01–RN03, calculados no
/// backend em `apps/body/services.py`). Salva perfil + primeira pesagem.
class PhysicalDataScreen extends ConsumerStatefulWidget {
  const PhysicalDataScreen({super.key, this.fromOnboarding = false});

  /// Vindo do cadastro: "Salvar" leva ao dashboard em vez de voltar.
  final bool fromOnboarding;

  @override
  ConsumerState<PhysicalDataScreen> createState() => _PhysicalDataScreenState();
}

class _PhysicalDataScreenState extends ConsumerState<PhysicalDataScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();
  String _sex = 'M';
  String _goal = 'hypertrophy';
  String _activity = 'moderate';
  bool _saving = false;
  bool _prefilled = false;

  static const _goals = [
    ('weight_loss', 'Emagrecimento'),
    ('hypertrophy', 'Hipertrofia'),
    ('maintenance', 'Manutenção'),
    ('general_health', 'Saúde'),
  ];

  static const _activities = [
    ('sedentary', 'Sedentário'),
    ('light', 'Leve'),
    ('moderate', 'Moderado'),
    ('intense', 'Intenso'),
    ('very_intense', 'Atleta'),
  ];

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  void _prefill(Me me) {
    if (_prefilled) return;
    _prefilled = true;
    final p = me.profile;
    if (p.heightCm != null) _height.text = '${p.heightCm}';
    if (p.age != null) _age.text = '${p.age}';
    if (p.sex != null) _sex = p.sex!;
    if (p.goal != null) _goal = p.goal!;
    if (p.activityLevel != null) _activity = p.activityLevel!;
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    final height = double.tryParse(_height.text.replaceAll(',', '.'));
    final age = int.tryParse(_age.text);
    if (weight == null || height == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha peso, altura e idade.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final birth = DateTime(now.year - age, now.month, now.day);
      await ref.read(profileRepositoryProvider).updateProfile(
            birthDate: birth.toIso8601String().substring(0, 10),
            sex: _sex,
            heightCm: height,
            goal: _goal,
            activityLevel: _activity,
          );
      final metric =
          await ref.read(bodyMetricsRepositoryProvider).create(weightKg: weight);
      ref.invalidate(meProvider);
      ref.invalidate(bodyMetricsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Meta diária calculada: ${metric.calorieGoal} kcal 🎯')));
      if (widget.fromOnboarding) {
        context.go('/inicio');
      } else {
        context.pop();
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response!.data as Map).values.first.toString()
          : 'Não foi possível salvar. Tente novamente.';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(detail)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(meProvider).whenData(_prefill);
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
              Expanded(
                  child:
                      _NumberField(label: 'Peso (kg)', controller: _weight)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _NumberField(label: 'Altura (cm)', controller: _height)),
            ]),
            const SizedBox(height: 14),
            _NumberField(label: 'Idade', controller: _age),
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
            const SizedBox(height: 20),
            const Text('Nível de atividade',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final a in _activities)
                GestureDetector(
                  onTap: () => setState(() => _activity = a.$1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color:
                          _activity == a.$1 ? AppColors.greenBgSoft : AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: _activity == a.$1
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Text(a.$2,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _activity == a.$1
                                ? AppColors.primary
                                : AppColors.textSecondary)),
                  ),
                ),
            ]),
            const SizedBox(height: 28),
            PillButton(
              label: _saving ? 'Salvando...' : 'Salvar dados',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTheme.grotesk(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
