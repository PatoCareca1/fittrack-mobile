import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_email.text.trim(), _password.text);
    if (ok && mounted) context.go('/inicio');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: FtLogo(size: 60, radius: 18)),
              const SizedBox(height: 14),
              const Text('Bem-vindo de volta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              const SizedBox(height: 6),
              const Text('Entre para continuar sua evolução',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              const Text('E-mail',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Senha',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
                obscureText: _obscure,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: '••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18, color: AppColors.textMuted),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/recuperar'),
                  child: const Text('Esqueci minha senha',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 4),
                Text(auth.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              PillButton(
                label: auth.loading ? 'Entrando...' : 'Entrar',
                onPressed: auth.loading ? null : _submit,
              ),
              const SizedBox(height: 24),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('ou', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 24),
              PillButton(
                label: 'Continuar com Google',
                outlined: true,
                height: 50,
                icon: Icons.g_mobiledata,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login com Google ainda não disponível')),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem conta? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.push('/cadastro'),
                    child: const Text('Criar conta',
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
