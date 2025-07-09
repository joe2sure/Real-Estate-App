import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/tenant_service.dart';

class TenantProvider with ChangeNotifier {
  final TenantService _service = TenantService();
  List<tenant> _tenants = [];
  bool _isLoading = false;

  List<tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;

  Future<void> loadTenants() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tenants = await _service.fetchTenants();
    } catch (error) {
      // Handle error (e.g., show a snackbar or log it)
      print('Error loading tenants: $error');
    }
    _isLoading = false;
    notifyListeners();
  }
}