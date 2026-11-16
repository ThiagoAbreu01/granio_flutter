import 'package:flutter/material.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Botão principal (gradiente da marca) ou secundário (contorno).
class GranioButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  const GranioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : outlined = false;

  const GranioButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : outlined = true;

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final corTexto = outlined ? c.text : Colors.white;
    final radius = BorderRadius.circular(16);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: outlined ? null : GranioColors.brandGradient,
        color: outlined ? c.surface : null,
        border: outlined ? Border.all(color: c.border) : null,
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: GranioColors.emerald.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: corTexto, size: 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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
