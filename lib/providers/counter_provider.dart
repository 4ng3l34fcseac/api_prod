import 'package:flutter/foundation.dart';

class CounterProvider extends ChangeNotifier {
  int contador = 0;

  void incrementar() {
    contador++;
    notifyListeners();
  }

  void decrementar() {
    contador--;
    notifyListeners();
  }

  void reiniciar() {
    contador = 0;
    notifyListeners();
  }
}