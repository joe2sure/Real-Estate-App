import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../constants/api.dart';

enum AuthState { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  User? _currentUser;
  String? _token;
  bool _isLoggedIn = false;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    final box = await Hive.openBox('auth');
    final storedUser = box.get('user');
    final storedToken = box.get('token');

    if (storedUser != null && storedToken != null) {
      _currentUser = storedUser;
      _token = storedToken;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = User.fromJson(data['data']['user']);
        _token = data['data']['token'];
        _isLoggedIn = true;

        final box = await Hive.openBox('auth');
        await box.put('user', _currentUser);
        await box.put('token', _token);

        _state = AuthState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Login failed';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _state = AuthState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Registration failed';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final box = await Hive.openBox('auth');
        await box.clear();

        _currentUser = null;
        _token = null;
        _isLoggedIn = false;
        _state = AuthState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Logout failed';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}






// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../constants/api.dart';
// import '../models/user_model.dart';
// // import '../constants/api.dart';

// enum AuthState { idle, loading, success, error }

// class AuthProvider extends ChangeNotifier {
//   AuthState _state = AuthState.idle;
//   String? _errorMessage;
//   User? _currentUser;
//   String? _token;
//   bool _isLoggedIn = false;

//   AuthState get state => _state;
//   String? get errorMessage => _errorMessage;
//   User? get currentUser => _currentUser;
//   String? get token => _token;
//   bool get isLoggedIn => _isLoggedIn;

//   Future<void> init() async {
//     await Hive.initFlutter();
//     Hive.registerAdapter(UserAdapter());
//     final box = await Hive.openBox('auth');
//     final storedUser = box.get('user');
//     final storedToken = box.get('token');
    
//     if (storedUser != null && storedToken != null) {
//       _currentUser = storedUser;
//       _token = storedToken;
//       _isLoggedIn = true;
//       notifyListeners();
//     }
//   }

//   Future<bool> login(String email, String password) async {
//     _state = AuthState.loading;
//     notifyListeners();

//     try {
//       final response = await http.post(
//         Uri.parse(ApiEndpoints.login),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//         }),
//       );

//       final data = jsonDecode(response.body);
      
//       if (response.statusCode == 200 && data['success'] == true) {
//         _currentUser = User.fromJson(data['data']['user']);
//         _token = data['data']['token'];
//         _isLoggedIn = true;
        
//         final box = await Hive.openBox('auth');
//         await box.put('user', _currentUser);
//         await box.put('token', _token);

//         _state = AuthState.success;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = data['message'] ?? 'Login failed';
//         _state = AuthState.error;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'An error occurred: $e';
//       _state = AuthState.error;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> register({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     _state = AuthState.loading;
//     notifyListeners();

//     try {
//       final response = await http.post(
//         Uri.parse(ApiEndpoints.register),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'firstName': firstName,
//           'lastName': lastName,
//           'email': email,
//           'password': password,
//           'role': role,
//         }),
//       );

//       final data = jsonDecode(response.body);
      
//       if (response.statusCode == 200 && data['success'] == true) {
//         _state = AuthState.success;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = data['message'] ?? 'Registration failed';
//         _state = AuthState.error;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'An error occurred: $e';
//       _state = AuthState.error;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     final box = await Hive.openBox('auth');
//     await box.clear();
    
//     _currentUser = null;
//     _token = null;
//     _isLoggedIn = false;
//     _state = AuthState.idle;
//     notifyListeners();
//   }

//   void clearError() {
//     _errorMessage = null;
//     _state = AuthState.idle;
//     notifyListeners();
//   }
// }