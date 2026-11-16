import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/transacao_tile.dart';
import 'package:granio_flutter/features/history/presentation/history_controller.dart';

class HistoryRouter {
  const HistoryRouter();

  Widget page({TipoTransacao? tipo}) => Builder(
        builder: (context) => BlocProvider(
          create: (c) => HistoryController(
            repository: c.read(),
            sync: c.read(),
            tipoInicial: tipo,
          )..carregar(),
          child: const HistoryPage(),
        ),
      );
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _busca = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        context.read<HistoryController>().carregarMais();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busca.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onBusca(String texto) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400),
        () => context.read<HistoryController>().buscar(texto));
  }

  void _alternarBusca() {
    setState(() => _buscando = !_buscando);
    if (!_buscando && _busca.text.isNotEmpty) {
      _busca.clear();
      context.read<HistoryController>().buscar(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return GranioBackground(
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HistoryController, HistoryState>(
          builder: (context, state) {
            final ctrl = context.read<HistoryController>();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RefreshIndicator(
                  color: GranioColors.emerald,
                  onRefresh: ctrl.carregar,
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: GranioPageHeader(
                          titulo: 'Histórico',
                          subtitulo: state.status == HistoryStatus.pronto
                              ? '${state.total} '
                                  '${state.total == 1 ? 'lançamento' : 'lançamentos'}'
                              : null,
                          acoes: [
                            GranioIconButton(
                              icone: _buscando
                                  ? Icons.close_rounded
                                  : Icons.search_rounded,
                              tooltip: _buscando ? 'Fechar busca' : 'Buscar',
                              onTap: _alternarBusca,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        sliver: SliverList.list(
                          children: [
                            if (_buscando) ...[
                              TextField(
                                controller: _busca,
                                autofocus: true,
                                onChanged: _onBusca,
                                cursorColor: GranioColors.emerald,
                                style: TextStyle(color: c.text),
                                decoration: InputDecoration(
                                  hintText: 'Buscar pela descrição',
                                  hintStyle: TextStyle(color: c.textMuted),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: c.textMuted),
                                  filled: true,
                                  fillColor: c.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: c.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: c.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: GranioColors.emerald),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            GranioMesSelector(
                              mes: state.filtro.mes ?? MesRef.atual(),
                              onChanged: ctrl.trocarMes,
                            ),
                            const SizedBox(height: 12),
                            _FiltroTipo(
                              tipo: state.filtro.tipo,
                              onChanged: ctrl.trocarTipo,
                            ),
                            const SizedBox(height: 14),
                            if (state.status == HistoryStatus.pronto)
                              _Resumo(state: state),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      ..._lista(context, state),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _lista(BuildContext context, HistoryState state) {
    final ctrl = context.read<HistoryController>();
    if (state.status == HistoryStatus.carregando && state.itens.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
                child: CircularProgressIndicator(color: GranioColors.emerald)),
          ),
        ),
      ];
    }
    if (state.status == HistoryStatus.erro && state.itens.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: GranioEmptyState(
            icone: Icons.cloud_off_rounded,
            titulo: 'Não deu para carregar',
            mensagem: state.erro,
            acao: 'Tentar de novo',
            onAcao: ctrl.carregar,
          ),
        ),
      ];
    }
    if (state.itens.isEmpty) {
      final f = state.filtro;
      return [
        SliverToBoxAdapter(
          child: GranioEmptyState(
            icone: Icons.receipt_long_outlined,
            titulo: f.busca != null
                ? 'Nada encontrado para "${f.busca}"'
                : 'Nenhum lançamento em ${(f.mes ?? MesRef.atual()).rotulo.toLowerCase()}',
            mensagem: 'Use os botões da home para lançar receitas, '
                'despesas e transferências.',
            acao: 'Lançar despesa',
            onAcao: () => abrirNovaTransacao(context, TipoTransacao.despesa),
          ),
        ),
      ];
    }

    // Agrupa por dia (a API já devolve ordenado por data desc).
    final grupos = <DateTime, List<Transacao>>{};
    for (final t in state.itens) {
      grupos.putIfAbsent(soData(t.data), () => []).add(t);
    }

    return [
      for (final MapEntry(key: dia, value: itens) in grupos.entries)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverList.list(
            children: [
              _CabecalhoDia(dia: dia, itens: itens),
              GranioCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Column(
                  children: [
                    for (final t in itens)
                      Dismissible(
                        key: ValueKey('t${t.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: GranioColors.expense.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: GranioColors.expense),
                        ),
                        confirmDismiss: (_) => confirmar(
                          context,
                          titulo: 'Excluir "${t.descricao}"?',
                          mensagem: 'Essa ação não pode ser desfeita.',
                        ),
                        onDismissed: (_) async {
                          final erro = await ctrl.excluir(t);
                          if (!context.mounted) return;
                          avisar(context, erro ?? 'Transação excluída.',
                              erro: erro != null);
                        },
                        child: TransacaoTile(
                          transacao: t,
                          onTap: () => abrirTransacao(context, t),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      if (state.carregandoMais)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child: CircularProgressIndicator(color: GranioColors.emerald)),
          ),
        ),
    ];
  }
}

class _FiltroTipo extends StatelessWidget {
  final TipoTransacao? tipo;
  final ValueChanged<TipoTransacao?> onChanged;

  const _FiltroTipo({required this.tipo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final opcoes = <(TipoTransacao?, String, Color)>[
      (null, 'Todos', GranioColors.emerald),
      for (final t in TipoTransacao.values) (t, t.plural, t.cor),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (t, rotulo, cor) in opcoes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(rotulo),
                selected: tipo == t,
                showCheckmark: false,
                selectedColor: cor.withValues(alpha: 0.16),
                backgroundColor: c.surface,
                side: BorderSide(color: tipo == t ? cor : c.border),
                labelStyle: TextStyle(
                  color: tipo == t ? cor : c.textMuted,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final HistoryState state;

  const _Resumo({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final saldo = state.receitas - state.despesas;
    Widget item(String rotulo, String valor, Color cor) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: TextStyle(color: c.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valor,
                  style: TextStyle(
                    color: cor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );

    return GranioCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          item('Entradas', formatarCentavos(state.receitas),
              GranioColors.income),
          item(
              'Saídas', formatarCentavos(state.despesas), GranioColors.expense),
          item('Resultado', formatarCentavos(saldo, comSinal: true),
              saldo >= 0 ? c.text : GranioColors.expense),
        ],
      ),
    );
  }
}

class _CabecalhoDia extends StatelessWidget {
  final DateTime dia;
  final List<Transacao> itens;

  const _CabecalhoDia({required this.dia, required this.itens});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final saldoDia = itens
        .where((t) => t.tipo != TipoTransacao.transferencia)
        .fold<int>(0, (s, t) => s + t.valorComSinal);
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cabecalhoDia(dia),
              style: TextStyle(
                color: c.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (saldoDia != 0)
            Text(
              formatarCentavos(saldoDia, comSinal: true),
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
