import 'package:granio_flutter/features/user/domain/entities/user.dart';

abstract class IUserRepository {
  Future<User> getContaConectada();
  Future<String> deleteAccount(User contaConectada);
}
