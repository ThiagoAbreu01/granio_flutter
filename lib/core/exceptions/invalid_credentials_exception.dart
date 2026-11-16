import 'package:granio_flutter/core/exceptions/failure.dart';

/// E-mail/senha inválidos (HTTP 401 no login).
class InvalidCredentialsException extends Failure {
  InvalidCredentialsException({super.message});
}
