import 'package:flutter/material.dart';

// Counter Provider
class CounterProvider extends ChangeNotifier {
  int _count = 5;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }

  void reset() {
    _count = 5;
    notifyListeners();
  }
}
