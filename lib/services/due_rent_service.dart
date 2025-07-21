import 'dart:convert';
import 'package:Peeman/models/due_rent_model.dart';
import 'package:flutter/cupertino.dart';
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
          //print("data");
          //print(data);
        //  final tenants = data['data']['tenants'] as List;
          print("data");
          print(data['data']);
          final tenantsJson = data['data'] as List;

          debugPrint('[DueRentService] Tenants count: ${tenantsJson.length}');
          debugPrint('[DueRentService] First tenant (if any): ${tenantsJson.isNotEmpty ? tenantsJson[0] : "None"}');

          return tenantsJson
              .map((json) => DueRentModel.fromJson(json))
              .toList();
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
