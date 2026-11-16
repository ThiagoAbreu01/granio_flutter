import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/widgets/nav_item.dart';

/// Barra inferior flutuante: o item ativo expande e mostra o rótulo.
class GranioNavBar extends StatelessWidget {
  final List<NavItem> itens;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GranioNavBar({
    super.key,
    required this.itens,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Center(
        heightFactor: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.10),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < itens.length; i++)
                _Item(
                  item: itens[i],
                  ativo: i == currentIndex,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    onTap(i);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final NavItem item;
  final bool ativo;
  final VoidCallback onTap;

  const _Item({required this.item, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Semantics(
      selected: ativo,
      button: true,
      label: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: ativo ? 18 : 22),
          decoration: BoxDecoration(
            color: ativo
                ? GranioColors.emerald.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                item.icon,
                size: 18,
                color: ativo ? GranioColors.emerald : c.textMuted,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: ativo
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: GranioColors.emerald,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
