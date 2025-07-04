import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../constants/api.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _stats;
  List<dynamic>? _monthlyRevenue;
  List<dynamic>? _recentPayments;
  List<dynamic>? _recentTenants;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get stats => _stats;
  List<dynamic>? get monthlyRevenue => _monthlyRevenue;
  List<dynamic>? get recentPayments => _recentPayments;
  List<dynamic>? get recentTenants => _recentTenants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _showToast(BuildContext context, String message, {bool isError = false}) async {
    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
        backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
        textColor: AppColors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      // Fallback to ScaffoldMessenger if fluttertoast fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.white, fontSize: 14.0),
          ),
          backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
        ),
      );
    }
  }

  Future<void> fetchDashboardData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      _errorMessage = 'No authentication token available';
      _isLoading = false;
      await _showToast(context, _errorMessage!, isError: true);
      notifyListeners();
      return;
    }

    try {
      // Fetch stats
      final statsResponse = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        if (statsData['success']) {
          _stats = statsData['data']['stats'];
          _monthlyRevenue = statsData['data']['monthlyRevenue'];
        } else {
          throw Exception(statsData['message'] ?? 'Failed to fetch stats');
        }
      } else {
        throw Exception('Failed to fetch stats: ${statsResponse.statusCode}');
      }

      // Fetch activity
      final activityResponse = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/dashboard/activity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (activityResponse.statusCode == 200) {
        final activityData = jsonDecode(activityResponse.body);
        if (activityData['success']) {
          _recentPayments = activityData['data']['recentPayments'];
          _recentTenants = activityData['data']['recentTenants'];
        } else {
          throw Exception(activityData['message'] ?? 'Failed to fetch activity');
        }
      } else {
        throw Exception('Failed to fetch activity: ${activityResponse.statusCode}');
      }

      await _showToast(context, 'Dashboard data loaded successfully');
    } catch (e) {
      _errorMessage = e.toString();
      await _showToast(context, _errorMessage ?? 'Failed to load dashboard data', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
