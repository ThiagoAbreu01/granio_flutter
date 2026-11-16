import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Rosca com animação de entrada. Toque numa fatia para destacá-la.
class GranioDonutChart extends StatefulWidget {
  final List<(double valor, Color cor)> fatias;
  final double tamanho;
  final double espessura;

  /// Conteúdo no centro (ex.: total). Recebe o índice destacado (ou null).
  final Widget Function(int? selecionada) centro;
  final ValueChanged<int?>? onSelecionar;

  const GranioDonutChart({
    super.key,
    required this.fatias,
    required this.centro,
    this.tamanho = 180,
    this.espessura = 22,
    this.onSelecionar,
  });

  @override
  State<GranioDonutChart> createState() => _GranioDonutChartState();
}

class _GranioDonutChartState extends State<GranioDonutChart>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  int? _selecionada;

  @override
  void didUpdateWidget(covariant GranioDonutChart old) {
    super.didUpdateWidget(old);
    if (old.fatias.length != widget.fatias.length) _selecionada = null;
    if (old.fatias != widget.fatias) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _tocar(Offset p) {
    final r = widget.tamanho / 2;
    final d = p - Offset(r, r);
    final dist = d.distance;
    if (dist < r - widget.espessura - 10 || dist > r + 6) {
      _selecionar(null);
      return;
    }
    // Ângulo a partir do topo, sentido horário.
    var ang = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (ang < 0) ang += 2 * math.pi;
    final total = widget.fatias.fold<double>(0, (s, f) => s + f.$1);
    if (total <= 0) return;
    var acc = 0.0;
    for (var i = 0; i < widget.fatias.length; i++) {
      acc += widget.fatias[i].$1 / total * 2 * math.pi;
      if (ang <= acc) {
        _selecionar(_selecionada == i ? null : i);
        return;
      }
    }
  }

  void _selecionar(int? i) {
    setState(() => _selecionada = i);
    widget.onSelecionar?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final trilho = GranioColors.of(context).surfaceAlt;
    return GestureDetector(
      onTapUp: (d) => _tocar(d.localPosition),
      child: SizedBox.square(
        dimension: widget.tamanho,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => CustomPaint(
            painter: _DonutPainter(
              fatias: widget.fatias,
              progresso: Curves.easeOutCubic.transform(_anim.value),
              espessura: widget.espessura,
              selecionada: _selecionada,
              trilho: trilho,
            ),
            child: Center(child: widget.centro(_selecionada)),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> fatias;
  final double progresso;
  final double espessura;
  final int? selecionada;
  final Color trilho;

  _DonutPainter({
    required this.fatias,
    required this.progresso,
    required this.espessura,
    required this.selecionada,
    required this.trilho,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raio = size.width / 2 - espessura / 2 - 4;
    final rect = Rect.fromCircle(center: centro, radius: raio);

    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..color = trilho,
    );

    final total = fatias.fold<double>(0, (s, f) => s + f.$1);
    if (total <= 0) return;

    // Pequeno vão entre fatias, só se houver mais de uma.
    final gap = fatias.length > 1 ? 0.035 : 0.0;
    var inicio = -math.pi / 2;
    final varredura = 2 * math.pi * progresso;
    for (var i = 0; i < fatias.length; i++) {
      final ang = fatias[i].$1 / total * varredura;
      final destaque = selecionada == i;
      final esmaecida = selecionada != null && !destaque;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = destaque ? espessura + 8 : espessura
        ..color =
            esmaecida ? fatias[i].$2.withValues(alpha: 0.30) : fatias[i].$2;
      final sweep = math.max(0.0, ang - gap);
      if (sweep > 0) canvas.drawArc(rect, inicio + gap / 2, sweep, false, p);
      inicio += ang;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) =>
      o.progresso != progresso ||
      o.selecionada != selecionada ||
      o.fatias != fatias ||
      o.trilho != trilho;
}

/// Barras agrupadas (receita × despesa) por mês, com eixo de valores.
class GranioBarrasMensais extends StatefulWidget {
  final List<(String rotulo, int receitas, int despesas)> meses;
  final double altura;

  const GranioBarrasMensais({
    super.key,
    required this.meses,
    this.altura = 190,
  });

  @override
  State<GranioBarrasMensais> createState() => _GranioBarrasMensaisState();
}

class _GranioBarrasMensaisState extends State<GranioBarrasMensais>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  int? _selecionado;

  @override
  void didUpdateWidget(covariant GranioBarrasMensais old) {
    super.didUpdateWidget(old);
    if (old.meses != widget.meses) {
      _selecionado = null;
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final sel = _selecionado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Detalhe do mês tocado (ou dica).
        SizedBox(
          height: 22,
          child: sel == null
              ? Text(
                  'Toque em um mês para ver os valores',
                  style: TextStyle(color: c.textMuted, fontSize: 12),
                )
              : Text.rich(
                  TextSpan(
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${widget.meses[sel].$1}  ',
                        style: TextStyle(
                            color: c.text, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: formatarCentavos(widget.meses[sel].$2),
                        style: const TextStyle(color: GranioColors.income),
                      ),
                      const TextSpan(text: '  ·  '),
                      TextSpan(
                        text: formatarCentavos(widget.meses[sel].$3),
                        style: const TextStyle(color: GranioColors.expense),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) => GestureDetector(
            onTapUp: (d) {
              final n = widget.meses.length;
              const eixo = 44.0;
              final larguraGrupo = (box.maxWidth - eixo) / n;
              final i = ((d.localPosition.dx - eixo) / larguraGrupo).floor();
              setState(() =>
                  _selecionado = (i < 0 || i >= n || i == sel) ? null : i);
            },
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) => CustomPaint(
                size: Size(box.maxWidth, widget.altura),
                painter: _BarrasPainter(
                  base: DefaultTextStyle.of(context).style,
                  meses: widget.meses,
                  progresso: Curves.easeOutCubic.transform(_anim.value),
                  selecionado: sel,
                  grade: c.border,
                  texto: c.textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarrasPainter extends CustomPainter {
  /// Estilo de texto do contexto: o CustomPainter não herda a fonte do tema.
  final TextStyle base;
  final List<(String, int, int)> meses;
  final double progresso;
  final int? selecionado;
  final Color grade;
  final Color texto;

  _BarrasPainter({
    required this.base,
    required this.meses,
    required this.progresso,
    required this.selecionado,
    required this.grade,
    required this.texto,
  });

  static const _eixo = 44.0;
  static const _rodape = 22.0;

  void _texto(Canvas canvas, String s, Offset pos,
      {TextAlign align = TextAlign.left,
      double largura = 40,
      bool negrito = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: base.copyWith(
          color: texto,
          fontSize: 11,
          fontWeight: negrito ? FontWeight.w700 : FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: largura, maxWidth: largura);
    tp.paint(canvas, pos - Offset(0, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (meses.isEmpty) return;
    final alturaUtil = size.height - _rodape;
    final maximo =
        meses.fold<int>(0, (m, e) => math.max(m, math.max(e.$2, e.$3)));
    // Topo "redondo" para o eixo ficar legível.
    final topo = _arredondar(maximo == 0 ? 10000 : maximo);

    // Grade + rótulos do eixo (0, 50%, 100%).
    for (final f in [0.0, 0.5, 1.0]) {
      final y = alturaUtil - alturaUtil * f;
      canvas.drawLine(
        Offset(_eixo, y),
        Offset(size.width, y),
        Paint()
          ..color = grade
          ..strokeWidth = 1,
      );
      _texto(canvas, formatarCentavosCurto((topo * f).round()), Offset(0, y),
          largura: _eixo - 6, align: TextAlign.right);
    }

    final larguraGrupo = (size.width - _eixo) / meses.length;
    final larguraBarra = math.min(14.0, larguraGrupo * 0.26);
    for (var i = 0; i < meses.length; i++) {
      final (rotulo, rec, desp) = meses[i];
      final cx = _eixo + larguraGrupo * i + larguraGrupo / 2;
      final esmaecido = selecionado != null && selecionado != i;

      void barra(int valor, double x, Color cor) {
        final h = alturaUtil * (valor / topo) * progresso;
        if (h <= 0) return;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, alturaUtil - h, larguraBarra, h),
            topLeft: const Radius.circular(5),
            topRight: const Radius.circular(5),
          ),
          Paint()..color = esmaecido ? cor.withValues(alpha: 0.3) : cor,
        );
      }

      barra(rec, cx - larguraBarra - 2, GranioColors.income);
      barra(desp, cx + 2, GranioColors.expense);
      _texto(canvas, rotulo, Offset(cx - 20, size.height - _rodape / 2),
          align: TextAlign.center, negrito: selecionado == i);
    }
  }

  /// 3.742,18 -> 4.000; 12.480 -> 15.000 (em centavos).
  int _arredondar(int v) {
    final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toInt();
    for (final m in [1, 2, 2.5, 5, 10]) {
      final c = (mag * m).round();
      if (c >= v) return c;
    }
    return mag * 10;
  }

  @override
  bool shouldRepaint(_BarrasPainter o) =>
      o.progresso != progresso ||
      o.selecionado != selecionado ||
      o.meses != meses ||
      o.grade != grade;
}
