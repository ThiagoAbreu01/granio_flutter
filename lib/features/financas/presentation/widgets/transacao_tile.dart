import 'package:flutter/material.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';

/// Linha de transação (home e histórico).
class TransacaoTile extends StatelessWidget {
  final Transacao transacao;
  final bool ocultarValor;
  final String? detalheExtra;
  final VoidCallback? onTap;

  const TransacaoTile({
    super.key,
    required this.transacao,
    this.ocultarValor = false,
    this.detalheExtra,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final t = transacao;
    final transf = t.tipo == TipoTransacao.transferencia;
    final corIcone = transf ? GranioColors.teal : (t.categoriaCor ?? c.text);
    final corValor = switch (t.tipo) {
      TipoTransacao.receita => GranioColors.income,
      TipoTransacao.despesa => GranioColors.expense,
      TipoTransacao.transferencia => c.text,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: corIcone.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                transf
                    ? GranioIcones.transferencia
                    : GranioIcones.categoria(t.categoriaIcone),
                color: corIcone,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detalheExtra == null
                        ? t.subtitulo
                        : '${t.subtitulo} · $detalheExtra',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ocultarValor
                  ? 'R\$ ••••'
                  : formatarCentavos(t.valorComSinal,
                      comSinal: t.tipo == TipoTransacao.receita),
              style: TextStyle(
                color: ocultarValor ? c.textMuted : corValor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
