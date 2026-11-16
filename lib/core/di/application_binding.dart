import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/i_secure_local_storage.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/secure_local_storage.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/dio_rest_client.dart';

// Datasources
import 'package:granio_flutter/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:granio_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:granio_flutter/features/auth/data/datasources/biometric_data_source.dart';
import 'package:granio_flutter/features/user/data/datasources/user_remote_data_source.dart';
import 'package:granio_flutter/features/financas/data/datasources/financas_remote_data_source.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';

// Repository interfaces
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/user/domain/repositories/i_user_repository.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';

// Repository implementations
import 'package:granio_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:granio_flutter/features/user/data/repositories/user_repository_impl.dart';
import 'package:granio_flutter/features/financas/data/repositories/financas_repository_impl.dart';

/// Injeção de dependências global do app.
///
/// Camadas (de baixo p/ cima): infra → datasources → repositories (interface).
/// Os Cubits/Controllers são providos por cada `*_router.dart` via BlocProvider,
/// resolvendo aqui as interfaces de repositório de que precisam.
class ApplicationBinding extends StatelessWidget {
  final Widget child;

  const ApplicationBinding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ───────────── Infra ─────────────
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ChangeNotifierProvider(create: (_) => FinancasSync()),
        Provider(create: (_) => Logger()),
        Provider<ISecureLocalStorage>(create: (_) => SecureLocalStorage()),
        Provider(
          create: (c) => DioRestClient(
            log: c.read(),
            secureLocalStorage: c.read(),
            authStore: c.read(),
          ),
        ),

        // ───────────── Datasources ─────────────
        Provider(
            create: (c) => AuthRemoteDataSource(dio: c.read(), log: c.read())),
        Provider(create: (c) => AuthLocalDataSource(storage: c.read())),
        Provider(create: (_) => BiometricDataSource()),
        Provider(
            create: (c) => UserRemoteDataSource(dio: c.read(), log: c.read())),
        Provider(
            create: (c) =>
                FinancasRemoteDataSource(dio: c.read(), log: c.read())),

        // ───────────── Repositories (interface → impl) ─────────────
        Provider<IAuthRepository>(
          create: (c) => AuthRepositoryImpl(
            remote: c.read(),
            local: c.read(),
            biometric: c.read(),
          ),
        ),
        Provider<IUserRepository>(
            create: (c) => UserRepositoryImpl(dataSource: c.read())),
        Provider<IFinancasRepository>(
          create: (c) =>
              FinancasRepositoryImpl(remote: c.read(), sync: c.read()),
        ),
      ],
      child: child,
    );
  }
}
