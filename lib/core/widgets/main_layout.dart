import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_nav_bar.dart';
import 'package:granio_flutter/core/widgets/main_layout_controller.dart';
import 'package:granio_flutter/core/widgets/nav_item.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';

/// Casca da área logada: app bar + bottom nav. Para adicionar um item de
/// menu, inclua em [_navItems] e a `GoRoute` correspondente no app_router.
class MainLayout extends StatelessWidget {
  final String currentLocation;
  final Widget child;

  const MainLayout({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  static const _navItems = [
    NavItem('Home', '/home', FontAwesomeIcons.house),
    NavItem('Histórico', '/history', FontAwesomeIcons.clockRotateLeft),
    NavItem('Perfil', '/profile', FontAwesomeIcons.user),
  ];

  int get _currentIndex {
    final i = _navItems.indexWhere((n) => currentLocation.startsWith(n.route));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => MainLayoutController(
        authRepository: c.read<IAuthRepository>(),
        authStore: c.read<AuthStore>(),
      ),
      child: Builder(
        builder: (context) {
          final c = GranioColors.of(context);
          // Sem AppBar: cada aba desenha o próprio cabeçalho.
          return Scaffold(
            extendBody: true,
            backgroundColor: c.background,
            bottomNavigationBar: GranioNavBar(
              itens: _navItems,
              currentIndex: _currentIndex,
              onTap: (index) => context.go(_navItems[index].route),
            ),
            body: child,
          );
        },
      ),
    );
  }
}
