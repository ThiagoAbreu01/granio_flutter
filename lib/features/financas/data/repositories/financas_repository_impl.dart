import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/features/financas/data/datasources/financas_remote_data_source.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/entities/dashboard.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';

/// Delega ao datasource e, a cada escrita que deu certo, avisa o [FinancasSync].
class FinancasRepositoryImpl implements IFinancasRepository {
  final FinancasRemoteDataSource _remote;
  final FinancasSync _sync;

  const FinancasRepositoryImpl({
    required FinancasRemoteDataSource remote,
    required FinancasSync sync,
  })  : _remote = remote,
        _sync = sync;

  Future<T> _escrita<T>(Future<T> Function() f) async {
    final r = await f();
    _sync.avisarMudanca();
    return r;
  }

  @override
  Future<List<Conta>> listarContas() => _remote.listarContas();

  @override
  Future<Conta> salvarConta(Conta conta) =>
      _escrita(() => _remote.salvarConta(conta));

  @override
  Future<String> removerConta(int id) =>
      _escrita(() => _remote.removerConta(id));

  @override
  Future<List<Categoria>> listarCategorias({TipoTransacao? tipo}) =>
      _remote.listarCategorias(tipo: tipo);

  @override
  Future<Categoria> salvarCategoria(Categoria categoria) =>
      _escrita(() => _remote.salvarCategoria(categoria));

  @override
  Future<String> removerCategoria(int id) =>
      _escrita(() => _remote.removerCategoria(id));

  @override
  Future<PaginaTransacoes> listarTransacoes(
    FiltroTransacoes filtro, {
    int limit = 50,
    int offset = 0,
  }) =>
      _remote.listarTransacoes(filtro, limit: limit, offset: offset);

  @override
  Future<Transacao> salvarTransacao(Transacao transacao) =>
      _escrita(() => _remote.salvarTransacao(transacao));

  @override
  Future<void> excluirTransacao(int id) =>
      _escrita(() => _remote.excluirTransacao(id));

  @override
  Future<Dashboard> dashboard(MesRef mes) => _remote.dashboard(mes);
}
