import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tenant.dart';

class TenantService {
  Future<List<tenant>> fetchTenants() async {
   const String _baseUrl = 'https://peeman-mobile-app-backend.onrender.com';

    try {
      final response = await http.get(Uri.parse('$_baseUrl/tenants'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => tenant.fromJson(json)).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load tenants: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load tenants: $error');
    }
  }
}