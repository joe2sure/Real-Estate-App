import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _activeTab = '';
  int _onboardingStep = 0;
  String _authTab = 'login';

  String get activeTab => _activeTab;
  int get onboardingStep => _onboardingStep;
  String get authTab => _authTab;

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  void setAuthTab(String tab) {
    _authTab = tab;
    notifyListeners();
  }
}