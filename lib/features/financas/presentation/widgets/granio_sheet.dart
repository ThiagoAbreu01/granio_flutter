import 'package:flutter/material.dart';
import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';

/// Abre um bottom sheet com o visual da marca (alça, cantos, teclado).
Future<T?> mostrarGranioSheet<T>(
  BuildContext context, {
  required String titulo,
  required Widget Function(BuildContext) builder,
}) {
  final c = GranioColors.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: c.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                builder(ctx),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Confirmação simples (excluir etc). `true` = confirmou.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String acao = 'Excluir',
}) async {
  final c = GranioColors.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      title: Text(titulo, style: TextStyle(color: c.text)),
      content: Text(mensagem, style: TextStyle(color: c.textMuted)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: c.textMuted,
          ),
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: GranioColors.expense,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child:
              Text(acao, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Snackbar flutuante padrão das telas financeiras.
void avisar(BuildContext context, String texto, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            erro ? const Color(0xFFB91C1C) : const Color(0xFF0F172A),
        content: Text(texto, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
      ),
    );
}

String mensagemDeErro(Object e, [String padrao = 'Algo deu errado.']) =>
    e is Failure ? (e.message ?? padrao) : padrao;

/// Grade de cores selecionáveis.
class SeletorCor extends StatelessWidget {
  final Color selecionada;
  final ValueChanged<Color> onChanged;

  const SeletorCor({
    super.key,
    required this.selecionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final cor in GranioIcones.paleta)
          GestureDetector(
            onTap: () => onChanged(cor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selecionada.toARGB32() == cor.toARGB32()
                      ? GranioColors.of(context).text
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: selecionada.toARGB32() == cor.toARGB32()
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Rótulo pequeno acima de um grupo do formulário.
class RotuloCampo extends StatelessWidget {
  final String texto;
  const RotuloCampo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
        child: Text(
          texto,
          style: TextStyle(
            color: GranioColors.of(context).textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
