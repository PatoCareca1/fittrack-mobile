import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';

/// Aceite de convite via código de 6 dígitos
/// (endpoint futuro: POST /professional/links/invite/).
class AcceptInviteScreen extends StatefulWidget {
  const AcceptInviteScreen({super.key});

  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final _controller = TextEditingController(text: 'FIT72');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SquareIconButton(
                    icon: Icons.arrow_back_ios_new, onTap: () => context.pop()),
              ),
              const SizedBox(height: 28),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.greenBgSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryDark),
                ),
                child: const Icon(Icons.person_add_alt,
                    size: 30, color: AppColors.primary),
              ),
              const SizedBox(height: 22),
              const Text('Aceitar convite',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.4)),
              const SizedBox(height: 10),
              const Text(
                'Digite o código de 6 dígitos que seu personal ou nutricionista compartilhou com você.',
                style: TextStyle(
                    fontSize: 14, height: 1.55, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 26),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final code = value.text.toUpperCase();
                  return Stack(children: [
                    Row(children: [
                      for (var i = 0; i < 6; i++) ...[
                        Expanded(
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: i < code.length
                                  ? AppColors.greenBgSoft
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: i <= code.length
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(i < code.length ? code[i] : '',
                                  style: AppTheme.grotesk(fontSize: 24)),
                            ),
                          ),
                        ),
                        if (i < 5) const SizedBox(width: 9),
                      ],
                    ]),
                    // campo invisível por cima para capturar digitação
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _controller,
                          maxLength: 6,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                    ),
                  ]);
                },
              ),
              const SizedBox(height: 26),
              PillButton(
                label: 'Vincular profissional',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Convite aceito! Profissional vinculado.')));
                  context.pop();
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'O profissional poderá atribuir treinos e planos alimentares',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
