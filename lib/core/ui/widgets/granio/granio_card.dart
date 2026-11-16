import 'package:flutter/material.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Superfície padrão: fundo `surface`, borda sutil, cantos de 20.
class GranioCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GranioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final radius = BorderRadius.circular(20);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Título de seção com ação opcional à direita ("Ver tudo").
class GranioSectionTitle extends StatelessWidget {
  final String titulo;
  final String? acao;
  final VoidCallback? onAcao;

  const GranioSectionTitle(this.titulo, {super.key, this.acao, this.onAcao});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                color: c.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (acao != null)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: GranioColors.emerald,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onAcao,
              child: Text(
                acao!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cabeçalho das telas sem AppBar: voltar (opcional), título e ações.
class GranioPageHeader extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final bool voltar;
  final List<Widget> acoes;

  const GranioPageHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.voltar = false,
    this.acoes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          if (voltar) ...[
            GranioIconButton(
              icone: Icons.arrow_back_rounded,
              tooltip: 'Voltar',
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: TextStyle(color: c.textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
          ...acoes,
        ],
      ),
    );
  }
}

/// Botão redondo com borda (cabeçalhos).
class GranioIconButton extends StatelessWidget {
  final IconData icone;
  final String tooltip;
  final VoidCallback onTap;
  final Color? cor;

  const GranioIconButton({
    super.key,
    required this.icone,
    required this.tooltip,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        shape: CircleBorder(side: BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icone, color: cor ?? c.text, size: 21),
          ),
        ),
      ),
    );
  }
}

/// "‹ Novembro ›" — navega entre meses. Não deixa passar do mês atual + 12.
class GranioMesSelector extends StatelessWidget {
  final MesRef mes;
  final ValueChanged<MesRef> onChanged;

  const GranioMesSelector({
    super.key,
    required this.mes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final limite = MesRef.atual().somar(12);
    Widget seta(IconData i, String tip, MesRef? destino) => IconButton(
          tooltip: tip,
          style: IconButton.styleFrom(backgroundColor: Colors.transparent),
          onPressed: destino == null ? null : () => onChanged(destino),
          icon: Icon(i, color: destino == null ? c.border : c.text, size: 22),
        );

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          seta(Icons.chevron_left_rounded, 'Mês anterior', mes.somar(-1)),
          Expanded(
            child: GestureDetector(
              onTap: mes.ehAtual ? null : () => onChanged(MesRef.atual()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mes.rotulo,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!mes.ehAtual)
                    const Text(
                      'toque para voltar ao mês atual',
                      style:
                          TextStyle(color: GranioColors.emerald, fontSize: 10),
                    ),
                ],
              ),
            ),
          ),
          seta(Icons.chevron_right_rounded, 'Próximo mês',
              mes.compareTo(limite) >= 0 ? null : mes.somar(1)),
        ],
      ),
    );
  }
}

/// Estado vazio/erro com ícone, texto e ação opcional.
class GranioEmptyState extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? mensagem;
  final String? acao;
  final VoidCallback? onAcao;

  const GranioEmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.acao,
    this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: GranioColors.emerald.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: GranioColors.emerald, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (mensagem != null) ...[
            const SizedBox(height: 6),
            Text(
              mensagem!,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.4),
            ),
          ],
          if (acao != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: GranioColors.emerald.withValues(alpha: 0.14),
                foregroundColor: GranioColors.emerald,
              ),
              onPressed: onAcao,
              child: Text(acao!,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
