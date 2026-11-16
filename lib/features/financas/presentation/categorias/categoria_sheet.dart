import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_button.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_text_field.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

/// Cria/edita uma categoria. Devolve a categoria salva (ou `null` se fechou).
Future<Categoria?> mostrarCategoriaSheet(
  BuildContext context, {
  Categoria? categoria,
  TipoTransacao tipo = TipoTransacao.despesa,
}) {
  final repo = context.read<IFinancasRepository>();
  return mostrarGranioSheet<Categoria>(
    context,
    titulo: categoria == null ? 'Nova categoria' : 'Editar categoria',
    builder: (_) => _CategoriaForm(
      repo: repo,
      categoria: categoria,
      tipo: categoria?.tipo ?? tipo,
    ),
  );
}

class _CategoriaForm extends StatefulWidget {
  final IFinancasRepository repo;
  final Categoria? categoria;
  final TipoTransacao tipo;

  const _CategoriaForm({
    required this.repo,
    required this.categoria,
    required this.tipo,
  });

  @override
  State<_CategoriaForm> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<_CategoriaForm> {
  late final _nome = TextEditingController(text: widget.categoria?.nome);
  late TipoTransacao _tipo = widget.tipo;
  late Color _cor = widget.categoria?.cor ?? GranioIcones.paleta.first;
  late String _icone = widget.categoria?.icone ??
      (widget.tipo == TipoTransacao.receita ? 'salario' : 'outros');
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty) {
      avisar(context, 'Dê um nome para a categoria.', erro: true);
      return;
    }
    setState(() => _salvando = true);
    try {
      final salva = await widget.repo.salvarCategoria(Categoria(
        id: widget.categoria?.id,
        nome: _nome.text.trim(),
        tipo: _tipo,
        cor: _cor,
        icone: _icone,
      ));
      if (mounted) Navigator.pop(context, salva);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisar(context, mensagemDeErro(e), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final editando = widget.categoria != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prévia
        Center(
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: _cor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(GranioIcones.categoria(_icone), color: _cor, size: 30),
          ),
        ),
        const SizedBox(height: 18),
        if (!editando) ...[
          SegmentedButton<TipoTransacao>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: _tipo.cor.withValues(alpha: 0.15),
              selectedForegroundColor: _tipo.cor,
              foregroundColor: c.textMuted,
              side: BorderSide(color: c.border),
            ),
            segments: const [
              ButtonSegment(
                  value: TipoTransacao.despesa, label: Text('Despesa')),
              ButtonSegment(
                  value: TipoTransacao.receita, label: Text('Receita')),
            ],
            selected: {_tipo},
            onSelectionChanged: (s) => setState(() => _tipo = s.first),
          ),
          const SizedBox(height: 16),
        ],
        GranioTextField(
          label: 'Nome',
          hint: 'Ex.: Academia',
          icon: Icons.label_outline_rounded,
          controller: _nome,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 14),
        const RotuloCampo('Cor'),
        SeletorCor(
          selecionada: _cor,
          onChanged: (cor) => setState(() => _cor = cor),
        ),
        const SizedBox(height: 14),
        const RotuloCampo('Ícone'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final MapEntry(key: chave, value: icone)
                in GranioIcones.categorias.entries)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _icone = chave),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: _icone == chave
                        ? _cor.withValues(alpha: 0.18)
                        : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _icone == chave ? _cor : c.border,
                    ),
                  ),
                  child: Icon(icone,
                      size: 20, color: _icone == chave ? _cor : c.textMuted),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _salvando
            ? const Center(
                child: CircularProgressIndicator(color: GranioColors.emerald))
            : GranioButton(
                label: editando ? 'Salvar alterações' : 'Criar categoria',
                onPressed: _salvar,
              ),
      ],
    );
  }
}
