import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';

/// Campo de texto da marca: rótulo acima, fundo preenchido, ícone à esquerda
/// e botão de mostrar/ocultar quando é senha.
class GranioTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const GranioTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  State<GranioTextField> createState() => _GranioTextFieldState();
}

class _GranioTextFieldState extends State<GranioTextField> {
  late bool _oculto = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    OutlineInputBorder borda(Color cor, [double largura = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: c.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextField(
          controller: widget.controller,
          obscureText: _oculto,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          cursorColor: GranioColors.emerald,
          style: TextStyle(
            color: c.text,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: c.surface,
            hintText: widget.hint,
            hintStyle: TextStyle(color: c.textMuted.withValues(alpha: 0.6)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            prefixIcon: Icon(widget.icon, size: 20, color: c.textMuted),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _oculto ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: () => setState(() => _oculto = !_oculto),
                    icon: Icon(
                      _oculto
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: c.textMuted,
                    ),
                  )
                : null,
            enabledBorder: borda(c.border),
            focusedBorder: borda(GranioColors.emerald, 1.6),
            border: borda(c.border),
          ),
        ),
      ],
    );
  }
}
