import 'dart:convert';
import 'package:Peeman/constants/api.dart';
import 'package:Peeman/models/tenant_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/tenant.dart';

class TenantService {

  Future<List<tenant>> fetchTenants(String token) async { 
    try {
           
      final response = await http.get(
        Uri.parse(ApiEndpoints.tenants), // Replace with your API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${token}"
        },
      );
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


// ...existing code...

  Future<void> addTenant({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String unit,
    required String property, // property ID as String
    required double rentAmount,
    required double securityDeposit,
    required String leaseStartDate, // ISO string
    required String leaseEndDate,   // ISO string
    required String nextPaymentDue, // ISO string
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String emergencyContactRelationship,
  }) async {
    try {
      final uri = Uri.parse(ApiEndpoints.tenants);
      final tenants ={
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "unit": unit,
        "property": property, // Ensure this is the correct property ID
        "rentAmount": rentAmount,
        "securityDeposit": securityDeposit,
        "leaseStartDate": leaseStartDate,
        "leaseEndDate": leaseEndDate,
        "nextPaymentDue": nextPaymentDue,
        "emergencyContact": {
          "name": emergencyContactName,
          "phone": emergencyContactPhone,
          "relationship": emergencyContactRelationship,
        }
      };
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(tenants),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add tenant: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add tenant: $e');
    }
  }
}
        


    
