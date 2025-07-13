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
}