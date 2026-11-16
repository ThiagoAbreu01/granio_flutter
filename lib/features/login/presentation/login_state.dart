import 'package:equatable/equatable.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';

import 'package:granio_flutter/features/login/presentation/login_status.dart';

export 'package:granio_flutter/features/login/presentation/login_status.dart';

class LoginState extends Equatable {
  final LoginStatus status;
  final User? contaConectada;
  final bool biometriaDisponivel;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.contaConectada,
    this.biometriaDisponivel = false,
    this.errorMessage,
  });

  /// `errorMessage` é transitório: não usa `?? this.errorMessage`, então é
  /// limpo a cada `emit`.
  LoginState copyWith({
    LoginStatus? status,
    User? contaConectada,
    bool? biometriaDisponivel,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      contaConectada: contaConectada ?? this.contaConectada,
      biometriaDisponivel: biometriaDisponivel ?? this.biometriaDisponivel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, contaConectada, biometriaDisponivel, errorMessage];
}
