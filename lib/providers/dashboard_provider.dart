import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../constants/api.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

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
      if (context.mounted) {
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

   
    if (!authProvider.isTokenValid()) {
      _errorMessage = 'Session expired';
      _isLoading = false;
      await ApiService.handleUnauthorized(context);
      notifyListeners();
      return;
    }

    try {
      final headers = ApiService.getAuthHeaders(token);

  
      final statsResponse = await ApiService.authenticatedGet(
        context,
        '${ApiEndpoints.baseUrl}/dashboard/stats',
        headers: headers,
      );

      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        if (statsData['success']) {
          _stats = statsData['data']['stats'];
          _monthlyRevenue = statsData['data']['monthlyRevenue'];
        } else {
          throw Exception(statsData['message'] ?? 'Failed to fetch stats');
        }
      } else if (statsResponse.statusCode != 401) {
        // 401 is already handled by ApiService
        throw Exception('Failed to fetch stats: ${statsResponse.statusCode}');
      }

      // ✅ Fetch activity using ApiService
      final activityResponse = await ApiService.authenticatedGet(
        context,
        '${ApiEndpoints.baseUrl}/dashboard/activity',
        headers: headers,
      );

      if (activityResponse.statusCode == 200) {
        final activityData = jsonDecode(activityResponse.body);
        if (activityData['success']) {
          _recentPayments = activityData['data']['recentPayments'];
          _recentTenants = activityData['data']['recentTenants'] ?? [];
        } else {
          throw Exception(activityData['message'] ?? 'Failed to fetch activity');
        }
      } else if (activityResponse.statusCode != 401) {
        throw Exception('Failed to fetch activity: ${activityResponse.statusCode}');
      }

      await _showToast(context, 'Dashboard data loaded successfully');
    } catch (e) {
      _errorMessage = e.toString();
      if (!e.toString().contains('Session expired')) {
        await _showToast(context, _errorMessage ?? 'Failed to load dashboard data', isError: true);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}