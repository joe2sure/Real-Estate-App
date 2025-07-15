import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/tenant.dart';

class TenantService {
  Future<List<Tenant>> fetchTenants(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.tenants),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => Tenant.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tenants');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch tenants: $error');
    }
  }

  Future<List<Tenant>> fetchTenantsByProperty(String token, String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tenants}/$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => Tenant.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tenants by property');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch tenants by property: $error');
    }
  }

  Future<List<Tenant>> searchTenants(String token, String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tenants}?search=$query&page=1&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => Tenant.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search tenants');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to search tenants: $error');
    }
  }

  Future<List<Tenant>> fetchTenantsByStatus(String token, String status) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tenants}?status=$status&page=1&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => Tenant.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tenants by status');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch tenants by status: $error');
    }
  }

  Future<Tenant> fetchTenantById(String token, String tenantId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tenants}/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Tenant.fromJson(data['data']['tenant']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch tenant: $error');
    }
  }

  Future<Tenant> createTenant(String token, Map<String, dynamic> tenantData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.tenants),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tenantData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Tenant.fromJson(data['data']['tenant']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to create tenant: $error');
    }
  }

  Future<Tenant> updateTenant(String token, String tenantId, Map<String, dynamic> tenantData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.tenants}/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tenantData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Tenant.fromJson(data['data']['tenant']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to update tenant: $error');
    }
  }

  Future<void> deleteTenant(String token, String tenantId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.tenants}/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to delete tenant: $error');
    }
  }

  Future<void> sendPaymentReminder(String token, String tenantId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.tenants}/$tenantId/payment-reminder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to send payment reminder');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to send payment reminder: $error');
    }
  }
}





// import 'dart:convert';
// import 'package:Peeman/constants/api.dart';
// import 'package:Peeman/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../models/tenant.dart';

// class TenantService {

//   Future<List<tenant>> fetchTenants(String token) async { 
//     try {
           
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.tenants), // Replace with your API endpoint
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': "Bearer ${token}"
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final tenants = data['data']['tenants'] as List;
//           return tenants.map((json) => tenant.fromJson(json)).toList();
//         } else {
//           throw Exception('API returned success: false');
//         }
//       } else {
//         throw Exception('Failed to load tenants: ${response.statusCode}');
//       }
//     } catch (error) {
//       throw Exception('Failed to load tenants: $error');
//     }
//   }
// }