import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class RecoverScreen extends StatelessWidget {
  const RecoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
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
                child: const Icon(Icons.lock_outline, size: 30, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text('Recuperar senha',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              const SizedBox(height: 10),
              const Text(
                'Informe seu e-mail e enviaremos um link para você redefinir sua senha.',
                style: TextStyle(fontSize: 14, height: 1.55, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              const Text('E-mail',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 28),
              PillButton(
                label: 'Enviar link',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Se o e-mail existir, você receberá o link em instantes.')),
                  );
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
