import 'package:equatable/equatable.dart';

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

const _diasSemana = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

String nomeMes(int mes) => _meses[mes - 1];
String nomeMesCurto(int mes) => _meses[mes - 1].substring(0, 3).toLowerCase();

DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

/// `yyyy-MM-dd` (formato da API).
String dataApi(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "Hoje", "Ontem" ou "12 de nov".
String dataRelativa(DateTime d) {
  final hoje = soData(DateTime.now());
  final dias = hoje.difference(soData(d)).inDays;
  if (dias == 0) return 'Hoje';
  if (dias == 1) return 'Ontem';
  if (dias == -1) return 'Amanhã';
  final ano = d.year == hoje.year ? '' : ' de ${d.year}';
  return '${d.day} de ${nomeMesCurto(d.month)}$ano';
}

/// Cabeçalho do grupo de dias no histórico: "Hoje", "Ontem", "Sexta, 12 de nov".
String cabecalhoDia(DateTime d) {
  final rel = dataRelativa(d);
  if (rel == 'Hoje' || rel == 'Ontem' || rel == 'Amanhã') return rel;
  final dia = _diasSemana[d.weekday - 1];
  return '${dia[0].toUpperCase()}${dia.substring(1)}, $rel';
}

/// Mês de referência dos filtros/relatórios.
class MesRef extends Equatable implements Comparable<MesRef> {
  final int ano;
  final int mes;

  const MesRef(this.ano, this.mes);

  factory MesRef.atual() {
    final h = DateTime.now();
    return MesRef(h.year, h.month);
  }

  /// "2026-11" -> MesRef(2026, 11).
  factory MesRef.parse(String s) {
    final p = s.split('-');
    return MesRef(int.parse(p[0]), int.parse(p[1]));
  }

  MesRef somar(int meses) {
    final d = DateTime(ano, mes + meses);
    return MesRef(d.year, d.month);
  }

  bool get ehAtual => this == MesRef.atual();

  /// `yyyy-MM`.
  String get api => '$ano-${mes.toString().padLeft(2, '0')}';

  /// "Novembro 2026" (ou só "Novembro" no ano corrente).
  String get rotulo =>
      ano == DateTime.now().year ? nomeMes(mes) : '${nomeMes(mes)} $ano';

  String get rotuloCurto => nomeMesCurto(mes);

  @override
  int compareTo(MesRef o) => ano != o.ano ? ano - o.ano : mes - o.mes;

  @override
  List<Object?> get props => [ano, mes];
}
