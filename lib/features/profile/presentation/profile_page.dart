import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/theme/custom_theme_switcher.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/core/widgets/main_layout_controller.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';

/// Aba "Perfil": dados da conta e atalhos de configuração.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final user = context.watch<AuthStore>().usuarioLogado;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final inicial = (user?.nome.isNotEmpty ?? false)
        ? user!.nome.trim()[0].toUpperCase()
        : 'G';

    return GranioBackground(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                const GranioPageHeader(titulo: 'Perfil'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GranioCard(
                        child: Row(
                          children: [
                            Container(
                              height: 58,
                              width: 58,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: GranioColors.brandGradient,
                              ),
                              child: Text(
                                inicial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.nome ?? '',
                                    style: TextStyle(
                                      color: c.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                        color: c.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const GranioSectionTitle('Organização'),
                      _Item(
                        icone: Icons.account_balance_wallet_outlined,
                        titulo: 'Contas',
                        subtitulo: 'Carteira, banco, poupança e saldos',
                        cor: GranioColors.emerald,
                        onTap: () => context.push(RotasFinancas.contas),
                      ),
                      const SizedBox(height: 10),
                      _Item(
                        icone: Icons.category_outlined,
                        titulo: 'Categorias',
                        subtitulo: 'Organize receitas e despesas',
                        cor: GranioColors.gold,
                        onTap: () => context.push(RotasFinancas.categorias),
                      ),
                      const SizedBox(height: 24),
                      const GranioSectionTitle('Preferências'),
                      GranioCard(
                        padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                        child: Row(
                          children: [
                            _IconeItem(
                              icone: escuro
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              cor: GranioColors.teal,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Tema escuro',
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: escuro,
                              activeTrackColor: GranioColors.emerald,
                              inactiveTrackColor: c.border,
                              thumbColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              trackOutlineColor: const WidgetStatePropertyAll(
                                  Colors.transparent),
                              onChanged: (v) => v
                                  ? CustomThemeSwitcher.switchToDarkTheme()
                                  : CustomThemeSwitcher.switchToLightTheme(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Item(
                        icone: Icons.logout_rounded,
                        titulo: 'Sair',
                        cor: GranioColors.expense,
                        onTap: () =>
                            context.read<MainLayoutController>().sair(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconeItem extends StatelessWidget {
  final IconData icone;
  final Color cor;

  const _IconeItem({required this.icone, required this.cor});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icone, color: cor, size: 20),
      );
}

class _Item extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final Color cor;
  final VoidCallback onTap;

  const _Item({
    required this.icone,
    required this.titulo,
    required this.cor,
    required this.onTap,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return GranioCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          _IconeItem(icone: icone, cor: cor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitulo != null)
                  Text(subtitulo!,
                      style: TextStyle(color: c.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}
