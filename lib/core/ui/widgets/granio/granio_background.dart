import 'package:flutter/material.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Fundo da marca: cor sólida com dois brilhos difusos (esmeralda e ciano).
class GranioBackground extends StatelessWidget {
  final Widget child;

  const GranioBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: c.background,
      child: Stack(
        children: [
          _Glow(
            alignment: const Alignment(-1.4, -1.1),
            color: GranioColors.emerald.withValues(alpha: dark ? 0.28 : 0.18),
          ),
          _Glow(
            alignment: const Alignment(1.5, -0.2),
            color: GranioColors.teal.withValues(alpha: dark ? 0.14 : 0.10),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final Color color;

  const _Glow({required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: alignment,
              radius: 1.0,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
