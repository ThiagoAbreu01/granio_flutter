import 'package:flutter/material.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

enum TipoTransacao {
  receita('Receita', 'Receitas', GranioColors.income, Icons.south_west_rounded),
  despesa(
      'Despesa', 'Despesas', GranioColors.expense, Icons.north_east_rounded),
  transferencia('Transferência', 'Transferências', GranioColors.teal,
      Icons.swap_horiz_rounded);

  final String rotulo;
  final String plural;
  final Color cor;
  final IconData icone;

  const TipoTransacao(this.rotulo, this.plural, this.cor, this.icone);

  String get api => name;

  static TipoTransacao fromApi(String? v) =>
      values.firstWhere((t) => t.name == v, orElse: () => despesa);
}
