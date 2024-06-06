import 'package:flutter/material.dart';

class SessionState extends ChangeNotifier {
  bool _isSessionStarted = false;

  bool get isSessionStarted => _isSessionStarted;

  void startSession() {
    _isSessionStarted = true;
    notifyListeners();
  }

  void endSession() {
    _isSessionStarted = false;
    notifyListeners();
  }
}
