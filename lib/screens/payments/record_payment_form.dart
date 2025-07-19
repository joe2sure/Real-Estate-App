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

class RecordPaymentForm extends StatefulWidget {
  const RecordPaymentForm({super.key});

  @override
  State<RecordPaymentForm> createState() => _RecordPaymentFormState();
}

class _RecordPaymentFormState extends State<RecordPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _discountController = TextEditingController();
  
  String? _selectedTenantId;
  String? _selectedPropertyId;
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
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      tenantProvider.fetchTenants(authProvider.token!);
      // propertyProvider.fetchProperties(authProvider.token!);
      propertyProvider.fetchPropertiesWithToken(authProvider.token!);
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

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenantId == null || _selectedPropertyId == null) {
        Fluttertoast.showToast(
          msg: 'Please select tenant and property',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      final success = await paymentProvider.recordPayment(
        authProvider.token!,
        tenantId: _selectedTenantId!,
        propertyId: _selectedPropertyId!,
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
          msg: 'Payment recorded successfully',
          backgroundColor: AppColors.secondaryTeal,
          textColor: AppColors.white,
        );
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
          msg: paymentProvider.errorMessage ?? 'Failed to record payment',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Record Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  'Enter payment details below',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tenant Selection
                        const Text(
                          'Tenant',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Consumer<TenantProvider>(
                          builder: (context, tenantProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedTenantId,
                              decoration: InputDecoration(
                                hintText: 'Select tenant',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppColors.grey200),
                                ),
                              ),
                              items: tenantProvider.tenants.map((tenant) {
                                return DropdownMenuItem(
                                  value: tenant.id,
                                  child: Text('${tenant.firstName} ${tenant.lastName}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTenantId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a tenant';
                                }
                                return null;
                              },
                            );
                          },
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
                                  borderSide: BorderSide(color: AppColors.grey200),
                                ),
                              ),
                              items: propertyProvider.properties.map((property) {
                                return DropdownMenuItem(
                                  value: property.id,
                                  child: Text(property.name),
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
                          'Late Fee (Optional)',
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
                          'Discount (Optional)',
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
                          'Notes (Optional)',
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

                        Consumer<PaymentProvider>(
                          builder: (context, paymentProvider, child) {
                            return CustomButton(
                              text: 'Record Payment',
                              onPressed: paymentProvider.state == PaymentState.loading 
                                  ? null 
                                  : _handleSubmit,
                              isGradient: true,
                              isLoading: paymentProvider.state == PaymentState.loading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_card.dart';

// class RecordPaymentForm extends StatelessWidget {
//   const RecordPaymentForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomCard(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Record Payment',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Enter payment details below',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.grey600,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Tenant',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               decoration: InputDecoration(
//                 hintText: 'Select tenant',
//                 suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.grey400),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Amount',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               decoration: InputDecoration(
//                 hintText: '0.00',
//                 prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey400),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Payment Date',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               initialValue: '2025-06-27',
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Payment Method',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               decoration: InputDecoration(
//                 hintText: 'Select payment method',
//                 suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.grey400),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Notes (Optional)',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//                    const SizedBox(height: 8),
//             TextFormField(
//               decoration: InputDecoration(
//                 hintText: 'Add any additional notes',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             CustomButton(
//               text: 'Record Payment',
//               onPressed: () {},
//               isGradient: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }