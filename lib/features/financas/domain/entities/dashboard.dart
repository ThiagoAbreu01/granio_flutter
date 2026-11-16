import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';

class TotalCategoria extends Equatable {
  final int idCategoria;
  final String nome;
  final Color cor;
  final String icone;
  final int total;

  const TotalCategoria({
    required this.idCategoria,
    required this.nome,
    required this.cor,
    required this.icone,
    required this.total,
  });

  factory TotalCategoria.fromMap(Map<String, dynamic> m) => TotalCategoria(
        idCategoria: (m['id_categoria'] as num).toInt(),
        nome: m['nome'] as String,
        cor: corDeHex(m['cor'] as String?),
        icone: m['icone'] as String? ?? 'outros',
        total: (m['total'] as num).toInt(),
      );

  @override
  List<Object?> get props => [idCategoria, nome, cor, icone, total];
}

class TotalMes extends Equatable {
  final MesRef mes;
  final int receitas;
  final int despesas;

  const TotalMes(this.mes, this.receitas, this.despesas);

  factory TotalMes.fromMap(Map<String, dynamic> m) => TotalMes(
        MesRef.parse(m['mes'] as String),
        (m['receitas'] as num).toInt(),
        (m['despesas'] as num).toInt(),
      );

  @override
  List<Object?> get props => [mes, receitas, despesas];
}

class Dashboard extends Equatable {
  final MesRef mes;
  final int saldoTotal;
  final int saldoFimMes;
  final int saldoFimMesAnterior;
  final int receitasMes;
  final int despesasMes;
  final List<TotalCategoria> despesasPorCategoria;
  final List<TotalCategoria> receitasPorCategoria;
  final List<TotalMes> evolucao;
  final List<Transacao> ultimasTransacoes;

  const Dashboard({
    required this.mes,
    required this.saldoTotal,
    required this.saldoFimMes,
    required this.saldoFimMesAnterior,
    required this.receitasMes,
    required this.despesasMes,
    required this.despesasPorCategoria,
    required this.receitasPorCategoria,
    required this.evolucao,
    required this.ultimasTransacoes,
  });

  int get resultadoMes => receitasMes - despesasMes;

  factory Dashboard.fromMap(Map<String, dynamic> m) {
    List<T> lista<T>(String k, T Function(Map<String, dynamic>) f) =>
        (m[k] as List? ?? const [])
            .map((e) => f(e as Map<String, dynamic>))
            .toList();
    return Dashboard(
      mes: MesRef.parse(m['mes'] as String),
      saldoTotal: (m['saldo_total'] as num).toInt(),
      saldoFimMes: (m['saldo_fim_mes'] as num).toInt(),
      saldoFimMesAnterior: (m['saldo_fim_mes_anterior'] as num).toInt(),
      receitasMes: (m['receitas_mes'] as num).toInt(),
      despesasMes: (m['despesas_mes'] as num).toInt(),
      despesasPorCategoria:
          lista('despesas_por_categoria', TotalCategoria.fromMap),
      receitasPorCategoria:
          lista('receitas_por_categoria', TotalCategoria.fromMap),
      evolucao: lista('evolucao', TotalMes.fromMap),
      ultimasTransacoes: lista('ultimas_transacoes', Transacao.fromMap),
    );
  }

  @override
  List<Object?> get props => [
        mes,
        saldoTotal,
        saldoFimMes,
        saldoFimMesAnterior,
        receitasMes,
        despesasMes,
        despesasPorCategoria,
        receitasPorCategoria,
        evolucao,
        ultimasTransacoes,
      ];
}
