import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';

class Transacao extends Equatable {
  final int? id;
  final TipoTransacao tipo;
  final String descricao;

  /// Centavos, sempre positivo.
  final int valor;
  final DateTime data;
  final int idConta;
  final int? idContaDestino;
  final int? idCategoria;
  final String? observacao;

  // Vêm prontos da API (JOIN), só para exibir.
  final String? contaNome;
  final String? contaDestinoNome;
  final String? categoriaNome;
  final Color? categoriaCor;
  final String? categoriaIcone;

  const Transacao({
    this.id,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.idConta,
    this.idContaDestino,
    this.idCategoria,
    this.observacao,
    this.contaNome,
    this.contaDestinoNome,
    this.categoriaNome,
    this.categoriaCor,
    this.categoriaIcone,
  });

  /// Valor com sinal para exibição: receita +, despesa −, transferência sem sinal.
  int get valorComSinal => switch (tipo) {
        TipoTransacao.receita => valor,
        TipoTransacao.despesa => -valor,
        TipoTransacao.transferencia => valor,
      };

  /// Linha de apoio na lista: "Mercado · Nubank" / "Nubank para Carteira".
  String get subtitulo => tipo == TipoTransacao.transferencia
      ? '${contaNome ?? ''} para ${contaDestinoNome ?? ''}'
      : '${categoriaNome ?? 'Sem categoria'} · ${contaNome ?? ''}';

  factory Transacao.fromMap(Map<String, dynamic> m) => Transacao(
        id: m['id'] as int?,
        tipo: TipoTransacao.fromApi(m['tipo'] as String?),
        descricao: m['descricao'] as String? ?? '',
        valor: (m['valor'] as num?)?.toInt() ?? 0,
        data: DateTime.tryParse(m['data'] as String? ?? '') ?? DateTime.now(),
        idConta: (m['id_conta'] as num).toInt(),
        idContaDestino: (m['id_conta_destino'] as num?)?.toInt(),
        idCategoria: (m['id_categoria'] as num?)?.toInt(),
        observacao: m['observacao'] as String?,
        contaNome: m['conta_nome'] as String?,
        contaDestinoNome: m['conta_destino_nome'] as String?,
        categoriaNome: m['categoria_nome'] as String?,
        categoriaCor: m['categoria_cor'] == null
            ? null
            : corDeHex(m['categoria_cor'] as String),
        categoriaIcone: m['categoria_icone'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'tipo': tipo.api,
        'descricao': descricao,
        'valor': valor,
        'data': dataApi(data),
        'id_conta': idConta,
        'id_conta_destino': idContaDestino,
        'id_categoria': idCategoria,
        'observacao': observacao,
      };

  @override
  List<Object?> get props => [
        id,
        tipo,
        descricao,
        valor,
        data,
        idConta,
        idContaDestino,
        idCategoria,
        observacao,
        contaNome,
        contaDestinoNome,
        categoriaNome,
        categoriaCor,
        categoriaIcone,
      ];
}

class FiltroTransacoes extends Equatable {
  /// `null` = todas as datas.
  final MesRef? mes;
  final TipoTransacao? tipo;
  final int? idCategoria;
  final int? idConta;
  final String? busca;

  const FiltroTransacoes({
    this.mes,
    this.tipo,
    this.idCategoria,
    this.idConta,
    this.busca,
  });

  Map<String, dynamic> toQuery({int limit = 50, int offset = 0}) => {
        'mes': mes?.api ?? 'todos',
        if (tipo != null) 'tipo': tipo!.api,
        if (idCategoria != null) 'id_categoria': '$idCategoria',
        if (idConta != null) 'id_conta': '$idConta',
        if (busca != null && busca!.trim().isNotEmpty) 'busca': busca!.trim(),
        'limit': '$limit',
        'offset': '$offset',
      };

  @override
  List<Object?> get props => [mes, tipo, idCategoria, idConta, busca];
}

class PaginaTransacoes extends Equatable {
  final List<Transacao> itens;
  final int total;
  final int receitas;
  final int despesas;

  const PaginaTransacoes({
    required this.itens,
    required this.total,
    required this.receitas,
    required this.despesas,
  });

  factory PaginaTransacoes.fromMap(Map<String, dynamic> m) => PaginaTransacoes(
        itens: (m['itens'] as List)
            .map((e) => Transacao.fromMap(e as Map<String, dynamic>))
            .toList(),
        total: (m['total'] as num).toInt(),
        receitas: (m['receitas'] as num).toInt(),
        despesas: (m['despesas'] as num).toInt(),
      );

  @override
  List<Object?> get props => [itens, total, receitas, despesas];
}
