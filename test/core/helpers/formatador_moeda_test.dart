import 'package:flutter_test/flutter_test.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';

void main() {
  group('formatarCentavos', () {
    test('formata milhar e centavos', () {
      expect(formatarCentavos(0), 'R\$ 0,00');
      expect(formatarCentavos(5), 'R\$ 0,05');
      expect(formatarCentavos(123456), 'R\$ 1.234,56');
      expect(formatarCentavos(99999999999), 'R\$ 999.999.999,99');
    });

    test('sinal', () {
      expect(formatarCentavos(-2450), '- R\$ 24,50');
      expect(formatarCentavos(2450, comSinal: true), '+ R\$ 24,50');
      expect(formatarCentavos(0, comSinal: true), 'R\$ 0,00');
    });
  });

  group('CentavosInputFormatter', () {
    TextEditingValue digitar(String texto, {bool negativo = false}) =>
        CentavosInputFormatter(permiteNegativo: negativo).formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: texto),
        );

    test('dígitos entram pela direita', () {
      expect(digitar('1').text, '0,01');
      expect(digitar('123').text, '1,23');
      expect(digitar('123456').text, '1.234,56');
    });

    test('ignora letras e limita o tamanho', () {
      expect(digitar('1a2b3').text, '1,23');
      expect(digitar('9' * 15).text, '999.999.999,99');
    });

    test('vazio quando zero; negativo só se permitido', () {
      expect(digitar('0').text, '');
      expect(digitar('-150').text, '1,50');
      expect(digitar('-150', negativo: true).text, '-1,50');
    });

    test('ida e volta com centavosDeTexto', () {
      expect(centavosDeTexto(digitar('123456').text), 123456);
    });
  });
}
