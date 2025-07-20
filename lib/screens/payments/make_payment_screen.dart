import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import 'stripe_payment_screen.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedPropertyId;
  String _selectedMethod = 'credit_card';

  final List<String> _paymentMethods = [
    'credit_card',
    'bank_transfer',
    'cash',
    'check',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);

    // if (authProvider.token != null) {
    //   propertyProvider.fetchProperties(authProvider.token!);
    // }
    if (authProvider.token != null) {
      propertyProvider.fetchPropertiesWithToken(authProvider.token!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPropertyId == null) {
        Fluttertoast.showToast(
          msg: 'Please select a property',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      if (_selectedMethod == 'credit_card') {
        // Navigate to Stripe payment screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StripePaymentScreen(
              amount: amount,
              tenantId: authProvider.currentUser!.id,
              propertyId: _selectedPropertyId!,
            ),
          ),
        );
      } else {
        // Handle other payment methods
        final paymentProvider =
            Provider.of<PaymentProvider>(context, listen: false);

        final success = await paymentProvider.recordPayment(
          authProvider.token!,
          tenantId: authProvider.currentUser!.id,
          propertyId: _selectedPropertyId!,
          amount: amount,
          method: _selectedMethod,
          paymentDate: DateTime.now().toIso8601String(),
          status: 'pending', // Non-card payments start as pending
        );

        if (success) {
          Fluttertoast.showToast(
            msg: 'Payment submitted successfully',
            backgroundColor: AppColors.secondaryTeal,
            textColor: AppColors.white,
          );
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
            msg: paymentProvider.errorMessage ?? 'Failed to submit payment',
            backgroundColor: AppColors.red500,
            textColor: AppColors.white,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
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
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Property Selection
                      const Text(
                        'Property',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Consumer<PropertyProvider>(
                        builder: (context, propertyProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedPropertyId,
                            decoration: InputDecoration(
                              hintText: 'Select property',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: AppColors.grey200),
                              ),
                            ),
                            items: propertyProvider.properties.map((property) {
                              return DropdownMenuItem(
                                value: property.id,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(property.name),
                                    Text(
                                      property.address,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPropertyId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a property';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      const Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money,
                              color: AppColors.grey400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Method
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Row(
                              children: [
                                Icon(
                                  _getPaymentMethodIcon(method),
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(method.replaceAll('_', ' ').toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMethod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      if (_selectedMethod == 'credit_card') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.security,
                                  color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Secure payment powered by Stripe',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          return CustomButton(
                            text: _selectedMethod == 'credit_card'
                                ? 'Continue to Payment'
                                : 'Submit Payment',
                            onPressed:
                                paymentProvider.state == PaymentState.loading
                                    ? null
                                    : _handlePayment,
                            isGradient: true,
                            isLoading:
                                paymentProvider.state == PaymentState.loading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Methods Info
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Methods',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodInfo(
                        Icons.credit_card,
                        'Credit Card',
                        'Instant payment via Stripe',
                      ),
                      _buildPaymentMethodInfo(
                        Icons.account_balance,
                        'Bank Transfer',
                        'Direct bank transfer (2-3 business days)',
                      ),
                      _buildPaymentMethodInfo(
                        Icons.money,
                        'Cash',
                        'Cash payment at property office',
                      ),
                      _buildPaymentMethodInfo(
                        Icons.receipt,
                        'Check',
                        'Personal or cashier\'s check',
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

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      case 'check':
        return Icons.receipt;
      default:
        return Icons.payment;
    }
  }

  Widget _buildPaymentMethodInfo(
      IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}