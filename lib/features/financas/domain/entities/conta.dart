import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';

class Conta extends Equatable {
  static const tipos = <String, String>{
    'carteira': 'Carteira',
    'corrente': 'Conta corrente',
    'poupanca': 'Poupança',
    'investimento': 'Investimento',
    'outro': 'Outro',
  };

  final int? id;
  final String nome;
  final String tipo;

  /// Centavos.
  final int saldoInicial;
  final int saldoAtual;
  final Color cor;
  final bool arquivada;

  const Conta({
    this.id,
    required this.nome,
    required this.tipo,
    this.saldoInicial = 0,
    this.saldoAtual = 0,
    required this.cor,
    this.arquivada = false,
  });

  String get tipoRotulo => tipos[tipo] ?? tipo;

  factory Conta.fromMap(Map<String, dynamic> m) => Conta(
        id: m['id'] as int?,
        nome: m['nome'] as String? ?? '',
        tipo: m['tipo'] as String? ?? 'outro',
        saldoInicial: (m['saldo_inicial'] as num?)?.toInt() ?? 0,
        saldoAtual: (m['saldo_atual'] as num?)?.toInt() ?? 0,
        cor: corDeHex(m['cor'] as String?),
        arquivada: m['arquivada'] == true,
      );

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'tipo': tipo,
        'saldo_inicial': saldoInicial,
        'cor': hexDeCor(cor),
      };

  @override
  List<Object?> get props =>
      [id, nome, tipo, saldoInicial, saldoAtual, cor, arquivada];
}
