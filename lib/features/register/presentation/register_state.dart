import 'package:equatable/equatable.dart';

import 'package:granio_flutter/features/register/presentation/register_status.dart';

export 'package:granio_flutter/features/register/presentation/register_status.dart';

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState(
      {this.status = RegisterStatus.initial, this.errorMessage});

  RegisterState copyWith({RegisterStatus? status, String? errorMessage}) =>
      RegisterState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, errorMessage];
}
