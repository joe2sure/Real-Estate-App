import 'package:Peeman/models/due_rent_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/services/due_rent_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DueRentState { idle, loading, error }

class DueRentProvider with ChangeNotifier {


  final DueRentService _service = DueRentService();
  List<DueRentModel> _tenants = [];
  DueRentState _state = DueRentState.idle;
  String? _errorMessage;

  List<DueRentModel> get tenants => _tenants;
  DueRentState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == DueRentState.loading;


  Future<void> loadTenants( {required BuildContext context}) async {
    _state = DueRentState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.fetchDueRent(token);
      _state = DueRentState.idle;
      notifyListeners();
    } catch (error) {
      _state = DueRentState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}
