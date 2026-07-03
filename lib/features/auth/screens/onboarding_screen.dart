import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class _OnbPage {
  const _OnbPage(this.title, this.desc, this.cards);

  final String title;
  final String desc;
  final List<(Color, Color, String, String)> cards;
}

const _pages = [
  _OnbPage(
    'Desbloqueie seu Potencial',
    'Treinos personalizados que evoluem com você. Cada série, cada carga, registrada e acompanhada.',
    [
      (AppColors.greenBgSoft, AppColors.primary, 'Treinos Personalizados', 'Divisões A/B/C sob medida'),
      (AppColors.orangeBgSoft, AppColors.accent, 'Acompanhe a Carga', 'Progressão automática'),
    ],
  ),
  _OnbPage(
    'Controle Total da Dieta',
    'Macros, calorias e refeições com a base TACO e Open Food Facts na palma da mão.',
    [
      (AppColors.greenBgSoft, AppColors.primary, 'Controle de Macros', 'Proteína, carbo e gordura'),
      (AppColors.blueBgSoft, AppColors.blueAccent, 'Base TACO + OFF', 'Milhares de alimentos'),
    ],
  ),
  _OnbPage(
    'Evolua com Profissionais',
    'Conecte-se ao seu personal e nutricionista. Receba planos e acompanhe sua evolução juntos.',
    [
      (AppColors.greenBgSoft, AppColors.primary, 'Personal Trainer', 'Treinos atribuídos'),
      (AppColors.blueBgSoft, AppColors.blueAccent, 'Nutricionista', 'Planos de dieta'),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    FtLogo(),
                    SizedBox(width: 8),
                    Text('FitTrack',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -.3)),
                  ]),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Pular',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    _OnbArt(index: _index),
                    const SizedBox(height: 28),
                    Text(page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -.8)),
                    const SizedBox(height: 14),
                    Text(page.desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, height: 1.55, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    for (final c in page.cards) ...[
                      FtCard(
                        radius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: c.$1, borderRadius: BorderRadius.circular(11)),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                    color: c.$2, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.$3,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              Text(c.$4,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ]),
                      ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => _index = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: i == _index ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _index ? AppColors.accent : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PillButton(
                label: _index == 2 ? 'Começar' : 'Próximo',
                color: AppColors.accent,
                foreground: AppColors.onAccent,
                onPressed: () {
                  if (_index < 2) {
                    setState(() => _index++);
                  } else {
                    context.go('/login');
                  }
                },
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: RichText(
                  text: const TextSpan(
                    text: 'Já tenho conta · ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(
                          text: 'Entrar',
                          style: TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnbArt extends StatelessWidget {
  const _OnbArt({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.primary, AppColors.blueAccent, AppColors.primary];
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 154,
            height: 154,
            child: CircularProgressIndicator(
              value: [0.72, 0.45, 0.5][index],
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              color: colors[index],
              backgroundColor: AppColors.cardAlt,
            ),
          ),
          Icon(
            [Icons.fitness_center, Icons.restaurant, Icons.groups][index],
            size: 54,
            color: colors[index],
          ),
        ],
      ),
    );
  }
}
