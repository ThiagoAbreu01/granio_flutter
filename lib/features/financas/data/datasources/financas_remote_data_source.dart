import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/helpers/json_decoder.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/dio_rest_client.dart';
import 'package:granio_flutter/core/rest_client/request_handler.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/entities/dashboard.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';

class FinancasRemoteDataSource {
  final DioRestClient _dio;
  final Logger _log;

  const FinancasRemoteDataSource({
    required DioRestClient dio,
    required Logger log,
  })  : _dio = dio,
        _log = log;

  static const _contas = '${Constants.API_PREFIX}/contas';
  static const _categorias = '${Constants.API_PREFIX}/categorias';
  static const _transacoes = '${Constants.API_PREFIX}/transacoes';
  static const _dashboard = '${Constants.API_PREFIX}/dashboard';

  Future<T> _req<T>(String contexto, Future<T> Function() f) =>
      handleRequest(f, log: _log, contexto: contexto);

  String _mensagem(dynamic data) =>
      decodeMap(data)['message'] as String? ?? 'Feito.';

  // ───────────── Contas ─────────────

  Future<List<Conta>> listarContas() =>
      _req('Erro ao carregar as contas.', () async {
        final r = await _dio.auth().get('$_contas/');
        return decodeList(r.data)
            .map((e) => Conta.fromMap(e as Map<String, dynamic>))
            .toList();
      });

  Future<Conta> salvarConta(Conta c) =>
      _req('Erro ao salvar a conta.', () async {
        final r = c.id == null
            ? await _dio.auth().post('$_contas/', data: c.toMap())
            : await _dio.auth().put('$_contas/${c.id}', data: c.toMap());
        return Conta.fromMap(decodeMap(r.data));
      });

  Future<String> removerConta(int id) =>
      _req('Erro ao remover a conta.', () async {
        final r = await _dio.auth().delete('$_contas/$id');
        return _mensagem(r.data);
      });

  // ───────────── Categorias ─────────────

  Future<List<Categoria>> listarCategorias({TipoTransacao? tipo}) =>
      _req('Erro ao carregar as categorias.', () async {
        final r = await _dio.auth().get(
          '$_categorias/',
          queryParameters: {if (tipo != null) 'tipo': tipo.api},
        );
        return decodeList(r.data)
            .map((e) => Categoria.fromMap(e as Map<String, dynamic>))
            .toList();
      });

  Future<Categoria> salvarCategoria(Categoria c) =>
      _req('Erro ao salvar a categoria.', () async {
        final r = c.id == null
            ? await _dio.auth().post('$_categorias/', data: c.toMap())
            : await _dio.auth().put('$_categorias/${c.id}', data: c.toMap());
        return Categoria.fromMap(decodeMap(r.data));
      });

  Future<String> removerCategoria(int id) =>
      _req('Erro ao remover a categoria.', () async {
        final r = await _dio.auth().delete('$_categorias/$id');
        return _mensagem(r.data);
      });

  // ───────────── Transações ─────────────

  Future<PaginaTransacoes> listarTransacoes(
    FiltroTransacoes filtro, {
    int limit = 50,
    int offset = 0,
  }) =>
      _req('Erro ao carregar as transações.', () async {
        final r = await _dio.auth().get(
              '$_transacoes/',
              queryParameters: filtro.toQuery(limit: limit, offset: offset),
            );
        return PaginaTransacoes.fromMap(decodeMap(r.data));
      });

  Future<Transacao> salvarTransacao(Transacao t) =>
      _req('Erro ao salvar a transação.', () async {
        final r = t.id == null
            ? await _dio.auth().post('$_transacoes/', data: t.toMap())
            : await _dio.auth().put('$_transacoes/${t.id}', data: t.toMap());
        return Transacao.fromMap(decodeMap(r.data));
      });

  Future<void> excluirTransacao(int id) =>
      _req('Erro ao excluir a transação.', () async {
        await _dio.auth().delete('$_transacoes/$id');
      });

  // ───────────── Dashboard ─────────────

  Future<Dashboard> dashboard(MesRef mes) =>
      _req('Erro ao carregar o resumo.', () async {
        final r = await _dio
            .auth()
            .get('$_dashboard/', queryParameters: {'mes': mes.api});
        return Dashboard.fromMap(decodeMap(r.data));
      });
}
