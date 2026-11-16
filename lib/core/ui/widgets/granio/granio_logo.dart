import 'package:flutter/material.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Marca: selo com broto (o "grão" que cresce) + nome Granio.
class GranioLogo extends StatelessWidget {
  final double size;

  const GranioLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            gradient: GranioColors.brandGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child:
              Icon(Icons.spa_rounded, color: Colors.white, size: size * 0.58),
        ),
        SizedBox(width: size * 0.3),
        Text(
          'Granio',
          style: TextStyle(
            color: c.text,
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Ilustração em um círculo com brilho. [lightAsset] é a versão de fundo
/// claro, usada no tema claro (se não houver, usa [asset]).
class GranioHeroImage extends StatelessWidget {
  final String asset;
  final String? lightAsset;
  final double size;

  const GranioHeroImage({
    super.key,
    required this.asset,
    this.lightAsset,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final imagem = dark ? asset : (lightAsset ?? asset);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: GranioColors.emerald.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GranioColors.emerald.withValues(alpha: dark ? 0.30 : 0.16),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagem,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFF0B0F14),
            child: Icon(Icons.savings_rounded,
                color: GranioColors.emerald, size: 72),
          ),
        ),
      ),
    );
  }
}
