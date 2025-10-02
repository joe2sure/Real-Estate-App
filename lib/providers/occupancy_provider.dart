import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants/api.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OccupancyProvider with ChangeNotifier {
  double? _occupancyRate;
  List<dynamic>? _tenantDistribution;
  List<dynamic>? _topProperties;
  bool _isLoading = false;
  String? _errorMessage;

  double? get occupancyRate => _occupancyRate;
  List<dynamic>? get tenantDistribution => _tenantDistribution;
  List<dynamic>? get topProperties => _topProperties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOccupancyData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/analytics/occupancy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _occupancyRate = data['data']['occupancyRate'];
          _tenantDistribution = data['data']['tenantDistribution'];
          _topProperties = data['data']['topProperties'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to fetch occupancy data');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}