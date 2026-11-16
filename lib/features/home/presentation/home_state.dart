import 'package:equatable/equatable.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/features/financas/domain/entities/dashboard.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';

enum HomeStatus { carregando, pronto, erro }

class HomeState extends Equatable {
  final HomeStatus status;
  final User? contaConectada;
  final MesRef mes;
  final Dashboard? dashboard;
  final bool valoresOcultos;
  final String? erro;

  const HomeState({
    this.status = HomeStatus.carregando,
    this.contaConectada,
    required this.mes,
    this.dashboard,
    this.valoresOcultos = false,
    this.erro,
  });

  HomeState copyWith({
    HomeStatus? status,
    MesRef? mes,
    Dashboard? dashboard,
    bool? valoresOcultos,
    String? erro,
  }) =>
      HomeState(
        status: status ?? this.status,
        contaConectada: contaConectada,
        mes: mes ?? this.mes,
        dashboard: dashboard ?? this.dashboard,
        valoresOcultos: valoresOcultos ?? this.valoresOcultos,
        erro: erro,
      );

  @override
  List<Object?> get props =>
      [status, contaConectada, mes, dashboard, valoresOcultos, erro];
}
