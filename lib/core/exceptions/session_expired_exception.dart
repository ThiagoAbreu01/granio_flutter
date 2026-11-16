import 'package:granio_flutter/core/exceptions/failure.dart';

/// Token ausente ou recusado pelo servidor e não foi possível renovar.
class SessionExpiredException extends Failure {
  SessionExpiredException({
    super.message = 'Sua sessão expirou. Faça login novamente.',
  });
}
