import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../mock/mock_data.dart';

class _SetEntry {
  _SetEntry({required this.load, required this.reps, this.done = false});

  String load;
  String reps;
  bool done;
}

/// Execução de treino. Estado local por enquanto; a persistência offline-first
/// em Hive + sync (regra crítica do README 5.4) entra na fase de integração.
class ExecutionScreen extends StatefulWidget {
  const ExecutionScreen({super.key, required this.letter});

  final String letter;

  @override
  State<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends State<ExecutionScreen> {
  late final MockWorkout _workout = MockData.workouts.firstWhere(
    (w) => w.letter == widget.letter,
    orElse: () => MockData.workouts.first,
  );

  int _exIndex = 0;
  late final DateTime _start = DateTime.now();
  Timer? _ticker;
  int _restLeft = 0;
  bool _restRunning = false;
  final _comment = TextEditingController();

  late List<_SetEntry> _sets = _buildSets();

  List<_SetEntry> _buildSets() => [
        _SetEntry(load: '60', reps: '10', done: true),
        _SetEntry(load: '60', reps: '9', done: true),
        _SetEntry(load: '62', reps: '8'),
        _SetEntry(load: '62', reps: ''),
      ];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_restRunning && _restLeft > 0) {
          _restLeft--;
          if (_restLeft == 0) _restRunning = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _comment.dispose();
    super.dispose();
  }

  String _fmt(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _toggleSet(int i) {
    setState(() {
      _sets[i].done = !_sets[i].done;
      if (_sets[i].done) {
        _restLeft = 90;
        _restRunning = true;
      }
    });
  }

  void _nextExercise() {
    if (_exIndex < _workout.exercises.length - 1) {
      setState(() {
        _exIndex++;
        _sets = _buildSets();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _workout.exercises[_exIndex];
    final elapsed = DateTime.now().difference(_start).inSeconds;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SquareIconButton(icon: Icons.close, onTap: () => context.pop()),
                  Column(children: [
                    Text(
                      'Treino ${_workout.letter} · Exercício ${_exIndex + 1} de ${_workout.exercises.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    GroteskText(_fmt(elapsed),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent),
                  ]),
                  SquareIconButton(
                      icon: Icons.arrow_forward_ios, onTap: _nextExercise),
                ],
              ),
              const SizedBox(height: 18),

              // progresso por exercício
              Row(children: [
                for (var i = 0; i < _workout.exercises.length; i++)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < _exIndex
                            ? AppColors.primary
                            : i == _exIndex
                                ? AppColors.accent
                                : AppColors.cardAlt,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 18),

              FtCard(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.greenBgSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: MuscleIcon(color: exercise.color, size: 40)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 7, runSpacing: 6, children: [
                          FtTag(exercise.muscle, color: exercise.color),
                          FtTag(exercise.equipment,
                              color: AppColors.textSecondary, filled: false),
                          const FtTag('COMPOSTO',
                              color: AppColors.textSecondary, filled: false),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 18),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Séries',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('Toque no ✓ para concluir',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              _SetHeaderRow(),
              const SizedBox(height: 8),
              for (var i = 0; i < _sets.length; i++) ...[
                _SetRow(index: i, entry: _sets[i], onToggle: () => _toggleSet(i)),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 10),

              // timer de descanso
              FtCard(
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(children: [
                        Icon(Icons.timer_outlined, size: 18, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('Descanso',
                            style:
                                TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ]),
                      GroteskText(
                        _restLeft > 0 ? _fmt(_restLeft) : 'Pronto',
                        fontSize: 24,
                        color: _restLeft > 0 ? AppColors.accent : AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    _TimerButton(
                      label: '−15s',
                      onTap: () => setState(
                          () => _restLeft = (_restLeft - 15).clamp(0, 3600)),
                    ),
                    const SizedBox(width: 8),
                    _TimerButton(
                      label: _restRunning
                          ? 'Pausar'
                          : (_restLeft > 0 ? 'Continuar' : 'Iniciar 90s'),
                      primary: true,
                      onTap: () => setState(() {
                        if (_restLeft > 0) {
                          _restRunning = !_restRunning;
                        } else {
                          _restLeft = 90;
                          _restRunning = true;
                        }
                      }),
                    ),
                    const SizedBox(width: 8),
                    _TimerButton(
                      label: '+15s',
                      onTap: () => setState(() {
                        _restLeft += 15;
                        _restRunning = true;
                      }),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              const Text('Comentário da sessão',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _comment,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Como foi o treino? Sensações, dores, observações...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
              ),
              child: PillButton(
                label: 'Finalizar treino',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Treino registrado! 💪')));
                  context.go('/evolucao');
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SetHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#', style: style)),
        Expanded(child: Center(child: Text('CARGA (KG)', style: style))),
        SizedBox(width: 8),
        Expanded(child: Center(child: Text('REPS', style: style))),
        SizedBox(width: 52),
      ]),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.index, required this.entry, required this.onToggle});

  final int index;
  final _SetEntry entry;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final done = entry.done;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: done ? AppColors.greenBgSoft : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? AppColors.primaryDark : AppColors.cardAlt),
      ),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: Center(
            child: Text('${index + 1}',
                style: AppTheme.grotesk(
                    fontSize: 14,
                    color: done ? AppColors.primary : AppColors.textSecondary)),
          ),
        ),
        Expanded(child: _ValueBox(value: entry.load, suffix: 'kg')),
        const SizedBox(width: 8),
        Expanded(child: _ValueBox(value: entry.reps)),
        const SizedBox(width: 8),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.cardAlt,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.check,
                size: 18, color: done ? AppColors.onPrimary : AppColors.textMuted),
          ),
        ),
      ]),
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.value, this.suffix});

  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value.isEmpty ? '—' : value,
            style: AppTheme.grotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:
                    value.isEmpty ? AppColors.textDisabled : AppColors.textPrimary)),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix!,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ]),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.label, required this.onTap, this.primary = false});

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: primary
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  textStyle:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(label),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textSecondary,
                  textStyle:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(label),
              ),
      ),
    );
  }
}
