import 'package:flutter/material.dart';

/// Ícones das categorias. A API guarda só a chave (ex.: `mercado`); a mesma
/// lista de chaves padrão está no back (`GranioPadroesRepository`).
class GranioIcones {
  GranioIcones._();

  static const categorias = <String, IconData>{
    'casa': Icons.home_outlined,
    'restaurante': Icons.restaurant_outlined,
    'mercado': Icons.shopping_cart_outlined,
    'carro': Icons.directions_car_outlined,
    'combustivel': Icons.local_gas_station_outlined,
    'lazer': Icons.local_activity_outlined,
    'saude': Icons.favorite_border_rounded,
    'educacao': Icons.school_outlined,
    'compras': Icons.shopping_bag_outlined,
    'contas': Icons.receipt_long_outlined,
    'assinatura': Icons.subscriptions_outlined,
    'celular': Icons.smartphone_outlined,
    'cafe': Icons.local_cafe_outlined,
    'viagem': Icons.flight_outlined,
    'academia': Icons.fitness_center_outlined,
    'pet': Icons.pets_outlined,
    'roupa': Icons.checkroom_outlined,
    'beleza': Icons.spa_outlined,
    'bebe': Icons.child_friendly_outlined,
    'presente': Icons.card_giftcard_outlined,
    'imposto': Icons.account_balance_outlined,
    'salario': Icons.account_balance_wallet_outlined,
    'trabalho': Icons.work_outline_rounded,
    'investimento': Icons.trending_up_rounded,
    'banco': Icons.savings_outlined,
    'outros': Icons.category_outlined,
  };

  static IconData categoria(String? chave) =>
      categorias[chave] ?? Icons.category_outlined;

  static IconData conta(String tipo) => switch (tipo) {
        'carteira' => Icons.account_balance_wallet_outlined,
        'corrente' => Icons.account_balance_outlined,
        'poupanca' => Icons.savings_outlined,
        'investimento' => Icons.trending_up_rounded,
        _ => Icons.credit_card_outlined,
      };

  static const transferencia = Icons.swap_horiz_rounded;

  /// Cores sugeridas nos formulários de categoria/conta.
  static const paleta = [
    Color(0xFF10B981),
    Color(0xFF34D399),
    Color(0xFF22D3EE),
    Color(0xFF60A5FA),
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFFF87171),
    Color(0xFFFB923C),
    Color(0xFFF5C451),
    Color(0xFF84CC16),
    Color(0xFF64748B),
  ];
}

/// '#10B981' -> Color. Valor inválido cai na cor da marca.
Color corDeHex(String? hex) {
  final h = (hex ?? '').replaceFirst('#', '');
  final v = int.tryParse(h, radix: 16);
  if (h.length != 6 || v == null) return const Color(0xFF10B981);
  return Color(0xFF000000 | v);
}

/// Color -> '#10B981'.
String hexDeCor(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
