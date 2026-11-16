import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/widgets/main_layout.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/presentation/categorias/categorias_page.dart';
import 'package:granio_flutter/features/financas/presentation/contas/contas_page.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';
import 'package:granio_flutter/features/financas/presentation/transacao/transacao_form_page.dart';
import 'package:granio_flutter/features/history/presentation/history_page.dart';
import 'package:granio_flutter/features/profile/presentation/profile_page.dart';
import 'package:granio_flutter/features/home/presentation/home_router.dart';
import 'package:granio_flutter/features/login/presentation/login_router.dart';
import 'package:granio_flutter/features/register/presentation/register_router.dart';

const _rotasPublicas = {'/login', '/register'};

/// Criado uma vez no app. O [AuthStore] é o `refreshListenable`: quando o
/// usuário entra, sai ou a sessão expira, o redirect roda de novo.
GoRouter buildAppRouter(AuthStore authStore) => GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: false,
      refreshListenable: authStore,
      redirect: (context, state) {
        final logado = authStore.isLogado;
        final publica = _rotasPublicas.contains(state.matchedLocation);

        if (!logado && !publica) return '/login';
        if (logado && publica) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginRouter().page,
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterRouter().page,
        ),
        // Telas cheias (sem bottom nav), abertas com push por cima da casca.
        GoRoute(
          path: RotasFinancas.transacao,
          builder: (context, state) => TransacaoFormPage(
            args: state.extra is TransacaoFormArgs
                ? state.extra as TransacaoFormArgs
                : const TransacaoFormArgs(),
          ),
        ),
        GoRoute(
          path: RotasFinancas.categorias,
          builder: (context, state) => const CategoriasPage(),
        ),
        GoRoute(
          path: RotasFinancas.contas,
          builder: (context, state) => const ContasPage(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              MainLayout(currentLocation: state.matchedLocation, child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeRouter().page,
            ),
            GoRoute(
              path: '/history',
              name: 'history',
              // `?tipo=receita` abre já filtrado (cards da home).
              builder: (context, state) => const HistoryRouter().page(
                tipo: switch (state.uri.queryParameters['tipo']) {
                  final String t =>
                    TipoTransacao.values.where((e) => e.api == t).firstOrNull,
                  _ => null,
                },
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(
        body: Center(child: Text('Página não encontrada.')),
      ),
    );
