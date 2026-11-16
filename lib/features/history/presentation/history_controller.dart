import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

enum HistoryStatus { carregando, pronto, erro }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final FiltroTransacoes filtro;
  final List<Transacao> itens;
  final int total;
  final int receitas;
  final int despesas;
  final bool carregandoMais;
  final String? erro;

  const HistoryState({
    this.status = HistoryStatus.carregando,
    required this.filtro,
    this.itens = const [],
    this.total = 0,
    this.receitas = 0,
    this.despesas = 0,
    this.carregandoMais = false,
    this.erro,
  });

  bool get temMais => itens.length < total;

  HistoryState copyWith({
    HistoryStatus? status,
    FiltroTransacoes? filtro,
    List<Transacao>? itens,
    int? total,
    int? receitas,
    int? despesas,
    bool? carregandoMais,
    String? erro,
  }) =>
      HistoryState(
        status: status ?? this.status,
        filtro: filtro ?? this.filtro,
        itens: itens ?? this.itens,
        total: total ?? this.total,
        receitas: receitas ?? this.receitas,
        despesas: despesas ?? this.despesas,
        carregandoMais: carregandoMais ?? this.carregandoMais,
        erro: erro,
      );

  @override
  List<Object?> get props =>
      [status, filtro, itens, total, receitas, despesas, carregandoMais, erro];
}

class HistoryController extends Cubit<HistoryState> {
  final IFinancasRepository _repository;
  final FinancasSync _sync;
  static const _pagina = 50;

  HistoryController({
    required IFinancasRepository repository,
    required FinancasSync sync,
    TipoTransacao? tipoInicial,
  })  : _repository = repository,
        _sync = sync,
        super(HistoryState(
          filtro: FiltroTransacoes(mes: MesRef.atual(), tipo: tipoInicial),
        )) {
    _sync.addListener(carregar);
  }

  Future<void> carregar() async {
    final filtro = state.filtro;
    if (state.itens.isEmpty) {
      emit(state.copyWith(status: HistoryStatus.carregando));
    }
    try {
      // Recarrega o que já estava na tela (até 200), para não "pular" a lista.
      final limite = state.itens.length.clamp(_pagina, 200);
      final p = await _repository.listarTransacoes(filtro, limit: limite);
      if (isClosed || filtro != state.filtro) return;
      emit(state.copyWith(
        status: HistoryStatus.pronto,
        itens: p.itens,
        total: p.total,
        receitas: p.receitas,
        despesas: p.despesas,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: HistoryStatus.erro,
        erro: mensagemDeErro(e, 'Não foi possível carregar o histórico.'),
      ));
    }
  }

  Future<void> carregarMais() async {
    if (!state.temMais || state.carregandoMais) return;
    final filtro = state.filtro;
    emit(state.copyWith(carregandoMais: true));
    try {
      final p = await _repository.listarTransacoes(filtro,
          limit: _pagina, offset: state.itens.length);
      if (isClosed || filtro != state.filtro) return;
      emit(state.copyWith(
        itens: [...state.itens, ...p.itens],
        total: p.total,
        carregandoMais: false,
      ));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(carregandoMais: false));
    }
  }

  void _filtrar(FiltroTransacoes f) {
    emit(state.copyWith(
      filtro: f,
      itens: const [],
      status: HistoryStatus.carregando,
    ));
    carregar();
  }

  void trocarMes(MesRef mes) => _filtrar(FiltroTransacoes(
        mes: mes,
        tipo: state.filtro.tipo,
        busca: state.filtro.busca,
      ));

  void trocarTipo(TipoTransacao? tipo) => _filtrar(FiltroTransacoes(
        mes: state.filtro.mes,
        tipo: tipo,
        busca: state.filtro.busca,
      ));

  void buscar(String? texto) => _filtrar(FiltroTransacoes(
        mes: state.filtro.mes,
        tipo: state.filtro.tipo,
        busca: (texto?.trim().isEmpty ?? true) ? null : texto!.trim(),
      ));

  /// Remove da tela na hora; se o back recusar, recarrega.
  Future<String?> excluir(Transacao t) async {
    emit(state.copyWith(
      itens: state.itens.where((i) => i.id != t.id).toList(),
      total: state.total - 1,
    ));
    try {
      await _repository.excluirTransacao(t.id!);
      return null;
    } catch (e) {
      await carregar();
      return mensagemDeErro(e, 'Não foi possível excluir.');
    }
  }

  @override
  Future<void> close() {
    _sync.removeListener(carregar);
    return super.close();
  }
}
