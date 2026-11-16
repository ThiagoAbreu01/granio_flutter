import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/categorias/categoria_sheet.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  late final IFinancasRepository _repo = context.read();
  late final FinancasSync _sync = context.read();
  TipoTransacao _tipo = TipoTransacao.despesa;
  List<Categoria>? _categorias;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _sync.addListener(_carregar);
    _carregar();
  }

  @override
  void dispose() {
    _sync.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final lista = await _repo.listarCategorias();
      if (mounted) {
        setState(() {
          _categorias = lista;
          _erro = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(e));
    }
  }

  Future<void> _remover(Categoria cat) async {
    final ok = await confirmar(
      context,
      titulo: 'Remover "${cat.nome}"?',
      mensagem: 'Se já houver lançamentos nela, a categoria é arquivada: '
          'some das opções, mas o histórico continua igual.',
      acao: 'Remover',
    );
    if (!ok || !mounted) return;
    try {
      final msg = await _repo.removerCategoria(cat.id!);
      if (mounted) avisar(context, msg);
    } catch (e) {
      if (mounted) avisar(context, mensagemDeErro(e), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final lista =
        _categorias?.where((cat) => cat.tipo == _tipo).toList() ?? const [];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GranioColors.emerald,
        foregroundColor: Colors.white,
        onPressed: () => mostrarCategoriaSheet(context, tipo: _tipo),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova categoria',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: GranioBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  const GranioPageHeader(titulo: 'Categorias', voltar: true),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TipoTransacao>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor:
                              _tipo.cor.withValues(alpha: 0.15),
                          selectedForegroundColor: _tipo.cor,
                          foregroundColor: c.textMuted,
                          side: BorderSide(color: c.border),
                          textStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        segments: const [
                          ButtonSegment(
                              value: TipoTransacao.despesa,
                              label: Text('Despesas')),
                          ButtonSegment(
                              value: TipoTransacao.receita,
                              label: Text('Receitas')),
                        ],
                        selected: {_tipo},
                        onSelectionChanged: (s) =>
                            setState(() => _tipo = s.first),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _categorias == null
                        ? (_erro == null
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: GranioColors.emerald))
                            : GranioEmptyState(
                                icone: Icons.cloud_off_rounded,
                                titulo: 'Não deu para carregar',
                                mensagem: _erro,
                                acao: 'Tentar de novo',
                                onAcao: _carregar,
                              ))
                        : lista.isEmpty
                            ? GranioEmptyState(
                                icone: Icons.category_outlined,
                                titulo: 'Nenhuma categoria de '
                                    '${_tipo.rotulo.toLowerCase()}',
                                mensagem:
                                    'Crie categorias para organizar seus lançamentos.',
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: lista.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) => _ItemCategoria(
                                  categoria: lista[i],
                                  onTap: () => mostrarCategoriaSheet(context,
                                      categoria: lista[i]),
                                  onRemover: () => _remover(lista[i]),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCategoria extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  const _ItemCategoria({
    required this.categoria,
    required this.onTap,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return GranioCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: categoria.cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(GranioIcones.categoria(categoria.icone),
                color: categoria.cor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              categoria.nome,
              style: TextStyle(
                color: c.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remover',
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
            onPressed: onRemover,
            icon: Icon(Icons.delete_outline_rounded, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
