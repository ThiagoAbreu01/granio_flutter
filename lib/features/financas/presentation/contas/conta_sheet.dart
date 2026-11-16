import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_button.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_text_field.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

/// Cria/edita uma conta. Devolve a conta salva (ou `null`).
Future<Conta?> mostrarContaSheet(BuildContext context, {Conta? conta}) {
  final repo = context.read<IFinancasRepository>();
  return mostrarGranioSheet<Conta>(
    context,
    titulo: conta == null ? 'Nova conta' : 'Editar conta',
    builder: (_) => _ContaForm(repo: repo, conta: conta),
  );
}

class _ContaForm extends StatefulWidget {
  final IFinancasRepository repo;
  final Conta? conta;

  const _ContaForm({required this.repo, required this.conta});

  @override
  State<_ContaForm> createState() => _ContaFormState();
}

class _ContaFormState extends State<_ContaForm> {
  late final _nome = TextEditingController(text: widget.conta?.nome);
  late final _saldo = TextEditingController(
    text: widget.conta == null || widget.conta!.saldoInicial == 0
        ? ''
        : '${widget.conta!.saldoInicial < 0 ? '-' : ''}'
            '${textoDeCentavos(widget.conta!.saldoInicial.abs())}',
  );
  late String _tipo = widget.conta?.tipo ?? 'corrente';
  late Color _cor = widget.conta?.cor ?? GranioIcones.paleta[4];
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _saldo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty) {
      avisar(context, 'Dê um nome para a conta.', erro: true);
      return;
    }
    final negativo = _saldo.text.contains('-');
    final centavos = centavosDeTexto(_saldo.text) * (negativo ? -1 : 1);
    setState(() => _salvando = true);
    try {
      final salva = await widget.repo.salvarConta(Conta(
        id: widget.conta?.id,
        nome: _nome.text.trim(),
        tipo: _tipo,
        saldoInicial: centavos,
        cor: _cor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GranioTextField(
          label: 'Nome',
          hint: 'Ex.: Nubank, Carteira',
          icon: Icons.label_outline_rounded,
          controller: _nome,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        const RotuloCampo('Tipo'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final MapEntry(key: chave, value: rotulo)
                in Conta.tipos.entries)
              ChoiceChip(
                avatar: Icon(GranioIcones.conta(chave),
                    size: 18, color: _tipo == chave ? _cor : c.textMuted),
                label: Text(rotulo),
                selected: _tipo == chave,
                showCheckmark: false,
                selectedColor: _cor.withValues(alpha: 0.16),
                backgroundColor: c.surface,
                side: BorderSide(color: _tipo == chave ? _cor : c.border),
                labelStyle: TextStyle(
                  color: _tipo == chave ? c.text : c.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _tipo = chave),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GranioTextField(
          label: 'Saldo inicial (opcional)',
          hint: '0,00',
          icon: Icons.attach_money_rounded,
          controller: _saldo,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: const [
            CentavosInputFormatter(permiteNegativo: true),
          ],
          textInputAction: TextInputAction.done,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            'Quanto já havia na conta antes de usar o Granio. '
            'Digite "-" para saldo negativo.',
            style: TextStyle(color: c.textMuted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 14),
        const RotuloCampo('Cor'),
        SeletorCor(
          selecionada: _cor,
          onChanged: (cor) => setState(() => _cor = cor),
        ),
        const SizedBox(height: 24),
        _salvando
            ? const Center(
                child: CircularProgressIndicator(color: GranioColors.emerald))
            : GranioButton(
                label: widget.conta == null ? 'Criar conta' : 'Salvar',
                onPressed: _salvar,
              ),
      ],
    );
  }
}
