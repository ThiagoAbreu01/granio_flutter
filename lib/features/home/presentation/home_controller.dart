import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/home/presentation/home_state.dart';

class HomeController extends Cubit<HomeState> {
  final IFinancasRepository _repository;
  final FinancasSync _sync;

  HomeController({
    required AuthStore authStore,
    required IFinancasRepository repository,
    required FinancasSync sync,
  })  : _repository = repository,
        _sync = sync,
        super(HomeState(
          contaConectada: authStore.usuarioLogado,
          mes: MesRef.atual(),
        )) {
    _sync.addListener(carregar);
  }

  /// Mantém o dashboard anterior na tela enquanto recarrega.
  Future<void> carregar() async {
    if (state.dashboard == null) {
      emit(state.copyWith(status: HomeStatus.carregando));
    }
    final mes = state.mes;
    try {
      final dashboard = await _repository.dashboard(mes);
      // O usuário pode ter trocado de mês enquanto carregava.
      if (isClosed || mes != state.mes) return;
      emit(state.copyWith(status: HomeStatus.pronto, dashboard: dashboard));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: HomeStatus.erro,
        erro: e is Failure ? e.message : 'Não foi possível carregar o resumo.',
      ));
    }
  }

  void trocarMes(MesRef mes) {
    if (mes == state.mes) return;
    emit(state.copyWith(mes: mes));
    carregar();
  }

  void alternarValores() =>
      emit(state.copyWith(valoresOcultos: !state.valoresOcultos));

  @override
  Future<void> close() {
    _sync.removeListener(carregar);
    return super.close();
  }
}
