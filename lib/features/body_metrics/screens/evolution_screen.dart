import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  String _metric = 'peso';

  @override
  Widget build(BuildContext context) {
    final data = MockData.evolution[_metric]!;
    final current = data.$3.last.toString().replaceAll('.', ',');
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text('Evolução',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
          const SizedBox(height: 4),
          const Text('Seu progresso ao longo do tempo',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 18),

          // tabs de métrica
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardAlt),
            ),
            child: Row(children: [
              for (final t in const [('peso', 'Peso'), ('gordura', 'Gordura'), ('magra', 'Massa magra')])
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _metric = t.$1),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: _metric == t.$1 ? AppColors.cardAlt : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(t.$2,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _metric == t.$1
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 18),

          FtCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data.$1} atual',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          GroteskText(current, fontSize: 30),
                          Text(' ${data.$2}',
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.greenBgSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Icon(data.$6 ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(data.$5,
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
                child: CustomPaint(
                  painter: _LineChartPainter(values: data.$3, color: data.$4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          const Text('Sessões de treino',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final s in MockData.sessions) ...[
            FtCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: s.$5.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fitness_center, size: 20, color: s.$5),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${s.$1} · ${s.$3}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                GroteskText(s.$4,
                    fontSize: 14, fontWeight: FontWeight.w600, color: s.$5),
              ]),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Gráfico de linha com gradiente — mesmo estilo do LineChart SVG do painel web.
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});

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
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.color != color;
}
