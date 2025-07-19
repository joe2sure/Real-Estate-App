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

  // Original method that requires BuildContext (keeping for backward compatibility)
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

  // New method that accepts token directly (for payment forms)
  Future<void> fetchTenants(String token) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  // Token-based version for payment forms
  Future<void> fetchTenantsByPropertyWithToken(String token, String propertyId) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  // Token-based version for payment forms
  Future<void> searchTenantsWithToken(String token, String query) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  // Token-based version for payment forms
  Future<void> fetchTenantsByStatusWithToken(String token, String status) async {
    _state = TenantState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  // Token-based version for payment forms
  Future<Tenant> fetchTenantByIdWithToken(String token, String tenantId) async {
    try {
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

  // Utility methods
  void clearTenants() {
    _tenants.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == TenantState.error) {
      _state = TenantState.idle;
    }
    notifyListeners();
  }

  // Get tenant by ID from current list
  Tenant? getTenantById(String tenantId) {
    try {
      return _tenants.firstWhere((tenant) => tenant.id == tenantId);
    } catch (e) {
      return null;
    }
  }

  // Filter tenants by status from current list
  List<Tenant> getTenantsByStatus(String status) {
    return _tenants.where((tenant) => tenant.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Filter tenants by property from current list
  List<Tenant> getTenantsByProperty(String propertyId) {
    return _tenants.where((tenant) => tenant.property?.id == propertyId).toList();
  }
}





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/tenant.dart';
// import '../services/tenant_service.dart';
// import '../providers/auth_provider.dart';

// enum TenantState { idle, loading, error }

// class TenantProvider with ChangeNotifier {
//   final TenantService _service = TenantService();
//   List<Tenant> _tenants = [];
//   TenantState _state = TenantState.idle;
//   String? _errorMessage;

//   List<Tenant> get tenants => _tenants;
//   TenantState get state => _state;
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _state == TenantState.loading;

//   Future<void> loadTenants(BuildContext context) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       _tenants = await _service.fetchTenants(token);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchTenantsByProperty(BuildContext context, String propertyId) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       _tenants = await _service.fetchTenantsByProperty(token, propertyId);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> searchTenants(BuildContext context, String query) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       _tenants = await _service.searchTenants(token, query);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchTenantsByStatus(BuildContext context, String status) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       _tenants = await _service.fetchTenantsByStatus(token, status);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<Tenant> fetchTenantById(BuildContext context, String tenantId) async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       return await _service.fetchTenantById(token, tenantId);
//     } catch (error) {
//       throw Exception('Failed to fetch tenant: $error');
//     }
//   }

//   Future<void> createTenant(BuildContext context, Map<String, dynamic> tenantData) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       final newTenant = await _service.createTenant(token, tenantData);
//       _tenants.insert(0, newTenant);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> updateTenant(BuildContext context, String tenantId, Map<String, dynamic> tenantData) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       final updatedTenant = await _service.updateTenant(token, tenantId, tenantData);
//       final index = _tenants.indexWhere((t) => t.id == tenantId);
//       if (index != -1) {
//         _tenants[index] = updatedTenant;
//       }
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> deleteTenant(BuildContext context, String tenantId) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       await _service.deleteTenant(token, tenantId);
//       _tenants.removeWhere((t) => t.id == tenantId);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> sendPaymentReminder(BuildContext context, String tenantId, String message) async {
//     _state = TenantState.loading;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       if (token == null) {
//         throw Exception('No authentication token found. Please log in.');
//       }
//       await _service.sendPaymentReminder(token, tenantId, message);
//       _state = TenantState.idle;
//       notifyListeners();
//     } catch (error) {
//       _state = TenantState.error;
//       _errorMessage = error.toString();
//       notifyListeners();
//     }
//   }
// }