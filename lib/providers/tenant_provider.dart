import 'package:Peeman/models/tenant_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../services/tenant_service.dart';

class TenantProvider with ChangeNotifier {
  final TenantService _service = TenantService();
  List<tenant> _tenants = [];
  bool _isLoading = false;

  List<tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;

  Future<void> loadTenants(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _tenants = await _service.fetchTenants(token);
    } catch (error) {
      // Handle error (e.g., show a snackbar or log it)
      print('Error loading tenants: $error');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTenant({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String unit,
    required String property,
    required double rentAmount,
    required double securityDeposit,
    required String leaseStartDate,
    required String leaseEndDate,
    required String nextPaymentDue,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String emergencyContactRelationship,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
    await _service.addTenant(
      // TODO: Replace 'yourPositionalArgument' with the actual required positional argument
      token: token,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      unit: unit,
      property: property,
      rentAmount: rentAmount,
      securityDeposit: securityDeposit,
      leaseStartDate: leaseStartDate,
      leaseEndDate: leaseEndDate,
      nextPaymentDue: nextPaymentDue,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      emergencyContactRelationship: emergencyContactRelationship,
    );
    // Optionally, reload tenants from backend:
    await loadTenants(context);
    notifyListeners();
  } catch (error) {
      // Handle error (e.g., show a snackbar or log it)
      print('Error adding tenant: $error');
    }
  }
}

