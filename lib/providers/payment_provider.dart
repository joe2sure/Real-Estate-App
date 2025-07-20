import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
// import '../services/payment_service.dart';

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
  double get totalRevenue => _paymentSummary?.totalRevenue ?? 0.0;
  double get currentMonthRevenue {
    if (_paymentSummary?.monthlyRevenue.isEmpty ?? true) return 0.0;
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyData = _paymentSummary!.monthlyRevenue.firstWhere(
      (revenue) => revenue.month == currentMonth && revenue.year == currentYear,
      orElse: () => MonthlyRevenue(year: currentYear, month: currentMonth, revenue: 0.0, count: 0),
    );
    return monthlyData.revenue;
  }

  int get overduePaymentsCount => _paymentSummary?.outstandingPayments.overdue.length ?? 0;
  double get outstandingAmount {
    if (_paymentSummary?.outstandingPayments.overdue.isEmpty ?? true) return 0.0;
    // This would need to be calculated based on the overdue tenants' rent amounts
    // For now, returning a placeholder calculation
    return overduePaymentsCount * 1200.0; // Average rent amount
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
      _setError(e.toString());
    }
  }

  Future<void> fetchRecentPayments(String token) async {
    _setState(PaymentState.loading);

    try {
      _recentPayments = await PaymentService.getRecentPayments(token);
      _setState(PaymentState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchPaymentSummary(String token) async {
    _setState(PaymentState.loading);

    try {
      _paymentSummary = await PaymentService.getPaymentSummary(token);
      _setState(PaymentState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchPaymentById(String token, String paymentId) async {
    _setState(PaymentState.loading);

    try {
      _selectedPayment = await PaymentService.getPaymentById(token, paymentId);
      _setState(PaymentState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Future<bool> recordPayment(String token, {
  //   required String tenantId,
  //   required String propertyId,
  //   required double amount,
  //   required String method,
  //   required String paymentDate,
  //   String? notes,
  //   double lateFee = 0.0,
  //   double discount = 0.0,
  //   String status = 'completed',
  // }) async {
  //   _setState(PaymentState.loading);

  //   try {
  //     final paymentData = {
  //       'tenant': tenantId,
  //       'property': propertyId,
  //       'amount': amount,
  //       'method': method,
  //       'paymentDate': paymentDate,
  //       'notes': notes,
  //       'lateFee': lateFee,
  //       'discount': discount,
  //       'status': status,
  //     };

  //     final newPayment = await PaymentService.recordPayment(token, paymentData);
  //     _payments.insert(0, newPayment);
  //     _recentPayments.insert(0, newPayment);
      
  //     // Keep only the latest 10 recent payments
  //     if (_recentPayments.length > 10) {
  //       _recentPayments = _recentPayments.take(10).toList();
  //     }

  //     _setState(PaymentState.idle);
  //     return true;
  //   } catch (e) {
  //     _setError(e.toString());
  //     return false;
  //   }
  // }


Future<bool> recordPayment(String token, {
  required String tenantId,
  required String propertyId,
  required double amount,
  required String method,
  required String paymentDate,
  String? notes,
  double lateFee = 0.0,
  double discount = 0.0,
  String status = 'completed',
}) async {
  _setState(PaymentState.loading);

  try {
    final paymentData = {
      'tenant': tenantId,
      'property': propertyId,
      'amount': amount,
      'method': method,
      'paymentDate': paymentDate,
      'notes': notes,
      'lateFee': lateFee,
      'discount': discount,
      'status': status,
    };

    debugPrint('Recording payment with data: $paymentData');
    
    final newPayment = await PaymentService.recordPayment(token, paymentData);
    _payments.insert(0, newPayment);
    _recentPayments.insert(0, newPayment);
    
    if (_recentPayments.length > 10) {
      _recentPayments = _recentPayments.take(10).toList();
    }

    _setState(PaymentState.idle);
    return true;
  } catch (e) {
    debugPrint('Error recording payment: ${e.toString()}');
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
