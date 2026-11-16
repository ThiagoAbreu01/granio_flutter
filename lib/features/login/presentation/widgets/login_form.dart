import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_button.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_logo.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_text_field.dart';
import 'package:granio_flutter/features/login/presentation/login_controller.dart';
import 'package:granio_flutter/features/login/presentation/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  late final _cadastroRecognizer = TapGestureRecognizer()
    ..onTap = () => context.push('/register');
  bool _salvarBiometria = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _cadastroRecognizer.dispose();
    super.dispose();
  }

  void _entrar() {
    FocusScope.of(context).unfocus();
    context.read<LoginController>().realizarLogin(
          email: _email.text,
          senha: _senha.text,
          salvarBiometria: _salvarBiometria,
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: GranioLogo(size: 34)),
          const SizedBox(height: 28),
          const Center(
            child: GranioHeroImage(
              asset: 'assets/images/login_hero.png',
              lightAsset: 'assets/images/login_hero_light.png',
              size: 180,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo de volta',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acompanhe seus gastos e veja seu dinheiro crescer, grão a grão.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textMuted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),
          GranioTextField(
            label: 'E-mail',
            hint: 'voce@email.com',
            icon: Icons.alternate_email_rounded,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 18),
          GranioTextField(
            label: 'Senha',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            controller: _senha,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _entrar(),
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 12),
          _BiometriaSwitch(
            value: _salvarBiometria,
            onChanged: (v) => setState(() => _salvarBiometria = v),
          ),
          const SizedBox(height: 24),
          GranioButton(label: 'Entrar', onPressed: _entrar),
          BlocSelector<LoginController, LoginState, bool>(
            selector: (state) => state.biometriaDisponivel,
            builder: (context, disponivel) {
              if (!disponivel) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: GranioButton.outlined(
                  label: 'Entrar com biometria',
                  icon: Icons.fingerprint_rounded,
                  onPressed: () =>
                      context.read<LoginController>().entrarComBiometria(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: c.textMuted, fontSize: 14),
                children: [
                  const TextSpan(text: 'Ainda não tem conta? '),
                  TextSpan(
                    text: 'Criar conta',
                    recognizer: _cadastroRecognizer,
                    style: const TextStyle(
                      color: GranioColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometriaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BiometriaSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.fingerprint_rounded, size: 20, color: c.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Usar biometria nas próximas vezes',
                style: TextStyle(color: c.textMuted, fontSize: 13),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: GranioColors.emerald,
              inactiveTrackColor: c.border,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
