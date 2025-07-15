import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../services/tenant_service.dart';
import '../providers/auth_provider.dart';

enum TenantState { idle, loading, error }

class TenantProvider with ChangeNotifier {
  final TenantService _service = TenantService();
  List<Tenant> _tenants = [];
  TenantState _state = TenantState.idle;
  String? _errorMessage;

  List<Tenant> get tenants => _tenants;
  TenantState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TenantState.loading;

  Future<void> loadTenants(BuildContext context) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.fetchTenants(token);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTenantsByProperty(BuildContext context, String propertyId) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.fetchTenantsByProperty(token, propertyId);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> searchTenants(BuildContext context, String query) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.searchTenants(token, query);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTenantsByStatus(BuildContext context, String status) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.fetchTenantsByStatus(token, status);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<Tenant> fetchTenantById(BuildContext context, String tenantId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      return await _service.fetchTenantById(token, tenantId);
    } catch (error) {
      throw Exception('Failed to fetch tenant: $error');
    }
  }

  Future<void> createTenant(BuildContext context, Map<String, dynamic> tenantData) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      final newTenant = await _service.createTenant(token, tenantData);
      _tenants.insert(0, newTenant);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> updateTenant(BuildContext context, String tenantId, Map<String, dynamic> tenantData) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      final updatedTenant = await _service.updateTenant(token, tenantId, tenantData);
      final index = _tenants.indexWhere((t) => t.id == tenantId);
      if (index != -1) {
        _tenants[index] = updatedTenant;
      }
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTenant(BuildContext context, String tenantId) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      await _service.deleteTenant(token, tenantId);
      _tenants.removeWhere((t) => t.id == tenantId);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> sendPaymentReminder(BuildContext context, String tenantId, String message) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      await _service.sendPaymentReminder(token, tenantId, message);
      _state = TenantState.idle;
      notifyListeners();
    } catch (error) {
      _state = TenantState.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}




// import 'package:Peeman/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/tenant.dart';
// import '../services/tenant_service.dart';

// class TenantProvider with ChangeNotifier {
//   final TenantService _service = TenantService();
//   List<tenant> _tenants = [];
//   bool _isLoading = false;

//   List<tenant> get tenants => _tenants;
//   bool get isLoading => _isLoading;

//   Future<void> loadTenants(BuildContext context) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       _tenants = await _service.fetchTenants(token);
//     } catch (error) {
//       // Handle error (e.g., show a snackbar or log it)
//       print('Error loading tenants: $error');
//     }
//     _isLoading = false;
//     notifyListeners();
//   }
// }