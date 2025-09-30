import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Peeman/models/due_rent_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/services/due_rent_service.dart';

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

  Future<void> loadTenants({required BuildContext context}) async {
    debugPrint('[DueRentProvider] Starting loadTenants');
    _state = DueRentState.loading; 
    _errorMessage = null; 
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false); 
      final token = authProvider.token;

      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }

      debugPrint('[DueRentProvider] Fetching due rents using token: $token');

      final fetched = await _service.fetchDueRent(token); 
      print("see fetched");
      print(fetched);
      debugPrint('[DueRentProvider] Fetched tenants: ${fetched.length}');

      for (var tenant in fetched) {
        debugPrint(
            '[DueRentProvider] Tenant: ${tenant.firstName} ${tenant.lastName}, Status: ${tenant.status}');
      }

      _tenants = fetched; 
      _state = DueRentState.idle; 
      notifyListeners();
    } catch (error) {
      debugPrint('[DueRentProvider] Error fetching due rents: $error');
      _state = DueRentState.error; 
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}