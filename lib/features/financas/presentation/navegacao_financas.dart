import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';

/// Rotas das telas financeiras fora da casca (sem bottom nav).
class RotasFinancas {
  RotasFinancas._();

  static const transacao = '/transacao';
  static const categorias = '/categorias';
  static const contas = '/contas';
}

/// Argumentos da tela de lançamento: [transacao] = edição.
class TransacaoFormArgs {
  final TipoTransacao tipo;
  final Transacao? transacao;

  const TransacaoFormArgs({this.tipo = TipoTransacao.despesa, this.transacao});
}

void abrirNovaTransacao(BuildContext context, TipoTransacao tipo) =>
    context.push(RotasFinancas.transacao, extra: TransacaoFormArgs(tipo: tipo));

void abrirTransacao(BuildContext context, Transacao t) => context.push(
      RotasFinancas.transacao,
      extra: TransacaoFormArgs(tipo: t.tipo, transacao: t),
    );
