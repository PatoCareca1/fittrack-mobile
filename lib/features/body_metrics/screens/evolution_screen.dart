import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../workouts/data.dart';
import '../data.dart';

class EvolutionScreen extends ConsumerStatefulWidget {
  const EvolutionScreen({super.key});

  @override
  ConsumerState<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends ConsumerState<EvolutionScreen> {
  String _metric = 'peso';

  static const _tabs = [('peso', 'Peso'), ('gordura', 'Gordura'), ('magra', 'Massa magra')];

  (String, String, Color, List<(DateTime, double)>) _series(List<BodyMetric> metrics) {
    switch (_metric) {
      case 'gordura':
        return (
          'Gordura',
          '%',
          AppColors.accent,
          [
            for (final m in metrics)
              if (m.bodyFatPct != null) (m.date, m.bodyFatPct!)
          ],
        );
      case 'magra':
        return (
          'Massa magra',
          'kg',
          AppColors.blueAccent,
          [
            for (final m in metrics)
              if (m.muscleMassKg != null) (m.date, m.muscleMassKg!)
          ],
        );
      default:
        return (
          'Peso',
          'kg',
          AppColors.primary,
          [for (final m in metrics) (m.date, m.weightKg)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(bodyMetricsProvider);
          ref.invalidate(sessionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text('Evolução',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            const SizedBox(height: 4),
            const Text('Seu progresso ao longo do tempo',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardAlt),
              ),
              child: Row(children: [
                for (final tab in _tabs)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _metric = tab.$1),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: _metric == tab.$1
                              ? AppColors.cardAlt
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text(tab.$2,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _metric == tab.$1
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 18),

            metricsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Não foi possível carregar as medições.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              data: (metrics) {
                final (label, unit, color, points) = _series(metrics);
                if (points.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(children: [
                      const Icon(Icons.monitor_weight_outlined,
                          size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('Sem registros de ${label.toLowerCase()} ainda',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Registre em Perfil → Bioimpedância',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ]),
                  );
                }
                final current = points.last.$2;
                final delta = points.length > 1 ? current - points.first.$2 : 0.0;
                final deltaLabel =
                    '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1).replaceAll('.', ',')}$unit';
                return FtCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$label atual',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                GroteskText(
                                    current
                                        .toStringAsFixed(1)
                                        .replaceAll('.', ','),
                                    fontSize: 30),
                                Text(' $unit',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        if (points.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.greenBgSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(children: [
                              Icon(
                                  delta <= 0
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 14,
                                  color: AppColors.primary),
                              const SizedBox(width: 5),
                              Text(deltaLabel,
                                  style: AppTheme.grotesk(
                                      fontSize: 13, color: AppColors.primary)),
                            ]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: points.length == 1
                          ? const Center(
                              child: Text(
                                  'Registre mais medições para ver o gráfico',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textMuted)))
                          : CustomPaint(
                              painter: LineChartPainter(
                                values: [for (final p in points) p.$2],
                                color: color,
                              ),
                            ),
                    ),
                  ]),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text('Sessões de treino',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            sessionsAsync.when(
              loading: () => const SizedBox(),
              error: (e, _) => const SizedBox(),
              data: (sessions) {
                final done =
                    sessions.where((s) => s.status == 'completed').toList();
                if (done.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Nenhum treino concluído ainda.',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  );
                }
                return Column(children: [
                  for (final session in done.take(10)) ...[
                    _SessionRow(session: session),
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

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final WorkoutSessionModel session;

  @override
  Widget build(BuildContext context) {
    final when = DateFormat('d MMM · HH:mm', 'pt_BR').format(session.startedAt);
    final minutes = session.duration?.inMinutes;
    final tonnage = session.totalLoadKg >= 1000
        ? '${(session.totalLoadKg / 1000).toStringAsFixed(1).replaceAll('.', ',')}t'
        : '${session.totalLoadKg.round()}kg';
    return FtCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center,
              size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.workoutName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(minutes == null ? when : '$when · $minutes min',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        GroteskText(tonnage,
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
      ]),
    );
  }
}

/// Gráfico de linha com gradiente — mesmo estilo do LineChart SVG do painel web.
class LineChartPainter extends CustomPainter {
  LineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 10.0;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1 : max - min;
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          pad + i * (size.width - 2 * pad) / (values.length - 1),
          size.height - pad - ((values[i] - min) / range) * (size.height - 2 * pad),
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .3), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < points.length; i++) {
      final last = i == points.length - 1;
      canvas.drawCircle(
        points[i],
        last ? 4.5 : 2.4,
        Paint()..color = last ? color : AppColors.card,
      );
      canvas.drawCircle(
        points[i],
        last ? 4.5 : 2.4,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) =>
      old.values != values || old.color != color;
}
