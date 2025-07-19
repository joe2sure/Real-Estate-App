import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class StripePaymentScreen extends StatefulWidget {
  final double amount;
  final String tenantId;
  final String propertyId;

  const StripePaymentScreen({
    super.key,
    required this.amount,
    required this.tenantId,
    required this.propertyId,
  });

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  void _formatCardNumber(String value) {
    String formatted = value.replaceAll(' ', '');
    if (formatted.length > 16) {
      formatted = formatted.substring(0, 16);
    }
    
    String display = '';
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) {
        display += ' ';
      }
      display += formatted[i];
    }
    
    _cardNumberController.value = TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }

  void _formatExpiry(String value) {
    String formatted = value.replaceAll('/', '');
    if (formatted.length > 4) {
      formatted = formatted.substring(0, 4);
    }
    
    if (formatted.length >= 2) {
      formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
    }
    
    _expiryController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

        // Create payment intent
        final paymentIntent = await paymentProvider.createPaymentIntent(
          authProvider.token!,
          amount: widget.amount,
          tenantId: widget.tenantId,
          propertyId: widget.propertyId,
        );

        if (paymentIntent != null) {
          // In a real implementation, you would use the Stripe SDK here
          // For now, we'll simulate a successful payment
          await Future.delayed(const Duration(seconds: 2));

          // Record the payment as completed
          final success = await paymentProvider.recordPayment(
            authProvider.token!,
            tenantId: widget.tenantId,
            propertyId: widget.propertyId,
            amount: widget.amount,
            method: 'credit_card',
            paymentDate: DateTime.now().toIso8601String(),
            status: 'completed',
            notes: 'Payment processed via Stripe',
          );

          if (success) {
            Fluttertoast.showToast(
              msg: 'Payment successful!',
              backgroundColor: AppColors.secondaryTeal,
              textColor: AppColors.white,
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            throw Exception('Failed to record payment');
          }
        } else {
          throw Exception('Failed to create payment intent');
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Payment failed: ${e.toString()}',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Payment Summary
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: AppColors.secondaryTeal),
                          const SizedBox(width: 8),
                          const Text(
                            'Secure Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to pay:'),
                          Text(
                            _formatCurrency(widget.amount),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card Details
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cardholder Name
                      const Text(
                        'Cardholder Name',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'John Doe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Card Number
                      const Text(
                        'Card Number',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        onChanged: _formatCardNumber,
                        decoration: InputDecoration(
                          hintText: '1234 5678 9012 3456',
                          suffixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.replaceAll(' ', '').length != 16) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Expiry Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expiry Date',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  onChanged: _formatExpiry,
                                  decoration: InputDecoration(
                                    hintText: 'MM/YY',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.grey200),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                      return 'Invalid format';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // CVC
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CVC',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _cvcController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  decoration: InputDecoration(
                                    hintText: '123',
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.grey200),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length != 3) {
                                      return 'Invalid CVC';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Pay ${_formatCurrency(widget.amount)}',
                        onPressed: _isProcessing ? null : _processPayment,
                        isGradient: true,
                        isLoading: _isProcessing,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security Info
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock, color: AppColors.secondaryTeal, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Your payment is secure',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your card details are encrypted and processed securely by Stripe. We never store your card information.',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
