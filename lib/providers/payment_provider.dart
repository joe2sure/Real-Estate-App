import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

enum PaymentState { idle, loading, error }

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  List<Payment> _recentPayments = [];
  PaymentSummary? _paymentSummary;
  Payment? _selectedPayment;
  PaymentState _state = PaymentState.idle;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePayments = true;

  // Getters
  List<Payment> get payments => _payments;
  List<Payment> get recentPayments => _recentPayments;
  PaymentSummary? get paymentSummary => _paymentSummary;
  Payment? get selectedPayment => _selectedPayment;
  PaymentState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get hasMorePayments => _hasMorePayments;
  int get currentPage => _currentPage;

  // Computed properties
  double get totalRevenue {
    if (_paymentSummary == null) return 0.0;
    final revenue = _paymentSummary!.revenue;
    return (revenue['USD'] ?? 0.0) + (revenue['GBP'] ?? 0.0) + (revenue['NGN'] ?? 0.0);
  }

  double get currentMonthRevenue {
    // Calculate from recent payments since summary doesn't include monthly breakdown
    final now = DateTime.now();
    final currentMonthPayments = _recentPayments.where((payment) {
      return payment.paymentDate.year == now.year && 
             payment.paymentDate.month == now.month &&
             payment.status.toLowerCase() == 'completed';
    });
    
    return currentMonthPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  int get overduePaymentsCount => _paymentSummary?.totalPayments ?? 0;
  
  double get outstandingAmount {
    // Calculate pending payments total
    final pendingPayments = _payments.where((p) => 
      p.status.toLowerCase() == 'pending' || p.status.toLowerCase() == 'overdue');
    return pendingPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  void _setState(PaymentState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = PaymentState.error;
    notifyListeners();
  }

  Future<void> fetchPayments(String token, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _payments.clear();
      _hasMorePayments = true;
    }

    if (!_hasMorePayments) return;

    _setState(PaymentState.loading);

    try {
      final newPayments = await PaymentService.getAllPayments(
        token,
        page: _currentPage,
        limit: 10,
      );

      if (newPayments.length < 10) {
        _hasMorePayments = false;
      }

      if (refresh) {
        _payments = newPayments;
      } else {
        _payments.addAll(newPayments);
      }

      _currentPage++;
      _setState(PaymentState.idle);
    } catch (e) {
      debugPrint('Error in fetchPayments: $e');
      _setError(e.toString());
    }
  }

  Future<void> fetchRecentPayments(String token) async {
    _setState(PaymentState.loading);

    try {
      _recentPayments = await PaymentService.getRecentPayments(token);
      _setState(PaymentState.idle);
    } catch (e) {
      debugPrint('Error in fetchRecentPayments: $e');
      _setError(e.toString());
    }
  }

  Future<void> fetchPaymentSummary(String token) async {
    _setState(PaymentState.loading);

    try {
      _paymentSummary = await PaymentService.getPaymentSummary(token);
      _setState(PaymentState.idle);
    } catch (e) {
      debugPrint('Error in fetchPaymentSummary: $e');
      _setError(e.toString());
    }
  }

  Future<void> fetchPaymentById(String token, String paymentId) async {
    _setState(PaymentState.loading);

    try {
      _selectedPayment = await PaymentService.getPaymentById(token, paymentId);
      _setState(PaymentState.idle);
    } catch (e) {
      debugPrint('Error in fetchPaymentById: $e');
      _setError(e.toString());
    }
  }

  Future<bool> recordPayment(String token, Map<String, dynamic> paymentData) async {
    _setState(PaymentState.loading);

    try {
      debugPrint('Recording payment in provider...');
      
      final newPayment = await PaymentService.recordPayment(token, paymentData);
      
      _payments.insert(0, newPayment);
      _recentPayments.insert(0, newPayment);
      
      if (_recentPayments.length > 10) {
        _recentPayments = _recentPayments.take(10).toList();
      }

      _setState(PaymentState.idle);
      debugPrint('Payment recorded successfully in provider');
      return true;
    } catch (e) {
      debugPrint('Error recording payment in provider: ${e.toString()}');
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updatePayment(String token, String paymentId, {
    String? tenantId,
    String? propertyId,
    double? amount,
    String? method,
    String? paymentDate,
    String? notes,
    double? lateFee,
    double? discount,
    String? status,
  }) async {
    _setState(PaymentState.loading);

    try {
      final paymentData = <String, dynamic>{};
      if (tenantId != null) paymentData['tenant'] = tenantId;
      if (propertyId != null) paymentData['property'] = propertyId;
      if (amount != null) paymentData['amount'] = amount;
      if (method != null) paymentData['method'] = method;
      if (paymentDate != null) paymentData['paymentDate'] = paymentDate;
      if (notes != null) paymentData['notes'] = notes;
      if (lateFee != null) paymentData['lateFee'] = lateFee;
      if (discount != null) paymentData['discount'] = discount;
      if (status != null) paymentData['status'] = status;

      final updatedPayment = await PaymentService.updatePayment(token, paymentId, paymentData);
      
      // Update the payment in the lists
      final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex != -1) {
        _payments[paymentIndex] = updatedPayment;
      }

      final recentPaymentIndex = _recentPayments.indexWhere((p) => p.id == paymentId);
      if (recentPaymentIndex != -1) {
        _recentPayments[recentPaymentIndex] = updatedPayment;
      }

      if (_selectedPayment?.id == paymentId) {
        _selectedPayment = updatedPayment;
      }

      _setState(PaymentState.idle);
      return true;
    } catch (e) {
      debugPrint('Error updating payment: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<PaymentIntent?> createPaymentIntent(String token, {
    required double amount,
    required String tenantId,
    required String propertyId,
  }) async {
    _setState(PaymentState.loading);

    try {
      final paymentIntent = await PaymentService.createPaymentIntent(
        token,
        amount: amount,
        tenantId: tenantId,
        propertyId: propertyId,
      );
      _setState(PaymentState.idle);
      return paymentIntent;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> deletePayment(String token, String paymentId) async {
    _setState(PaymentState.loading);

    try {
      final success = await PaymentService.deletePayment(token, paymentId);
      if (success) {
        _payments.removeWhere((p) => p.id == paymentId);
        _recentPayments.removeWhere((p) => p.id == paymentId);
        if (_selectedPayment?.id == paymentId) {
          _selectedPayment = null;
        }
      }
      _setState(PaymentState.idle);
      return success;
    } catch (e) {
      debugPrint('❌ Error deleting payment: $e');
      _setError(e.toString());
      return false;
    }
  }

  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == PaymentState.error) {
      _state = PaymentState.idle;
    }
    notifyListeners();
  }

  List<Payment> getPaymentsByStatus(String status) {
    return _payments.where((payment) => payment.status.toLowerCase() == status.toLowerCase()).toList();
  }

  List<Payment> getPaymentsByTenant(String tenantId) {
    return _payments.where((payment) => payment.tenant.id == tenantId).toList();
  }

  List<Payment> getPaymentsByProperty(String propertyId) {
    return _payments.where((payment) => payment.property.id == propertyId).toList();
  }
}