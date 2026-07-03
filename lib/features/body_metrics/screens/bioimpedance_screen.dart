import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

/// Nova medição — peso obrigatório; demais campos opcionais. Para o fluxo de
/// bioimpedância completa vale a RN14 (peso + % gordura).
class BioimpedanceScreen extends ConsumerStatefulWidget {
  const BioimpedanceScreen({super.key});

  @override
  ConsumerState<BioimpedanceScreen> createState() => _BioimpedanceScreenState();
}

class _BioimpedanceScreenState extends ConsumerState<BioimpedanceScreen> {
  final _weight = TextEditingController();
  final _fat = TextEditingController();
  final _muscle = TextEditingController();
  final _water = TextEditingController();
  final _bmr = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_weight, _fat, _muscle, _water, _bmr]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _save() async {
    final weight = _num(_weight);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe ao menos o peso.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final metric = await ref.read(bodyMetricsRepositoryProvider).create(
            weightKg: weight,
            bodyFatPct: _num(_fat),
            muscleMassKg: _num(_muscle),
            bodyWaterPct: _num(_water),
            bmrDevice: _num(_bmr)?.round(),
          );
      ref.invalidate(bodyMetricsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Medição salva! Nova meta: ${metric.calorieGoal} kcal/dia')));
      context.pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = data is Map && data.isNotEmpty
          ? data.values.first.toString()
          : 'Não foi possível salvar.';
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
    final metricsAsync = ref.watch(bodyMetricsProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Registrar Medição', onBack: () => context.pop()),
            const Padding(
              padding: EdgeInsets.only(left: 54, top: 4),
              child: Text('Peso obrigatório · bioimpedância opcional',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
              children: [
                _BioField(label: 'Peso *', unit: 'kg', color: AppColors.primary, controller: _weight),
                _BioField(label: '% Gordura', unit: '%', color: AppColors.accent, controller: _fat),
                _BioField(label: 'Massa magra', unit: 'kg', color: AppColors.blueAccent, controller: _muscle),
                _BioField(label: 'Água corporal', unit: '%', color: AppColors.primary, controller: _water),
                _BioField(label: 'TMB (balança)', unit: 'kcal', color: AppColors.warning, controller: _bmr),
              ],
            ),
            const SizedBox(height: 22),
            PillButton(
              label: _saving ? 'Salvando...' : 'Salvar medição de hoje',
              icon: Icons.save_outlined,
              color: AppColors.accent,
              foreground: AppColors.onAccent,
              height: 52,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 26),
            const Text('Histórico',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            metricsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => const Text('Erro ao carregar histórico.',
                  style: TextStyle(color: AppColors.textSecondary)),
              data: (metrics) {
                if (metrics.isEmpty) {
                  return const Text('Nenhuma medição ainda.',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textMuted));
                }
                final reversed = metrics.reversed.toList();
                return Column(children: [
                  for (var i = 0; i < reversed.length && i < 12; i++) ...[
                    _HistoryRow(metric: reversed[i], highlight: i == 0),
                    const SizedBox(height: 10),
                  ],
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BioField extends StatelessWidget {
  const _BioField({
    required this.label,
    required this.unit,
    required this.color,
    required this.controller,
  });

  final String label;
  final String unit;
  final Color color;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTheme.grotesk(fontSize: 22),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    hintText: '—',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Text(unit,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.metric, required this.highlight});

  final BodyMetric metric;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM', 'pt_BR').format(metric.date);
    return FtCard(
      radius: 14,
      borderColor: highlight ? AppColors.primaryDark : AppColors.cardAlt,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: highlight ? AppColors.greenBgSoft : AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.calendar_today_outlined,
              size: 17,
              color: highlight ? AppColors.primary : AppColors.textMuted),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(highlight ? '$date · mais recente' : date,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        ),
        GroteskText('${metric.weightKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
            fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.primary),
        if (metric.bodyFatPct != null) ...[
          const SizedBox(width: 14),
          GroteskText(
              '${metric.bodyFatPct!.toStringAsFixed(1).replaceAll('.', ',')}%',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.accent),
        ],
      ]),
    );
  }
}
