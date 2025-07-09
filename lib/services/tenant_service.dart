import 'dart:convert';
import 'package:Peeman/constants/api.dart';
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
}