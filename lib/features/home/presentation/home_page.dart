import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_charts.dart';
import 'package:granio_flutter/core/widgets/main_layout_controller.dart';
import 'package:granio_flutter/features/financas/domain/entities/dashboard.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/transacao_tile.dart';
import 'package:granio_flutter/features/home/presentation/home_controller.dart';
import 'package:granio_flutter/features/home/presentation/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GranioBackground(
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeController, HomeState>(
          builder: (context, state) {
            final controller = context.read<HomeController>();
            final d = state.dashboard;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RefreshIndicator(
                  color: GranioColors.emerald,
                  onRefresh: controller.carregar,
                  child: ListView(
                    // Espaço extra no fim por causa da bottom nav flutuante.
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _Cabecalho(nome: state.contaConectada?.primeiroNome),
                      const SizedBox(height: 18),
                      GranioMesSelector(
                        mes: state.mes,
                        onChanged: controller.trocarMes,
                      ),
                      const SizedBox(height: 16),
                      if (d == null && state.status == HomeStatus.erro)
                        GranioEmptyState(
                          icone: Icons.cloud_off_rounded,
                          titulo: 'Não deu para carregar o resumo',
                          mensagem: state.erro,
                          acao: 'Tentar de novo',
                          onAcao: controller.carregar,
                        )
                      else if (d == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: GranioColors.emerald),
                          ),
                        )
                      else
                        ..._conteudo(context, d, state.valoresOcultos),
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

  List<Widget> _conteudo(BuildContext context, Dashboard d, bool ocultos) => [
        _CartaoSaldo(dashboard: d, ocultos: ocultos),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _CartaoFluxo(
                tipo: TipoTransacao.receita,
                valor: d.receitasMes,
                ocultos: ocultos,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _CartaoFluxo(
                tipo: TipoTransacao.despesa,
                valor: d.despesasMes,
                ocultos: ocultos,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _AcoesRapidas(),
        const SizedBox(height: 28),
        _GraficoCategorias(dashboard: d, ocultos: ocultos),
        const SizedBox(height: 28),
        const GranioSectionTitle('Receitas × despesas'),
        GranioCard(
          child: GranioBarrasMensais(
            meses: [
              for (final e in d.evolucao)
                (e.mes.rotuloCurto, e.receitas, e.despesas),
            ],
          ),
        ),
        const SizedBox(height: 28),
        GranioSectionTitle(
          'Últimas transações',
          acao: 'Ver tudo',
          onAcao: () => context.go('/history'),
        ),
        GranioCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: d.ultimasTransacoes.isEmpty
              ? GranioEmptyState(
                  icone: Icons.receipt_long_outlined,
                  titulo: 'Nenhuma transação ainda',
                  mensagem: 'Registre o que entrou e o que saiu para '
                      'acompanhar seu dinheiro.',
                  acao: 'Lançar despesa',
                  onAcao: () =>
                      abrirNovaTransacao(context, TipoTransacao.despesa),
                )
              : Column(
                  children: [
                    for (final t in d.ultimasTransacoes)
                      TransacaoTile(
                        transacao: t,
                        ocultarValor: ocultos,
                        onTap: () => abrirTransacao(context, t),
                      ),
                  ],
                ),
        ),
      ];
}

String _valor(int centavos, bool ocultos, {bool comSinal = false}) =>
    ocultos ? 'R\$ ••••••' : formatarCentavos(centavos, comSinal: comSinal);

// ---------------------------------------------------------------- cabeçalho

class _Cabecalho extends StatelessWidget {
  final String? nome;

  const _Cabecalho({required this.nome});

  String get _saudacao {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final inicial = (nome?.isNotEmpty ?? false) ? nome![0].toUpperCase() : 'G';

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            height: 46,
            width: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: GranioColors.brandGradient,
            ),
            child: Text(
              inicial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_saudacao,',
                  style: TextStyle(color: c.textMuted, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                nome ?? 'Bem-vindo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        GranioIconButton(
          icone: Icons.logout_rounded,
          tooltip: 'Sair',
          onTap: () => context.read<MainLayoutController>().sair(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- saldo

class _CartaoSaldo extends StatelessWidget {
  final Dashboard dashboard;
  final bool ocultos;

  const _CartaoSaldo({required this.dashboard, required this.ocultos});

  @override
  Widget build(BuildContext context) {
    final resultado = dashboard.resultadoMes;
    final positivo = resultado >= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 10, 22),
      decoration: BoxDecoration(
        gradient: GranioColors.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: GranioColors.emerald.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(right: -30, bottom: -70, child: _Anel(170)),
          const Positioned(right: 40, bottom: -95, child: _Anel(150)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Saldo total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: ocultos ? 'Mostrar valores' : 'Ocultar valores',
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent),
                    onPressed: () =>
                        context.read<HomeController>().alternarValores(),
                    icon: Icon(
                      ocultos
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _valor(dashboard.saldoTotal, ocultos),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      positivo
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Resultado de ${dashboard.mes.rotulo.toLowerCase()}: '
                        '${_valor(resultado, ocultos, comSinal: true)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Anel extends StatelessWidget {
  final double tamanho;

  const _Anel(this.tamanho);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: tamanho,
        width: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 18,
          ),
        ),
      ),
    );
  }
}

class _CartaoFluxo extends StatelessWidget {
  final TipoTransacao tipo;
  final int valor;
  final bool ocultos;

  const _CartaoFluxo({
    required this.tipo,
    required this.valor,
    required this.ocultos,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return GranioCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.go('/history?tipo=${tipo.api}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: tipo.cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tipo.icone, color: tipo.cor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                tipo.plural,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _valor(valor, ocultos),
              style: TextStyle(
                color: c.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text('neste mês', style: TextStyle(color: c.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- ações

class _AcoesRapidas extends StatelessWidget {
  const _AcoesRapidas();

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final acoes = [
      (
        Icons.add_rounded,
        'Receita',
        GranioColors.income,
        () => abrirNovaTransacao(context, TipoTransacao.receita),
      ),
      (
        Icons.remove_rounded,
        'Despesa',
        GranioColors.expense,
        () => abrirNovaTransacao(context, TipoTransacao.despesa),
      ),
      (
        Icons.swap_horiz_rounded,
        'Transferir',
        GranioColors.teal,
        () => abrirNovaTransacao(context, TipoTransacao.transferencia),
      ),
      (
        Icons.category_outlined,
        'Categorias',
        GranioColors.gold,
        () => context.push(RotasFinancas.categorias),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (icone, rotulo, cor, onTap) in acoes)
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.border),
                    ),
                    child: Icon(icone, color: cor, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rotulo,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- categorias

/// Rosca de gastos (ou receitas) por categoria, com legenda.
/// Mostra as 5 maiores e agrupa o resto em "Outras".
class _GraficoCategorias extends StatefulWidget {
  final Dashboard dashboard;
  final bool ocultos;

  const _GraficoCategorias({required this.dashboard, required this.ocultos});

  @override
  State<_GraficoCategorias> createState() => _GraficoCategoriasState();
}

class _GraficoCategoriasState extends State<_GraficoCategorias> {
  TipoTransacao _tipo = TipoTransacao.despesa;

  List<(String nome, int total, Color cor, String icone)> get _fatias {
    final lista = _tipo == TipoTransacao.despesa
        ? widget.dashboard.despesasPorCategoria
        : widget.dashboard.receitasPorCategoria;
    final fatias = [
      for (final c in lista.take(5)) (c.nome, c.total, c.cor, c.icone),
    ];
    if (lista.length > 5) {
      final resto = lista.skip(5).fold<int>(0, (s, c) => s + c.total);
      fatias.add(('Outras', resto, const Color(0xFF94A3B8), 'outros'));
    }
    return fatias;
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final fatias = _fatias;
    final total = fatias.fold<int>(0, (s, f) => s + f.$2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Por categoria',
                style: TextStyle(
                  color: c.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SegmentedButton<TipoTransacao>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                selectedBackgroundColor:
                    GranioColors.emerald.withValues(alpha: 0.15),
                selectedForegroundColor: GranioColors.emerald,
                foregroundColor: c.textMuted,
                side: BorderSide(color: c.border),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              segments: const [
                ButtonSegment(
                    value: TipoTransacao.despesa, label: Text('Gastos')),
                ButtonSegment(
                    value: TipoTransacao.receita, label: Text('Receitas')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GranioCard(
          child: total == 0
              ? GranioEmptyState(
                  icone: Icons.donut_large_rounded,
                  titulo: _tipo == TipoTransacao.despesa
                      ? 'Sem gastos neste mês'
                      : 'Sem receitas neste mês',
                  mensagem: 'Os lançamentos do mês aparecem aqui, '
                      'separados por categoria.',
                )
              : Column(
                  children: [
                    GranioDonutChart(
                      fatias: [for (final f in fatias) (f.$2.toDouble(), f.$3)],
                      centro: (sel) => _Centro(
                        rotulo: sel == null ? 'Total' : fatias[sel].$1,
                        valor: _valor(sel == null ? total : fatias[sel].$2,
                            widget.ocultos),
                        detalhe: sel == null
                            ? '${fatias.length} categorias'
                            : '${(fatias[sel].$2 / total * 100).round()}%',
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final f in fatias)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LinhaLegenda(
                          nome: f.$1,
                          cor: f.$3,
                          icone: f.$4,
                          pct: f.$2 / total,
                          valor: _valor(f.$2, widget.ocultos),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Centro extends StatelessWidget {
  final String rotulo;
  final String valor;
  final String detalhe;

  const _Centro({
    required this.rotulo,
    required this.valor,
    required this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.textMuted, fontSize: 12)),
          FittedBox(
            child: Text(
              valor,
              style: TextStyle(
                color: c.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(detalhe, style: TextStyle(color: c.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LinhaLegenda extends StatelessWidget {
  final String nome;
  final Color cor;
  final String icone;
  final double pct;
  final String valor;

  const _LinhaLegenda({
    required this.nome,
    required this.cor,
    required this.icone,
    required this.pct,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(GranioIcones.categoria(icone), color: cor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    valor,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        color: cor,
                        backgroundColor: c.surfaceAlt,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${(pct * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: c.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
