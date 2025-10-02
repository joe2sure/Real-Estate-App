import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants/api.dart';
import '../providers/auth_provider.dart';

class RevenueAnalyticsProvider with ChangeNotifier {
  List<dynamic>? _monthlyRevenue;
  List<dynamic>? _revenueByProperty;
  List<dynamic>? _paymentTrends;
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic>? get monthlyRevenue => _monthlyRevenue;
  List<dynamic>? get revenueByProperty => _revenueByProperty;
  List<dynamic>? get paymentTrends => _paymentTrends;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRevenueAnalytics(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/analytics/revenue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _monthlyRevenue = data['data']['monthlyRevenue'];
          _revenueByProperty = data['data']['revenueByProperty'];
          _paymentTrends = data['data']['paymentTrends'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to fetch revenue analytics');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}