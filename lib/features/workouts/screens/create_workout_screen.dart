import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data.dart';

/// Criar Treino: nome + exercícios do catálogo com séries/reps/carga/descanso.
class CreateWorkoutScreen extends ConsumerStatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  ConsumerState<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final _name = TextEditingController();
  final List<NewExercise> _selected = [];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final picked = await showModalBottomSheet<ExerciseModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => const _ExercisePickerSheet(),
    );
    if (picked != null) {
      setState(() => _selected.add(NewExercise(exercise: picked)));
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Dê um nome e adicione ao menos 1 exercício.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(workoutsRepositoryProvider).createWorkout(name, _selected);
      ref.invalidate(workoutsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Treino "$name" criado! 💪')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Não foi possível salvar. Tente novamente.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              ScreenHeader(title: 'Criar Treino', onBack: () => context.pop()),
              const SizedBox(height: 20),
              const Text('Nome do treino',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                    hintText: 'ex.: Treino A · Peito e Tríceps'),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Exercícios',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('${_selected.length} adicionados',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _selected.length; i++) ...[
                _ExerciseConfigCard(
                  entry: _selected[i],
                  onRemove: () => setState(() => _selected.removeAt(i)),
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 10),
              ],
              InkWell(
                onTap: _pickExercise,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Adicionar exercício',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
                label: _saving ? 'Salvando...' : 'Salvar treino',
                color: AppColors.accent,
                foreground: AppColors.onAccent,
                onPressed: _saving ? null : _save,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ExerciseConfigCard extends StatelessWidget {
  const _ExerciseConfigCard({
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  final NewExercise entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return FtCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.cardAlt),
            ),
            child: Center(
                child: MuscleIcon(color: entry.exercise.muscleColor, size: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.exercise.name,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                FtTag(entry.exercise.muscleLabel.toUpperCase(),
                    color: entry.exercise.muscleColor),
              ],
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: AppColors.error),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _Stepper(
            label: 'Séries',
            value: entry.sets,
            onChanged: (v) {
              entry.sets = v.clamp(1, 10);
              onChanged();
            },
          ),
          const SizedBox(width: 8),
          _Stepper(
            label: 'Reps',
            value: entry.reps,
            step: 1,
            onChanged: (v) {
              entry.reps = v.clamp(1, 100);
              onChanged();
            },
          ),
          const SizedBox(width: 8),
          _Stepper(
            label: 'Carga kg',
            value: entry.loadKg?.round() ?? 0,
            step: 2,
            onChanged: (v) {
              entry.loadKg = v <= 0 ? null : v.toDouble();
              onChanged();
            },
          ),
          const SizedBox(width: 8),
          _Stepper(
            label: 'Desc. s',
            value: entry.restSeconds,
            step: 15,
            onChanged: (v) {
              entry.restSeconds = v.clamp(15, 300);
              onChanged();
            },
          ),
        ]),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            InkWell(
              onTap: () => onChanged(value - step),
              child: const SizedBox(
                  width: 24,
                  child: Icon(Icons.remove, size: 13, color: AppColors.textMuted)),
            ),
            Expanded(
              child: Center(
                child: Text(value == 0 && label == 'Carga kg' ? '—' : '$value',
                    style: AppTheme.grotesk(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            InkWell(
              onTap: () => onChanged(value + step),
              child: const SizedBox(
                  width: 24,
                  child: Icon(Icons.add, size: 13, color: AppColors.textMuted)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  String _query = '';
  String? _group;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      minChildSize: .5,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Buscar exercício...',
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _GroupChip(
                  label: 'Todos',
                  selected: _group == null,
                  color: AppColors.primary,
                  onTap: () => setState(() => _group = null),
                ),
                for (final entry in muscleGroups.entries)
                  _GroupChip(
                    label: entry.value.$1,
                    selected: _group == entry.key,
                    color: entry.value.$2,
                    onTap: () => setState(() => _group = entry.key),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => const Center(
                  child: Text('Erro ao carregar exercícios',
                      style: TextStyle(color: AppColors.textSecondary))),
              data: (exercises) {
                final filtered = exercises
                    .where((e) =>
                        (_group == null || e.muscleGroup == _group) &&
                        e.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final exercise = filtered[i];
                    return FtCard(
                      onTap: () => Navigator.pop(context, exercise),
                      radius: 12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(children: [
                        MuscleIcon(color: exercise.muscleColor, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(exercise.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        FtTag(exercise.muscleLabel.toUpperCase(),
                            color: exercise.muscleColor),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .15) : AppColors.card,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : AppColors.textSecondary)),
          ),
        ),
      ),
    );
  }
}
