import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../providers.dart';

const _accountTypes = [
  ('user', 'Usuário', 'Acompanhe seus treinos e dieta', AppColors.primary, AppColors.greenBgSoft, Icons.person_outline),
  ('personal', 'Personal Trainer', 'Crie e atribua treinos · CREF', AppColors.primary, AppColors.greenBgSoft, Icons.fitness_center),
  ('nutritionist', 'Nutricionista', 'Monte planos alimentares · CRN', AppColors.blueAccent, AppColors.blueBgSoft, Icons.restaurant),
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String _type = 'user';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref.read(authControllerProvider.notifier).register(
          accountType: _type,
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
    if (ok && mounted) context.go('/dados-fisicos?onboarding=1');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SquareIconButton(icon: Icons.arrow_back_ios_new, onTap: () => context.pop()),
              const SizedBox(height: 24),
              const Text('Criar conta',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              const SizedBox(height: 6),
              const Text('Escolha como você vai usar o FitTrack',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              for (final t in _accountTypes) ...[
                _AccountCard(
                  data: t,
                  selected: _type == t.$1,
                  onTap: () => setState(() => _type = t.$1),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'Nome completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Senha'),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              PillButton(
                label: auth.loading ? 'Criando conta...' : 'Criar conta',
                color: AppColors.accent,
                foreground: AppColors.onAccent,
                onPressed: auth.loading ? null : _submit,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem conta? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('Entrar',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.data, required this.selected, required this.onTap});

  final (String, String, String, Color, Color, IconData) data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = data.$4;
    return FtCard(
      onTap: onTap,
      radius: 14,
      background: selected ? data.$5 : AppColors.card,
      borderColor: selected ? accent : AppColors.border,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? accent : AppColors.cardAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.$6,
              size: 22, color: selected ? AppColors.onPrimary : AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(data.$3,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? accent : AppColors.border, width: 2),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                )
              : null,
        ),
      ]),
    );
  }
}
