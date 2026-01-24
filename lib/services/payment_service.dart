import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

      debugPrint('📥 Get All Payments Status: ${response.statusCode}');
      debugPrint('📥 Get All Payments Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final paymentsData = data['data']['payments'] as List;
          return paymentsData.map((payment) => Payment.fromJson(payment)).toList();
        }
      }
      throw Exception('Failed to fetch payments');
    } catch (e) {
      debugPrint('❌ Error fetching payments: $e');
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

      debugPrint('📥 Recent Payments Status: ${response.statusCode}');
      debugPrint('📥 Recent Payments Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final paymentsData = data['data']['payments'] as List;
          return paymentsData.map((payment) => Payment.fromJson(payment)).toList();
        }
      }
      throw Exception('Failed to fetch recent payments');
    } catch (e) {
      debugPrint('❌ Error fetching recent payments: $e');
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

      debugPrint('📥 Payment Detail Status: ${response.statusCode}');
      debugPrint('📥 Payment Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final paymentData = data['data']['payment'] ?? data['data'];
          return Payment.fromJson(paymentData);
        }
      }
      throw Exception('Failed to fetch payment details');
    } catch (e) {
      debugPrint('❌ Error fetching payment details: $e');
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

      debugPrint('📥 Payment Summary Status: ${response.statusCode}');
      debugPrint('📥 Payment Summary Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PaymentSummary.fromJson(data['data']);
        }
      }
      throw Exception('Failed to fetch payment summary');
    } catch (e) {
      debugPrint('❌ Error fetching payment summary: $e');
      throw Exception('Error fetching payment summary: $e');
    }
  }

  /// NEW: Updated to return full response with invoice details
  static Future<Map<String, dynamic>> recordPayment(
    String token,
    Map<String, dynamic> paymentData,
  ) async {
    final uri = Uri.parse('$_baseUrl/payments');
    debugPrint('📤 POST $uri');
    debugPrint('📦 Body: ${jsonEncode(paymentData)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          // Extract the payment object
          final paymentData = decoded['data']['payment'] ?? decoded['data'];
          final payment = Payment.fromJson(paymentData);
          
          // Return complete response including invoice details
          return {
            'success': true,
            'payment': payment,
            'invoiceNumber': decoded['data']['invoiceNumber'],
            'paymentReference': decoded['data']['paymentReference'],
            'invoiceEmailSent': decoded['data']['invoiceEmailSent'] ?? false,
            'invoiceEmailError': decoded['data']['invoiceEmailError'],
          };
        }
      }

      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Unknown server error');
    } catch (e) {
      debugPrint('❌ Error recording payment: $e');
      throw Exception('Error recording payment: $e');
    }
  }

  static Future<Payment> updatePayment(
    String token,
    String paymentId,
    Map<String, dynamic> paymentData,
  ) async {
    final uri = Uri.parse('$_baseUrl/payments/$paymentId');
    debugPrint('📤 PUT $uri');
    debugPrint('📦 Body: ${jsonEncode(paymentData)}');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final paymentData = decoded['data']['payment'] ?? decoded['data'];
          return Payment.fromJson(paymentData);
        }
      }

      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Unknown server error');
    } catch (e) {
      debugPrint('❌ Error updating payment: $e');
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
          'amount': amount,
          'tenantId': tenantId,
          'propertyId': propertyId,
        }),
      );

      debugPrint('📥 Stripe Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PaymentIntent.fromJson(data['data']);
        }
      }

      throw Exception(jsonDecode(response.body)['message'] ?? 'Stripe error');
    } catch (e) {
      throw Exception('Stripe payment failed: $e');
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

      debugPrint('📥 Delete Payment Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error deleting payment: $e');
      throw Exception('Error deleting payment: $e');
    }
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // import '../constants/api.dart';
// import '../models/payment_model.dart';

// class PaymentService {
//   static const String _baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';

//   static Future<List<Payment>> getAllPayments(String token, {int page = 1, int limit = 10}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/payments?page=$page&limit=$limit'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('📥 Get All Payments Status: ${response.statusCode}');
//       debugPrint('📥 Get All Payments Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           // API returns data.payments array
//           final paymentsData = data['data']['payments'] as List;
//           return paymentsData.map((payment) => Payment.fromJson(payment)).toList();
//         }
//       }
//       throw Exception('Failed to fetch payments');
//     } catch (e) {
//       debugPrint('❌ Error fetching payments: $e');
//       throw Exception('Error fetching payments: $e');
//     }
//   }

//   static Future<List<Payment>> getRecentPayments(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/payments/recent'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('📥 Recent Payments Status: ${response.statusCode}');
//       debugPrint('📥 Recent Payments Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           // API returns data.payments array
//           final paymentsData = data['data']['payments'] as List;
//           return paymentsData.map((payment) => Payment.fromJson(payment)).toList();
//         }
//       }
//       throw Exception('Failed to fetch recent payments');
//     } catch (e) {
//       debugPrint('❌ Error fetching recent payments: $e');
//       throw Exception('Error fetching recent payments: $e');
//     }
//   }

//   static Future<Payment> getPaymentById(String token, String paymentId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/payments/$paymentId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('📥 Payment Detail Status: ${response.statusCode}');
//       debugPrint('📥 Payment Detail Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           // Try both possible response structures
//           final paymentData = data['data']['payment'] ?? data['data'];
//           return Payment.fromJson(paymentData);
//         }
//       }
//       throw Exception('Failed to fetch payment details');
//     } catch (e) {
//       debugPrint('❌ Error fetching payment details: $e');
//       throw Exception('Error fetching payment details: $e');
//     }
//   }

//   static Future<PaymentSummary> getPaymentSummary(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/payments/summary'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('📥 Payment Summary Status: ${response.statusCode}');
//       debugPrint('📥 Payment Summary Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           return PaymentSummary.fromJson(data['data']);
//         }
//       }
//       throw Exception('Failed to fetch payment summary');
//     } catch (e) {
//       debugPrint('❌ Error fetching payment summary: $e');
//       throw Exception('Error fetching payment summary: $e');
//     }
//   }



//   static Future<Payment> recordPayment(
//     String token,
//     Map<String, dynamic> paymentData,
//   ) async {
//     final uri = Uri.parse('$_baseUrl/payments');
//     debugPrint('📤 POST $uri');
//     debugPrint('📦 Body: ${jsonEncode(paymentData)}');

//     try {
//       final response = await http.post(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(paymentData),
//       );

//       debugPrint('📥 Status: ${response.statusCode}');
//       debugPrint('📥 Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final decoded = jsonDecode(response.body);
//         if (decoded['success'] == true && decoded['data'] != null) {
//           // Try both possible response structures
//           final paymentData = decoded['data']['payment'] ?? decoded['data'];
//           return Payment.fromJson(paymentData);
//         }
//       }

//       final decoded = jsonDecode(response.body);
//       throw Exception(decoded['message'] ?? 'Unknown server error');
//     } catch (e) {
//       debugPrint('❌ Error recording payment: $e');
//       throw Exception('Error recording payment: $e');
//     }
//   }


//   static Future<Payment> updatePayment(
//     String token,
//     String paymentId,
//     Map<String, dynamic> paymentData,
//   ) async {
//     final uri = Uri.parse('$_baseUrl/payments/$paymentId');
//     debugPrint('📤 PUT $uri');
//     debugPrint('📦 Body: ${jsonEncode(paymentData)}');

//     try {
//       final response = await http.put(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(paymentData),
//       );

//       debugPrint('📥 Status: ${response.statusCode}');
//       debugPrint('📥 Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         if (decoded['success'] == true && decoded['data'] != null) {
//           // Try both possible response structures
//           final paymentData = decoded['data']['payment'] ?? decoded['data'];
//           return Payment.fromJson(paymentData);
//         }
//       }

//       final decoded = jsonDecode(response.body);
//       throw Exception(decoded['message'] ?? 'Unknown server error');
//     } catch (e) {
//       debugPrint('❌ Error updating payment: $e');
//       throw Exception('Error updating payment: $e');
//     }
//   }

//   static Future<PaymentIntent> createPaymentIntent(String token, {
//     required double amount,
//     required String tenantId,
//     required String propertyId,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/payments/create-intent'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'tenantId': tenantId,
//           'propertyId': propertyId,
//         }),
//       );

//       debugPrint('📥 Stripe Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true) {
//           return PaymentIntent.fromJson(data['data']);
//         }
//       }

//       throw Exception(jsonDecode(response.body)['message'] ?? 'Stripe error');
//     } catch (e) {
//       throw Exception('Stripe payment failed: $e');
//     }
//   }

//   static Future<bool> deletePayment(String token, String paymentId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$_baseUrl/payments/$paymentId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('📥 Delete Payment Status: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('❌ Error deleting payment: $e');
//       throw Exception('Error deleting payment: $e');
//     }
//   }
// }