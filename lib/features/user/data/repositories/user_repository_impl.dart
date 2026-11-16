import 'package:granio_flutter/features/user/data/datasources/user_remote_data_source.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';
import 'package:granio_flutter/features/user/domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _dataSource;

  const UserRepositoryImpl({required UserRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<User> getContaConectada() => _dataSource.getContaConectada();

  @override
  Future<String> deleteAccount(User contaConectada) =>
      _dataSource.deleteAccount(contaConectada);
}
