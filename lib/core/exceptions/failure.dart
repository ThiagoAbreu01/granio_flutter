/// Erro com mensagem pronta para o usuário. É o que os datasources lançam e
/// o que os controllers mostram.
class Failure implements Exception {
  final String? message;
  Failure({this.message});

  @override
  String toString() => '$runtimeType(message: $message)';
}
