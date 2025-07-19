import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/payment_model.dart';

class PaymentService {
  static const String _baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';

  static Future<List<Payment>> getAllPayments(String token, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((payment) => Payment.fromJson(payment))
              .toList();
        }
      }
      throw Exception('Failed to fetch payments');
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  static Future<List<Payment>> getRecentPayments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/recent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((payment) => Payment.fromJson(payment))
              .toList();
        }
      }
      throw Exception('Failed to fetch recent payments');
    } catch (e) {
      throw Exception('Error fetching recent payments: $e');
    }
  }

  static Future<Payment> getPaymentById(String token, String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Payment.fromJson(data['data']);
        }
      }
      throw Exception('Failed to fetch payment details');
    } catch (e) {
      throw Exception('Error fetching payment details: $e');
    }
  }

  static Future<PaymentSummary> getPaymentSummary(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PaymentSummary.fromJson(data['data']);
        }
      }
      throw Exception('Failed to fetch payment summary');
    } catch (e) {
      throw Exception('Error fetching payment summary: $e');
    }
  }

  static Future<Payment> recordPayment(String token, Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Payment.fromJson(data['data']);
        }
      }
      throw Exception('Failed to record payment');
    } catch (e) {
      throw Exception('Error recording payment: $e');
    }
  }

  static Future<Payment> updatePayment(String token, String paymentId, Map<String, dynamic> paymentData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Payment.fromJson(data['data']);
        }
      }
      throw Exception('Failed to update payment');
    } catch (e) {
      throw Exception('Error updating payment: $e');
    }
  }

  static Future<PaymentIntent> createPaymentIntent(String token, {
    required double amount,
    required String tenantId,
    required String propertyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'tenantId': tenantId,
          'propertyId': propertyId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PaymentIntent.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create payment intent');
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  static Future<bool> deletePayment(String token, String paymentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting payment: $e');
    }
  }
}
