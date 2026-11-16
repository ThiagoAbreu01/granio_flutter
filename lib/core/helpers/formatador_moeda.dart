import 'package:flutter/services.dart';

/// Formata centavos em Real sem depender do pacote intl:
/// 123450 -> "R$ 1.234,50". A API trafega dinheiro sempre em centavos (int).
String formatarCentavos(int centavos, {bool comSinal = false}) {
  final negativo = centavos < 0;
  final abs = centavos.abs();
  final sinal = negativo ? '- ' : (comSinal && centavos > 0 ? '+ ' : '');
  return '${sinal}R\$ ${_milhar(abs ~/ 100)},${(abs % 100).toString().padLeft(2, '0')}';
}

/// Versão compacta para eixos de gráfico: 1.2 mil, 3,4 mi.
String formatarCentavosCurto(int centavos) {
  final reais = centavos / 100;
  if (reais.abs() >= 1000000) {
    return '${(reais / 1000000).toStringAsFixed(1).replaceAll('.', ',')} mi';
  }
  if (reais.abs() >= 1000) {
    return '${(reais / 1000).toStringAsFixed(1).replaceAll('.', ',')} mil';
  }
  return reais.toStringAsFixed(0);
}

String _milhar(int inteiro) {
  final s = inteiro.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// "1.234,56" -> 123456. Só os dígitos importam.
int centavosDeTexto(String texto) =>
    int.tryParse(texto.replaceAll(RegExp(r'\D'), '')) ?? 0;

/// Texto sem o "R$": 123456 -> "1.234,56".
String textoDeCentavos(int centavos) =>
    '${_milhar(centavos ~/ 100)},${(centavos % 100).toString().padLeft(2, '0')}';

/// Digitação estilo app de banco: cada dígito entra pela direita
/// (1 -> 0,01 -> 0,12 -> 1,23). Sinal negativo com "-" quando [permiteNegativo].
class CentavosInputFormatter extends TextInputFormatter {
  final bool permiteNegativo;
  static const _max = 99999999999;

  const CentavosInputFormatter({this.permiteNegativo = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final negativo = permiteNegativo && newValue.text.contains('-');
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);
    final valor = (int.tryParse(digitos) ?? 0).clamp(0, _max);
    final texto = valor == 0 && !negativo
        ? ''
        : '${negativo ? '-' : ''}${textoDeCentavos(valor)}';
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
