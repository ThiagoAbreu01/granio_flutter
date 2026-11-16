import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/ui/widgets/global_components/custom_snackbar.dart';
import 'package:granio_flutter/core/ui/widgets/global_components/loader.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/features/login/presentation/login_controller.dart';
import 'package:granio_flutter/features/login/presentation/login_state.dart';
import 'package:granio_flutter/features/login/presentation/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with Loader {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginController, LoginState>(
      listenWhen: (anterior, atual) =>
          anterior.status != atual.status ||
          anterior.errorMessage != atual.errorMessage,
      listener: _onStateChanged,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: GranioBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    switch (state.status) {
      case LoginStatus.loading:
        showLoader(message: 'Autenticando');
      case LoginStatus.success:
        hideLoader();
        context.go('/home');
      case LoginStatus.error:
        hideLoader();
        CustomSnackbar.showMessage(
          context: context,
          text: state.errorMessage ?? 'Falha ao realizar login.',
          customDuration: const Duration(seconds: 4),
        );
      case LoginStatus.initial:
        hideLoader();
    }
  }
}
