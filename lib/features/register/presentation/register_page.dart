import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/widgets/global_components/custom_snackbar.dart';
import 'package:granio_flutter/core/ui/widgets/global_components/loader.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/features/register/presentation/register_controller.dart';
import 'package:granio_flutter/features/register/presentation/register_state.dart';
import 'package:granio_flutter/features/register/presentation/widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with Loader {
  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return BlocListener<RegisterController, RegisterState>(
      listener: _onStateChanged,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: GranioBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: const RegisterForm(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: IconButton.filled(
                      tooltip: 'Voltar',
                      style: IconButton.styleFrom(
                        backgroundColor: c.surface,
                        side: BorderSide(color: c.border),
                      ),
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_rounded, color: c.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    switch (state.status) {
      case RegisterStatus.loading:
        showLoader(message: 'Criando a sua conta...');
      case RegisterStatus.success:
        hideLoader();
        CustomSnackbar.showMessage(
          context: context,
          text: 'Conta criada com sucesso! Faça login para continuar.',
          customDuration: const Duration(seconds: 3),
        );
        context.pop();
      case RegisterStatus.error:
        hideLoader();
        CustomSnackbar.showMessage(
          context: context,
          text: state.errorMessage ?? 'Falha ao criar conta.',
          customDuration: const Duration(seconds: 3),
        );
      case RegisterStatus.initial:
        break;
    }
  }
}
