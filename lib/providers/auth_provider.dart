import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';
import '../models/user_model.dart';

enum AuthState { idle, loading, error }

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  String? _token;

  User? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  Future<void> init() async {
    final box = await Hive.openBox('auth');
    final userJson = box.get('user');
    final token = box.get('token');
    if (userJson != null && token != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      _token = token;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _currentUser = User.fromJson(data['data']['user']);
          _token = data['data']['token'];
          final box = await Hive.openBox('auth');
          await box.put('user', jsonEncode(data['data']['user']));
          await box.put('token', _token);
          _state = AuthState.idle;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Login failed';
          _state = AuthState.error;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _state = AuthState.idle;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Registration failed';
          _state = AuthState.error;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final box = await Hive.openBox('auth');
        await box.delete('user');
        await box.delete('token');
        _currentUser = null;
        _token = null;
        _state = AuthState.idle;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Logout failed: ${response.statusCode}';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
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