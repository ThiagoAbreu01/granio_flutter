import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/helpers/custom_telefone_input_formatter.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_button.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_logo.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_text_field.dart';
import 'package:granio_flutter/features/register/presentation/register_controller.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();

  static final _semEspacos = [FilteringTextInputFormatter.deny(RegExp(r'\s'))];

  @override
  void dispose() {
    for (final c in [_nome, _email, _telefone, _senha, _confirmarSenha]) {
      c.dispose();
    }
    super.dispose();
  }

  void _cadastrar() {
    FocusScope.of(context).unfocus();
    context.read<RegisterController>().cadastrar(
          nome: _nome.text,
          email: _email.text,
          telefone: _telefone.text,
          senha: _senha.text,
          confirmarSenha: _confirmarSenha.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    const espaco = SizedBox(height: 16);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: GranioHeroImage(
              asset: 'assets/images/register_hero.png',
              lightAsset: 'assets/images/login_hero_light.png',
              size: 140,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Crie sua conta',
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
            'Leva menos de um minuto. Seu primeiro grão começa aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textMuted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
          GranioTextField(
            label: 'Nome completo',
            hint: 'Como podemos te chamar?',
            icon: Icons.person_outline_rounded,
            controller: _nome,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
          ),
          espaco,
          GranioTextField(
            label: 'E-mail',
            hint: 'voce@email.com',
            icon: Icons.alternate_email_rounded,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: _semEspacos,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          espaco,
          GranioTextField(
            label: 'Telefone (opcional)',
            hint: '(00) 00000-0000',
            icon: Icons.phone_iphone_rounded,
            controller: _telefone,
            keyboardType: TextInputType.phone,
            inputFormatters: [CustomTelefoneInputFormatter()],
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
          ),
          espaco,
          GranioTextField(
            label: 'Senha',
            hint: 'Mínimo de 8 caracteres',
            icon: Icons.lock_outline_rounded,
            controller: _senha,
            obscure: true,
            inputFormatters: _semEspacos,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: _senha,
            builder: (context, _) => _ForcaSenha(senha: _senha.text),
          ),
          espaco,
          GranioTextField(
            label: 'Confirmar senha',
            hint: 'Repita a senha',
            icon: Icons.lock_outline_rounded,
            controller: _confirmarSenha,
            obscure: true,
            inputFormatters: _semEspacos,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _cadastrar(),
          ),
          const SizedBox(height: 28),
          GranioButton(label: 'Criar conta', onPressed: _cadastrar),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: c.textMuted,
              ),
              onPressed: () => context.pop(),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: c.textMuted, fontSize: 14),
                  children: const [
                    TextSpan(text: 'Já tem conta? '),
                    TextSpan(
                      text: 'Entrar',
                      style: TextStyle(
                        color: GranioColors.emerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador visual simples; a regra de verdade é do back.
class _ForcaSenha extends StatelessWidget {
  final String senha;

  const _ForcaSenha({required this.senha});

  int get _nivel {
    if (senha.isEmpty) return 0;
    var pontos = 0;
    if (senha.length >= 8) pontos++;
    if (RegExp(r'[A-Z]').hasMatch(senha) && RegExp(r'[a-z]').hasMatch(senha)) {
      pontos++;
    }
    if (RegExp(r'\d').hasMatch(senha)) pontos++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(senha)) pontos++;
    return pontos.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final nivel = _nivel;
    const cores = [
      GranioColors.expense,
      GranioColors.gold,
      GranioColors.teal,
      GranioColors.emerald,
    ];
    const rotulos = ['Fraca', 'Razoável', 'Boa', 'Forte'];

    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i < nivel ? cores[nivel - 1] : c.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        SizedBox(
          width: 64,
          child: Text(
            nivel == 0 ? '' : rotulos[nivel - 1],
            textAlign: TextAlign.right,
            style: TextStyle(
              color: nivel == 0 ? c.textMuted : cores[nivel - 1],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
