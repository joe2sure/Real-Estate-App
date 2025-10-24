// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state.dart';

class ApiService {
  static Future<http.Response> authenticatedGet(
    BuildContext context,
    String url, {
    Map<String, String>? headers,
  }) async {
    return _makeAuthenticatedRequest(
      context,
      () => http.get(Uri.parse(url), headers: headers),
    );
  }

  static Future<http.Response> authenticatedPost(
    BuildContext context,
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeAuthenticatedRequest(
      context,
      () => http.post(Uri.parse(url), headers: headers, body: body),
    );
  }

  static Future<http.Response> authenticatedPut(
    BuildContext context,
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeAuthenticatedRequest(
      context,
      () => http.put(Uri.parse(url), headers: headers, body: body),
    );
  }

  static Future<http.Response> authenticatedDelete(
    BuildContext context,
    String url, {
    Map<String, String>? headers,
  }) async {
    return _makeAuthenticatedRequest(
      context,
      () => http.delete(Uri.parse(url), headers: headers),
    );
  }

  static Future<http.Response> _makeAuthenticatedRequest(
    BuildContext context,
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      
      // Check for 401 Unauthorized
      if (response.statusCode == 401) {
        await handleUnauthorized(context);
        throw Exception('Session expired. Please login again.');
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> handleUnauthorized(BuildContext context) async {
    if (!context.mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Clear authentication data
    await authProvider.clearAuth();
    
    // Reset app state to show auth screen
    appState.setOnboardingStep(-1);
    
    // Show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper to get auth headers
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Check if token is expired (JWT decode)
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (payload['exp'] == null) return false;

      final exp = payload['exp'] as int;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      
      // Check if token expires in the next 5 minutes
      return DateTime.now().add(const Duration(minutes: 5)).isAfter(expiryDate);
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return true; // Treat as expired if we can't parse
    }
  }
}