import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';

class Categoria extends Equatable {
  final int? id;
  final String nome;

  /// Só [TipoTransacao.receita] ou [TipoTransacao.despesa].
  final TipoTransacao tipo;
  final Color cor;
  final String icone;
  final bool arquivada;

  const Categoria({
    this.id,
    required this.nome,
    required this.tipo,
    required this.cor,
    required this.icone,
    this.arquivada = false,
  });

  factory Categoria.fromMap(Map<String, dynamic> m) => Categoria(
        id: m['id'] as int?,
        nome: m['nome'] as String? ?? '',
        tipo: TipoTransacao.fromApi(m['tipo'] as String?),
        cor: corDeHex(m['cor'] as String?),
        icone: m['icone'] as String? ?? 'outros',
        arquivada: m['arquivada'] == true,
      );

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'tipo': tipo.api,
        'cor': hexDeCor(cor),
        'icone': icone,
      };

  @override
  List<Object?> get props => [id, nome, tipo, cor, icone, arquivada];
}
