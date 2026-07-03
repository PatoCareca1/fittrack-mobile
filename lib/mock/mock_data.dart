import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Dados mockados espelhando o protótipo aprovado (`FitTrack.dc.html`).
///
/// Mesmo racional do painel web (`fittrack-frontend/src/lib/mock-data.ts`):
/// o backend ainda não expõe todos os endpoints; ao integrar a API real,
/// substituir por repositories em `features/*/data/` mantendo os shapes.
class MockWorkout {
  const MockWorkout({
    required this.letter,
    required this.name,
    required this.color,
    required this.exerciseCount,
    required this.sets,
    required this.exercises,
  });

  final String letter;
  final String name;
  final Color color;
  final int exerciseCount;
  final int sets;
  final List<MockExercise> exercises;
}

class MockExercise {
  const MockExercise({
    required this.name,
    required this.muscle,
    required this.color,
    required this.scheme,
    required this.load,
    required this.rest,
    required this.equipment,
  });

  final String name;
  final String muscle;
  final Color color;
  final String scheme;
  final String load;
  final String rest;
  final String equipment;
}

class MockMeal {
  const MockMeal({
    required this.name,
    required this.time,
    required this.kcal,
    required this.done,
    required this.foods,
  });

  final String name;
  final String time;
  final int kcal;
  final bool done;
  final List<String> foods;
}

class MockFood {
  const MockFood({
    required this.name,
    required this.source,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String name;
  final String source; // TACO | OFF
  final int kcal;
  final num protein;
  final num carbs;
  final num fat;

  Color get sourceColor =>
      source == 'TACO' ? AppColors.primary : AppColors.blueAccent;
}

class MockChatMessage {
  const MockChatMessage({required this.mine, required this.text, required this.time});

  final bool mine;
  final String text;
  final String time;
}

abstract class MockData {
  static const userName = 'Lucas Andrade';
  static const userEmail = 'lucas@email.com';

  static const workouts = [
    MockWorkout(
      letter: 'A',
      name: 'Peito e Tríceps',
      color: AppColors.primary,
      exerciseCount: 8,
      sets: 24,
      exercises: [
        MockExercise(name: 'Supino Reto', muscle: 'PEITO', color: AppColors.primary, scheme: '4×8-10', load: '60kg', rest: '90s', equipment: 'BARRA'),
        MockExercise(name: 'Supino Inclinado', muscle: 'PEITO', color: AppColors.primary, scheme: '3×10', load: '24kg', rest: '75s', equipment: 'HALTER'),
        MockExercise(name: 'Crucifixo', muscle: 'PEITO', color: AppColors.primary, scheme: '3×12', load: '16kg', rest: '60s', equipment: 'HALTER'),
        MockExercise(name: 'Crossover', muscle: 'PEITO', color: AppColors.primary, scheme: '3×15', load: '20kg', rest: '60s', equipment: 'CABO'),
        MockExercise(name: 'Tríceps Pulley', muscle: 'TRÍCEPS', color: AppColors.accent, scheme: '4×12', load: '35kg', rest: '60s', equipment: 'CABO'),
        MockExercise(name: 'Tríceps Testa', muscle: 'TRÍCEPS', color: AppColors.accent, scheme: '3×10', load: '30kg', rest: '60s', equipment: 'BARRA'),
        MockExercise(name: 'Tríceps Corda', muscle: 'TRÍCEPS', color: AppColors.accent, scheme: '3×15', load: '25kg', rest: '45s', equipment: 'CABO'),
        MockExercise(name: 'Mergulho', muscle: 'TRÍCEPS', color: AppColors.accent, scheme: '3×máx', load: 'peso', rest: '60s', equipment: 'LIVRE'),
      ],
    ),
    MockWorkout(
      letter: 'B',
      name: 'Costas e Bíceps',
      color: AppColors.accent,
      exerciseCount: 7,
      sets: 21,
      exercises: [
        MockExercise(name: 'Puxada Frontal', muscle: 'COSTAS', color: AppColors.blueAccent, scheme: '4×10', load: '55kg', rest: '75s', equipment: 'CABO'),
        MockExercise(name: 'Remada Curvada', muscle: 'COSTAS', color: AppColors.blueAccent, scheme: '4×8', load: '50kg', rest: '90s', equipment: 'BARRA'),
        MockExercise(name: 'Remada Unilateral', muscle: 'COSTAS', color: AppColors.blueAccent, scheme: '3×12', load: '28kg', rest: '60s', equipment: 'HALTER'),
        MockExercise(name: 'Rosca Direta', muscle: 'BÍCEPS', color: AppColors.accent, scheme: '4×10', load: '30kg', rest: '60s', equipment: 'BARRA'),
        MockExercise(name: 'Rosca Alternada', muscle: 'BÍCEPS', color: AppColors.accent, scheme: '3×12', load: '14kg', rest: '45s', equipment: 'HALTER'),
        MockExercise(name: 'Rosca Martelo', muscle: 'BÍCEPS', color: AppColors.accent, scheme: '3×12', load: '16kg', rest: '45s', equipment: 'HALTER'),
      ],
    ),
    MockWorkout(
      letter: 'C',
      name: 'Pernas e Ombro',
      color: AppColors.blueAccent,
      exerciseCount: 9,
      sets: 27,
      exercises: [
        MockExercise(name: 'Agachamento Livre', muscle: 'QUADRÍCEPS', color: AppColors.blueAccent, scheme: '4×8', load: '80kg', rest: '120s', equipment: 'BARRA'),
        MockExercise(name: 'Leg Press', muscle: 'QUADRÍCEPS', color: AppColors.blueAccent, scheme: '4×12', load: '160kg', rest: '90s', equipment: 'MÁQUINA'),
        MockExercise(name: 'Cadeira Extensora', muscle: 'QUADRÍCEPS', color: AppColors.blueAccent, scheme: '3×15', load: '45kg', rest: '60s', equipment: 'MÁQUINA'),
        MockExercise(name: 'Mesa Flexora', muscle: 'POSTERIOR', color: AppColors.primary, scheme: '3×12', load: '40kg', rest: '60s', equipment: 'MÁQUINA'),
        MockExercise(name: 'Panturrilha em Pé', muscle: 'PANTURRILHA', color: AppColors.primary, scheme: '4×15', load: '60kg', rest: '45s', equipment: 'MÁQUINA'),
        MockExercise(name: 'Desenvolvimento', muscle: 'OMBROS', color: AppColors.accent, scheme: '4×10', load: '20kg', rest: '75s', equipment: 'HALTER'),
        MockExercise(name: 'Elevação Lateral', muscle: 'OMBROS', color: AppColors.accent, scheme: '3×12', load: '10kg', rest: '45s', equipment: 'HALTER'),
        MockExercise(name: 'Elevação Frontal', muscle: 'OMBROS', color: AppColors.accent, scheme: '3×12', load: '10kg', rest: '45s', equipment: 'HALTER'),
        MockExercise(name: 'Encolhimento', muscle: 'TRAPÉZIO', color: AppColors.accent, scheme: '3×15', load: '24kg', rest: '45s', equipment: 'HALTER'),
      ],
    ),
  ];

  /// Plano atribuído pelo personal (somente leitura — RN10).
  static MockWorkout get assignedWorkout => workouts[1];

  static const templates = [
    ('Push Pull Legs', '6× por semana', 'Intermediário', AppColors.primary),
    ('Full Body 3x', '3× por semana', 'Iniciante', AppColors.blueAccent),
    ('Upper / Lower', '4× por semana', 'Intermediário', AppColors.accent),
    ('ABC Clássico', '3× por semana', 'Hipertrofia', AppColors.primary),
    ('Força 5×5', '5× por semana', 'Avançado', AppColors.error),
  ];

  static const meals = [
    MockMeal(name: 'Café da manhã', time: '7:30', kcal: 420, done: true, foods: ['Ovos mexidos', 'Pão integral', 'Café']),
    MockMeal(name: 'Almoço', time: '12:30', kcal: 680, done: true, foods: ['Arroz', 'Frango grelhado', 'Feijão', 'Salada']),
    MockMeal(name: 'Lanche', time: '16:00', kcal: 240, done: false, foods: ['Whey protein', 'Banana']),
    MockMeal(name: 'Jantar', time: '20:00', kcal: 500, done: false, foods: ['Batata doce', 'Tilápia', 'Brócolis']),
  ];

  static const kcalConsumed = 1840;
  static const kcalGoal = 2400;

  /// (nome, cor, consumido, meta) em gramas.
  static const macros = [
    ('Proteína', AppColors.blueAccent, 122, 160),
    ('Carbo', AppColors.accent, 180, 260),
    ('Gordura', AppColors.error, 48, 70),
  ];

  static const foods = [
    MockFood(name: 'Frango grelhado', source: 'TACO', kcal: 165, protein: 31, carbs: 0, fat: 3.6),
    MockFood(name: 'Peito de frango cru', source: 'TACO', kcal: 159, protein: 32, carbs: 0, fat: 2.5),
    MockFood(name: 'Frango à passarinho', source: 'OFF', kcal: 220, protein: 27, carbs: 2, fat: 11),
    MockFood(name: 'Sobrecoxa assada', source: 'TACO', kcal: 211, protein: 26, carbs: 0, fat: 11),
    MockFood(name: 'Frango desfiado', source: 'OFF', kcal: 143, protein: 25, carbs: 1, fat: 4),
  ];

  /// Itens da refeição em edição: (nome, quantidade, kcal).
  static const mealItems = [
    ('Arroz branco cozido', '150g', 193),
    ('Frango grelhado', '120g', 198),
    ('Feijão preto', '100g', 132),
    ('Salada verde', '80g', 24),
  ];

  /// Macros da refeição em edição: (nome, cor, gramas).
  static const mealMacros = [
    ('Proteína', AppColors.blueAccent, 46),
    ('Carbo', AppColors.accent, 62),
    ('Gordura', AppColors.error, 9),
  ];

  /// Séries de evolução: métrica -> (label, unidade, valores, cor, delta, caiu?).
  static const evolution = {
    'peso': ('Peso', 'kg', [82.0, 81.2, 80.5, 80.0, 79.3, 78.8, 78.5], AppColors.primary, '-3,5kg', true),
    'gordura': ('Gordura', '%', [22.0, 21.3, 20.5, 19.8, 19.2, 18.6, 18.1], AppColors.accent, '-3,9%', true),
    'magra': ('Massa magra', 'kg', [62.0, 62.4, 62.8, 63.1, 63.5, 63.9, 64.2], AppColors.blueAccent, '+2,2kg', false),
  };

  /// Sessões: (quando, treino, duração, tonelagem, cor).
  static const sessions = [
    ('Hoje', 'Treino A · Peito e Tríceps', '52 min', '4,2t', AppColors.primary),
    ('Ontem', 'Treino C · Pernas e Ombro', '58 min', '6,1t', AppColors.blueAccent),
    ('23 jun', 'Treino B · Costas e Bíceps', '49 min', '5,0t', AppColors.accent),
    ('21 jun', 'Treino A · Peito e Tríceps', '51 min', '4,0t', AppColors.primary),
  ];

  /// Histórico de bioimpedância: (data, % gordura, massa magra).
  static const bioHistory = [
    ('25 jun · hoje', '18,1%', '64,2 kg'),
    ('11 jun', '18,9%', '63,5 kg'),
    ('28 mai', '19,8%', '62,9 kg'),
    ('14 mai', '20,6%', '62,1 kg'),
  ];

  /// Campos de bioimpedância: (label, valor, unidade, cor).
  static const bioFields = [
    ('% Gordura', '18,1', '%', AppColors.accent),
    ('Massa magra', '64,2', 'kg', AppColors.blueAccent),
    ('Massa gorda', '14,3', 'kg', AppColors.error),
    ('Água corporal', '58', '%', AppColors.primary),
    ('M. esquelética', '35,4', 'kg', AppColors.blueAccent),
    ('TMB', '1780', 'kcal', AppColors.warning),
  ];

  static const chatMessages = [
    MockChatMessage(mine: false, text: 'Fala Lucas! Como foi o treino A de hoje?', time: '8:30'),
    MockChatMessage(mine: true, text: 'Foi pesado! Consegui subir a carga no supino pra 62kg.', time: '8:42'),
    MockChatMessage(mine: false, text: 'Boa! Tua progressão tá ótima. Semana que vem a gente aumenta o volume de tríceps.', time: '8:44'),
    MockChatMessage(mine: true, text: 'Fechou. Valeu, Rafa!', time: '8:45'),
    MockChatMessage(mine: false, text: 'Já atualizei seu Treino B. Dá uma olhada no plano atribuído quando puder.', time: '8:46'),
  ];
}
