import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Peeman/models/due_rent_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/services/due_rent_service.dart';

enum DueRentState { idle, loading, error }
class DueRentProvider with ChangeNotifier {
  final DueRentService _service = DueRentService(); // Remove asterisk
  List<DueRentModel> _tenants = []; // Remove asterisk and make private
  DueRentState _state = DueRentState.idle; // Remove asterisk and make private
  String? _errorMessage; // Remove asterisk and make private

  List<DueRentModel> get tenants => _tenants; // Remove asterisk
  DueRentState get state => _state; // Remove asterisk
  String? get errorMessage => _errorMessage; // Remove asterisk
  bool get isLoading => _state == DueRentState.loading; // Remove asterisk

  Future<void> loadTenants({required BuildContext context}) async {
    debugPrint('[DueRentProvider] Starting loadTenants');
    _state = DueRentState.loading; // Remove asterisk
    _errorMessage = null; // Remove asterisk
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false); // Remove asterisk
      final token = authProvider.token;

      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }

      debugPrint('[DueRentProvider] Fetching due rents using token: $token');

      final fetched = await _service.fetchDueRent(token); // Remove asterisk
      print("see fetched");
      print(fetched);
      debugPrint('[DueRentProvider] Fetched tenants: ${fetched.length}');

      for (var tenant in fetched) {
        debugPrint(
            '[DueRentProvider] Tenant: ${tenant.firstName} ${tenant.lastName}, Status: ${tenant.status}');
      }

      _tenants = fetched; // Remove asterisk
      _state = DueRentState.idle; // Remove asterisk
      notifyListeners();
    } catch (error) {
      debugPrint('[DueRentProvider] Error fetching due rents: $error');
      _state = DueRentState.error; // Remove asterisk
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}