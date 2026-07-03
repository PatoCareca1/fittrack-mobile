import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../auth/providers.dart';

/// Labels/cores por grupo muscular (paleta da seção 6 — verde/laranja/azul).
const muscleGroups = <String, (String, Color)>{
  'chest': ('Peito', AppColors.primary),
  'back': ('Costas', AppColors.blueAccent),
  'shoulders': ('Ombros', AppColors.accent),
  'biceps': ('Bíceps', AppColors.accent),
  'triceps': ('Tríceps', AppColors.accent),
  'forearms': ('Antebraços', AppColors.accent),
  'core': ('Core', AppColors.warning),
  'glutes': ('Glúteos', AppColors.primary),
  'quads': ('Quadríceps', AppColors.blueAccent),
  'hamstrings': ('Posteriores', AppColors.blueAccent),
  'calves': ('Panturrilhas', AppColors.blueAccent),
  'cardio': ('Cardio', AppColors.error),
  'full_body': ('Corpo todo', AppColors.primary),
};

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  final int id;
  final String name;
  final String muscleGroup;

  String get muscleLabel => muscleGroups[muscleGroup]?.$1 ?? muscleGroup;
  Color get muscleColor => muscleGroups[muscleGroup]?.$2 ?? AppColors.primary;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'] as int,
        name: json['name'] as String,
        muscleGroup: json['muscle_group'] as String,
      );
}

class WorkoutExerciseModel {
  const WorkoutExerciseModel({
    required this.id,
    required this.exercise,
    required this.order,
    required this.sets,
    this.reps,
    this.loadKg,
    required this.restSeconds,
  });

  final int id;
  final ExerciseModel exercise;
  final int order;
  final int sets;
  final int? reps;
  final double? loadKg;
  final int restSeconds;

  String get scheme => '$sets×${reps ?? "-"}';
  String get loadLabel =>
      loadKg == null ? 'livre' : '${loadKg!.toStringAsFixed(loadKg! % 1 == 0 ? 0 : 1)}kg';

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) =>
      WorkoutExerciseModel(
        id: json['id'] as int,
        exercise:
            ExerciseModel.fromJson(json['exercise_detail'] as Map<String, dynamic>),
        order: json['order'] as int,
        sets: json['sets'] as int,
        reps: json['reps'] as int?,
        loadKg: json['load_kg'] == null ? null : double.parse('${json['load_kg']}'),
        restSeconds: json['rest_seconds'] as int? ?? 60,
      );
}

class WorkoutModel {
  const WorkoutModel({required this.id, required this.name, required this.exercises});

  final int id;
  final String name;
  final List<WorkoutExerciseModel> exercises;

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['id'] as int,
        name: json['name'] as String,
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutSessionModel {
  const WorkoutSessionModel({
    required this.id,
    required this.workoutName,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    required this.totalLoadKg,
  });

  final int id;
  final String workoutName;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final double totalLoadKg;

  Duration? get duration => finishedAt?.difference(startedAt);

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    double tonnage = 0;
    for (final log in (json['set_logs'] as List? ?? [])) {
      final load = log['load_kg'];
      final reps = log['reps_done'];
      if (load != null && reps != null) {
        tonnage += double.parse('$load') * (reps as int);
      }
    }
    return WorkoutSessionModel(
      id: json['id'] as int,
      workoutName: (json['workout'] is Map)
          ? json['workout']['name'] as String
          : 'Treino',
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      totalLoadKg: tonnage,
    );
  }
}

/// Payload de exercício ao criar treino.
class NewExercise {
  NewExercise({
    required this.exercise,
    this.sets = 3,
    this.reps = 12,
    this.loadKg,
    this.restSeconds = 60,
  });

  final ExerciseModel exercise;
  int sets;
  int reps;
  double? loadKg;
  int restSeconds;
}

class WorkoutsRepository {
  WorkoutsRepository(this._ref);

  final Ref _ref;

  Future<List<WorkoutModel>> list() async {
    final res = await _ref.read(apiClientProvider).dio.get('/workouts/');
    return (res.data as List)
        .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExerciseModel>> listExercises() async {
    final res = await _ref.read(apiClientProvider).dio.get('/exercises/');
    return (res.data as List)
        .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WorkoutModel> createWorkout(String name, List<NewExercise> exercises) async {
    final res = await _ref.read(apiClientProvider).dio.post('/workouts/', data: {
      'name': name,
      'exercises': [
        for (var i = 0; i < exercises.length; i++)
          {
            'exercise': exercises[i].exercise.id,
            'order': i + 1,
            'sets': exercises[i].sets,
            'reps': exercises[i].reps,
            if (exercises[i].loadKg != null) 'load_kg': exercises[i].loadKg,
            'rest_seconds': exercises[i].restSeconds,
          },
      ],
    });
    return WorkoutModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkout(int id) =>
      _ref.read(apiClientProvider).dio.delete('/workouts/$id/');

  Future<int> startSession(int workoutId) async {
    final res = await _ref
        .read(apiClientProvider)
        .dio
        .post('/workouts/$workoutId/start-session/');
    return res.data['id'] as int;
  }

  Future<void> logSet({
    required int sessionId,
    required int workoutExerciseId,
    required int setNumber,
    int? repsDone,
    double? loadKg,
  }) =>
      _ref
          .read(apiClientProvider)
          .dio
          .patch('/workout-sessions/$sessionId/log-set/', data: {
        'workout_exercise': workoutExerciseId,
        'set_number': setNumber,
        if (repsDone != null) 'reps_done': repsDone,
        if (loadKg != null) 'load_kg': loadKg,
      });

  Future<void> finishSession(int sessionId, {String notes = ''}) => _ref
      .read(apiClientProvider)
      .dio
      .post('/workout-sessions/$sessionId/finish/',
          data: {if (notes.isNotEmpty) 'notes': notes});

  Future<List<WorkoutSessionModel>> listSessions() async {
    final res = await _ref.read(apiClientProvider).dio.get('/workout-sessions/');
    return (res.data as List)
        .map((json) => WorkoutSessionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final workoutsRepositoryProvider = Provider((ref) => WorkoutsRepository(ref));

final workoutsProvider = FutureProvider<List<WorkoutModel>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(workoutsRepositoryProvider).list();
});

final exercisesProvider = FutureProvider<List<ExerciseModel>>(
  (ref) => ref.watch(workoutsRepositoryProvider).listExercises(),
);

final sessionsProvider = FutureProvider<List<WorkoutSessionModel>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(workoutsRepositoryProvider).listSessions();
});
