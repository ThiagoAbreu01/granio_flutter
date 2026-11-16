import 'dart:convert';

/// Normaliza a resposta da API que ora vem como `String` (JSON cru),
/// ora já decodificada como `Map`/`List`.
Map<String, dynamic> decodeMap(dynamic raw) {
  if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
  return raw as Map<String, dynamic>;
}

List<dynamic> decodeList(dynamic raw) {
  if (raw is String) return jsonDecode(raw) as List;
  return raw as List;
}
