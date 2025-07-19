import 'dart:convert';
import 'package:Peeman/models/due_rent_model.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class DueRentService {


  Future<List<DueRentModel>> fetchDueRent(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.overdue),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tenants = data['data']['tenants'] as List;
          return tenants.map((json) => DueRentModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tenants');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch tenants: $error');
    }

  }}
