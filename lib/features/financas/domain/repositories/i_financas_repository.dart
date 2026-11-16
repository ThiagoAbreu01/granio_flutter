import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/entities/dashboard.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';

/// Contas, categorias, transações e dashboard do módulo `/granio` do back.
///
/// Toda escrita bem-sucedida avisa o `FinancasSync`, e as telas que mostram
/// dados (home, histórico, contas) recarregam sozinhas.
abstract class IFinancasRepository {
  // Contas
  Future<List<Conta>> listarContas();
  Future<Conta> salvarConta(Conta conta);

  /// Devolve a mensagem do back (excluída ou arquivada).
  Future<String> removerConta(int id);

  // Categorias
  Future<List<Categoria>> listarCategorias({TipoTransacao? tipo});
  Future<Categoria> salvarCategoria(Categoria categoria);
  Future<String> removerCategoria(int id);

  // Transações
  Future<PaginaTransacoes> listarTransacoes(
    FiltroTransacoes filtro, {
    int limit = 50,
    int offset = 0,
  });
  Future<Transacao> salvarTransacao(Transacao transacao);
  Future<void> excluirTransacao(int id);

  // Dashboard
  Future<Dashboard> dashboard(MesRef mes);
}
