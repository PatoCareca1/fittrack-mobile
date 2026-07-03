import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../workouts/data.dart';

class _SetEntry {
  _SetEntry({required this.load, required this.reps});

  final TextEditingController load;
  final TextEditingController reps;
  bool done = false;

  void dispose() {
    load.dispose();
    reps.dispose();
  }
}

/// Execução de treino ligada à API: start-session ao abrir, log-set a cada
/// série concluída, finish ao encerrar. Persistência offline-first (Hive)
/// fica para a fase pós-demo.
class ExecutionScreen extends ConsumerStatefulWidget {
  const ExecutionScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen> {
  WorkoutModel? _workout;
  int? _sessionId;
  int _exIndex = 0;
  final Map<int, List<_SetEntry>> _setsByExercise = {};
  late final DateTime _start = DateTime.now();
  Timer? _ticker;
  int _restLeft = 0;
  bool _restRunning = false;
  bool _finishing = false;
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_restRunning && _restLeft > 0) {
          _restLeft--;
          if (_restLeft == 0) _restRunning = false;
        }
      });
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final workouts = await ref.read(workoutsRepositoryProvider).list();
    final workout = workouts.where((w) => w.id == widget.workoutId).firstOrNull;
    if (workout == null || workout.exercises.isEmpty) {
      if (mounted) context.pop();
      return;
    }
    final sessionId =
        await ref.read(workoutsRepositoryProvider).startSession(workout.id);
    if (!mounted) return;
    setState(() {
      _workout = workout;
      _sessionId = sessionId;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _comment.dispose();
    for (final sets in _setsByExercise.values) {
      for (final entry in sets) {
        entry.dispose();
      }
    }
    super.dispose();
  }

  List<_SetEntry> _setsFor(int index) {
    return _setsByExercise.putIfAbsent(index, () {
      final we = _workout!.exercises[index];
      return List.generate(
        we.sets,
        (_) => _SetEntry(
          load: TextEditingController(
              text: we.loadKg == null
                  ? ''
                  : we.loadKg!.toStringAsFixed(we.loadKg! % 1 == 0 ? 0 : 1)),
          reps: TextEditingController(text: we.reps?.toString() ?? ''),
        ),
      );
    });
  }

  String _fmt(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  Future<void> _toggleSet(int setIndex) async {
    final we = _workout!.exercises[_exIndex];
    final entry = _setsFor(_exIndex)[setIndex];
    setState(() {
      entry.done = !entry.done;
      if (entry.done) {
        _restLeft = we.restSeconds;
        _restRunning = true;
      }
    });
    if (entry.done && _sessionId != null) {
      try {
        await ref.read(workoutsRepositoryProvider).logSet(
              sessionId: _sessionId!,
              workoutExerciseId: we.id,
              setNumber: setIndex + 1,
              repsDone: int.tryParse(entry.reps.text),
              loadKg: double.tryParse(entry.load.text.replaceAll(',', '.')),
            );
      } catch (_) {
        // Não interrompe o treino por falha de rede — o log fica local.
      }
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= _workout!.exercises.length) return;
    setState(() => _exIndex = index);
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      if (_sessionId != null) {
        await ref
            .read(workoutsRepositoryProvider)
            .finishSession(_sessionId!, notes: _comment.text.trim());
      }
      ref.invalidate(sessionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Treino registrado! 💪')));
        context.go('/evolucao');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _finishing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Falha ao finalizar. Verifique a conexão.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = _workout;
    if (workout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final exercise = workout.exercises[_exIndex];
    final sets = _setsFor(_exIndex);
    final elapsed = DateTime.now().difference(_start).inSeconds;
    final isFirst = _exIndex == 0;
    final isLast = _exIndex == workout.exercises.length - 1;

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
                      '${workout.name} · ${_exIndex + 1} de ${workout.exercises.length}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    GroteskText(_fmt(elapsed),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent),
                  ]),
                  Row(children: [
                    SquareIconButton(
                      icon: Icons.arrow_back_ios_new,
                      color: isFirst ? AppColors.textDisabled : AppColors.textPrimary,
                      onTap: () => _goTo(_exIndex - 1),
                    ),
                    const SizedBox(width: 8),
                    SquareIconButton(
                      icon: Icons.arrow_forward_ios,
                      color: isLast ? AppColors.textDisabled : AppColors.textPrimary,
                      onTap: () => _goTo(_exIndex + 1),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 18),

              // progresso por exercício (toque para pular direto)
              Row(children: [
                for (var i = 0; i < workout.exercises.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goTo(i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i < _exIndex
                              ? AppColors.primary
                              : i == _exIndex
                                  ? AppColors.accent
                                  : AppColors.cardAlt,
                          borderRadius: BorderRadius.circular(3),
                        ),
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
                    child: Center(
                        child:
                            MuscleIcon(color: exercise.exercise.muscleColor, size: 40)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.exercise.name,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 7, runSpacing: 6, children: [
                          FtTag(exercise.exercise.muscleLabel.toUpperCase(),
                              color: exercise.exercise.muscleColor),
                          FtTag(exercise.scheme,
                              color: AppColors.textSecondary, filled: false),
                          FtTag('DESCANSO ${exercise.restSeconds}s',
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
                  Text('Edite carga/reps e toque no ✓',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              _SetHeaderRow(),
              const SizedBox(height: 8),
              for (var i = 0; i < sets.length; i++) ...[
                _SetRow(
                    index: i, entry: sets[i], onToggle: () => _toggleSet(i)),
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
                          : (_restLeft > 0
                              ? 'Continuar'
                              : 'Iniciar ${exercise.restSeconds}s'),
                      primary: true,
                      onTap: () => setState(() {
                        if (_restLeft > 0) {
                          _restRunning = !_restRunning;
                        } else {
                          _restLeft = exercise.restSeconds;
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
                label: _finishing ? 'Finalizando...' : 'Finalizar treino',
                onPressed: _finishing ? null : _finish,
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
        Expanded(child: _ValueField(controller: entry.load, suffix: 'kg')),
        const SizedBox(width: 8),
        Expanded(child: _ValueField(controller: entry.reps)),
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

class _ValueField extends StatelessWidget {
  const _ValueField({required this.controller, this.suffix});

  final TextEditingController controller;
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
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTheme.grotesk(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 7),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (suffix != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(suffix!,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ),
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
                  padding: EdgeInsets.zero,
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
                  padding: EdgeInsets.zero,
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
