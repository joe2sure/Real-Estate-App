import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _activeTab = 'dashboard'; // Default to 'dashboard'
  int _onboardingStep = -2;
  String _authTab = 'login';
  bool _autoLogin = true;

  String get activeTab => _activeTab;
  int get onboardingStep => _onboardingStep;
  String get authTab => _authTab;
  bool get autoLogin => _autoLogin;

  void setActiveTab(String tab, {BuildContext? context}) {
    _activeTab = tab;
    notifyListeners();
    // Navigation is now handled in MainScreen, so context is not needed here
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  void setAuthTab(String tab) {
    _authTab = tab;
    notifyListeners();
  }

  void toggleAutoLogin(bool value) {
    _autoLogin = value;
    notifyListeners();
  }
}




// import 'package:flutter/material.dart';

// class AppState extends ChangeNotifier {
//   String _activeTab = 'dashboard'; // Default to 'dashboard'
//   int _onboardingStep = -2;
//   String _authTab = 'login';
//   bool _autoLogin = true;

//   String get activeTab => _activeTab;
//   int get onboardingStep => _onboardingStep;
//   String get authTab => _authTab;
//   bool get autoLogin => _autoLogin;

//   void setActiveTab(String tab, {BuildContext? context}) {
//     _activeTab = tab;
//     notifyListeners();
//     if (context != null && tab.isNotEmpty) {
//       Navigator.of(context).pushReplacementNamed('/$tab');
//     }
//   }

//   void setOnboardingStep(int step) {
//     _onboardingStep = step;
//     notifyListeners();
//   }

//   void setAuthTab(String tab) {
//     _authTab = tab;
//     notifyListeners();
//   }

//   void toggleAutoLogin(bool value) {
//     _autoLogin = value;
//     notifyListeners();
//   }
// }