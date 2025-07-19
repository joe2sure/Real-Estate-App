import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class EditPaymentScreen extends StatefulWidget {
  final String paymentId;

  const EditPaymentScreen({super.key, required this.paymentId});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _discountController = TextEditingController();
  
  String _selectedMethod = 'bank_transfer';
  String _selectedStatus = 'completed';
  DateTime _selectedDate = DateTime.now();

  final List<String> _paymentMethods = [
    'bank_transfer',
    'credit_card',
    'cash',
    'check',
  ];

  final List<String> _paymentStatuses = [
    'completed',
    'pending',
    'failed',
    'overdue',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentData();
    });
  }

  void _loadPaymentData() {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final payment = paymentProvider.selectedPayment;
    
    if (payment != null) {
      _amountController.text = payment.amount.toString();
      _notesController.text = payment.notes ?? '';
      _lateFeeController.text = payment.lateFee.toString();
      _discountController.text = payment.discount.toString();
      _selectedMethod = payment.method;
      _selectedStatus = payment.status;
      _selectedDate = payment.paymentDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _lateFeeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      final success = await paymentProvider.updatePayment(
        authProvider.token!,
        widget.paymentId,
        amount: double.parse(_amountController.text),
        method: _selectedMethod,
        paymentDate: _selectedDate.toIso8601String(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        lateFee: double.tryParse(_lateFeeController.text) ?? 0.0,
        discount: double.tryParse(_discountController.text) ?? 0.0,
        status: _selectedStatus,
      );

      if (success) {
        Fluttertoast.showToast(
          msg: 'Payment updated successfully',
          backgroundColor: AppColors.secondaryTeal,
          textColor: AppColors.white,
        );
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
          msg: paymentProvider.errorMessage ?? 'Failed to update payment',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey800,
        elevation: 0,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.selectedPayment == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Payment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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
                              prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey400),
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
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Payment Date
                          const Text(
                            'Payment Date',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  ),
                                  const Icon(Icons.calendar_today, color: AppColors.grey400),
                                ],
                              ),
                            ),
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
                                child: Text(method.replaceAll('_', ' ').toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMethod = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Status
                          const Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                            items: _paymentStatuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Late Fee
                          const Text(
                            'Late Fee',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lateFeeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Discount
                          const Text(
                            'Discount',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notes
                          const Text(
                            'Notes',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any additional notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          CustomButton(
                            text: 'Update Payment',
                            onPressed: paymentProvider.state == PaymentState.loading 
                                ? null 
                                : _handleUpdate,
                            isGradient: true,
                            isLoading: paymentProvider.state == PaymentState.loading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
