import 'package:flutter/foundation.dart';

/// Avisa que os dados financeiros mudaram (transação, conta ou categoria
/// salva/excluída). Os controllers de home, histórico e contas escutam e
/// recarregam — assim uma tela não precisa conhecer as outras.
class FinancasSync extends ChangeNotifier {
  void avisarMudanca() => notifyListeners();
}
