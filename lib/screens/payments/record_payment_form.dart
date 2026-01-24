import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/room_provider.dart';
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
  final _descriptionController = TextEditingController();
  
  String? _selectedTenantId;
  String? _selectedPropertyId;
  String? _selectedRoomId;
  String? _selectedTenantEmail; // NEW: Store tenant email
  String _selectedMethod = 'bank_transfer';
  String _selectedCurrency = 'GBP';
  String _selectedPaymentType = 'full';
  DateTime _selectedPaymentDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

  final List<String> _paymentMethods = ['cash', 'bank_transfer', 'credit_card', 'check'];
  final List<String> _currencies = ['GBP', 'USD', 'NGN'];
  final List<String> _paymentTypes = ['full', 'partial'];

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
      propertyProvider.fetchPropertiesWithToken(authProvider.token!);
    }
  }

  void _loadRoomsForProperty(String propertyId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      roomProvider.fetchRoomsByProperty(authProvider.token!, propertyId);
      setState(() {
        _selectedRoomId = null;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _lateFeeController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPaymentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPaymentDate ? _selectedPaymentDate : _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentDate) {
          _selectedPaymentDate = picked;
        } else {
          _selectedDueDate = picked;
        }
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenantId == null || _selectedPropertyId == null || _selectedRoomId == null) {
        Fluttertoast.showToast(
          msg: 'Please select tenant, property, and room',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      try {
        // Build payment data matching backend expectations
        final paymentData = {
          'tenant': _selectedTenantId!,
          'property': _selectedPropertyId!,
          'room': _selectedRoomId!,
          'amount': double.parse(_amountController.text),
          'currency': _selectedCurrency,
          'method': _selectedMethod,
          'paymentType': _selectedPaymentType,
          'paymentDate': _selectedPaymentDate.toIso8601String(),
          'dueDate': _selectedDueDate.toIso8601String(),
          'lateFee': double.tryParse(_lateFeeController.text) ?? 0.0,
          'discount': double.tryParse(_discountController.text) ?? 0.0,
        };

        // NEW: Add tenant email for invoice
        if (_selectedTenantEmail != null && _selectedTenantEmail!.isNotEmpty) {
          paymentData['tenantEmail'] = _selectedTenantEmail!;
        }

        // NEW: Add description for invoice
        String description = _descriptionController.text.trim();
        if (description.isEmpty) {
          // Auto-generate description if not provided
          final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
          final roomProvider = Provider.of<RoomProvider>(context, listen: false);
          
          final property = propertyProvider.properties.firstWhere(
            (p) => p.id == _selectedPropertyId,
            orElse: () => throw Exception('Property not found'),
          );
          final room = roomProvider.rooms.firstWhere(
            (r) => r.id == _selectedRoomId,
            orElse: () => throw Exception('Room not found'),
          );
          
          description = 'Monthly Rent Payment - Room ${room.roomNumber} - ${property.name}';
        }
        paymentData['description'] = description;

        // Add notes if provided
        if (_notesController.text.isNotEmpty) {
          paymentData['notes'] = _notesController.text;
        }

        debugPrint('📦 Submitting payment data: $paymentData');

        final result = await paymentProvider.recordPayment(
          authProvider.token!,
          paymentData,
        );

        if (result['success']) {
          // NEW: Show success message with invoice status
          final invoiceEmailSent = result['invoiceEmailSent'] ?? false;
          final invoiceNumber = result['invoiceNumber'];
          
          String successMessage = 'Payment recorded successfully';
          if (invoiceEmailSent && invoiceNumber != null) {
            successMessage += '\nInvoice $invoiceNumber sent to tenant';
          } else if (invoiceNumber != null) {
            successMessage += '\nInvoice $invoiceNumber generated (email failed)';
          }
          
          Fluttertoast.showToast(
            msg: successMessage,
            backgroundColor: AppColors.secondaryTeal,
            textColor: AppColors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
            msg: paymentProvider.errorMessage ?? 'Failed to record payment',
            backgroundColor: AppColors.red500,
            textColor: AppColors.white,
          );
        }
      } catch (e) {
        debugPrint('❌ Error in _handleSubmit: ${e.toString()}');
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.gradientBlue.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_card_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Record Payment',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Invoice will be sent to tenant',
                        style: TextStyle(fontSize: 14, color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: AppColors.grey600),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.grey100,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tenant Selection (UPDATED to capture email)
                    _buildSectionLabel('Tenant', required: true),
                    const SizedBox(height: 8),
                    Consumer<TenantProvider>(
                      builder: (context, tenantProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedTenantId,
                            decoration: const InputDecoration(
                              hintText: 'Select tenant',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.person_rounded),
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
                                // NEW: Capture tenant email when selected
                                if (value != null) {
                                  final tenant = tenantProvider.tenants.firstWhere((t) => t.id == value);
                                  _selectedTenantEmail = tenant.email;
                                }
                              });
                            },
                            validator: (value) => value == null ? 'Please select a tenant' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Property Selection
                    _buildSectionLabel('Property', required: true),
                    const SizedBox(height: 8),
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPropertyId,
                            decoration: const InputDecoration(
                              hintText: 'Select property',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.home_rounded),
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
                                if (value != null) {
                                  _loadRoomsForProperty(value);
                                }
                              });
                            },
                            validator: (value) => value == null ? 'Please select a property' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Room Selection
                    _buildSectionLabel('Room', required: true),
                    const SizedBox(height: 8),
                    Consumer<RoomProvider>(
                      builder: (context, roomProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedRoomId,
                            decoration: const InputDecoration(
                              hintText: 'Select room',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.meeting_room_rounded),
                            ),
                            items: roomProvider.rooms.map((room) {
                              return DropdownMenuItem(
                                value: room.id,
                                child: Text('Room ${room.roomNumber}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoomId = value;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a room' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Amount and Currency Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Amount', required: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixIcon: const Icon(Icons.attach_money_rounded),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (double.tryParse(value) == null) return 'Invalid amount';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Currency', required: true),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey200),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCurrency,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: _currencies.map((currency) {
                                    return DropdownMenuItem(value: currency, child: Text(currency));
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedCurrency = value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // NEW: Description field for invoice
                    _buildSectionLabel('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Monthly Rent Payment - January',
                        prefixIcon: const Icon(Icons.description_rounded),
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Type and Method
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Type', required: true),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey200),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedPaymentType,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: _paymentTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedPaymentType = value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Method', required: true),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey200),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedMethod,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: _paymentMethods.map((method) {
                                    return DropdownMenuItem(
                                      value: method,
                                      child: Text(method.replaceAll('_', ' ').toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedMethod = value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Payment Date', required: true),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey50,
                                    border: Border.all(color: AppColors.grey200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_selectedPaymentDate.day}/${_selectedPaymentDate.month}/${_selectedPaymentDate.year}'),
                                      const Icon(Icons.calendar_today_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Due Date', required: true),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey50,
                                    border: Border.all(color: AppColors.grey200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}'),
                                      const Icon(Icons.calendar_today_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Late Fee and Discount
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Late Fee'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lateFeeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixIcon: const Icon(Icons.warning_rounded),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Discount'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixIcon: const Icon(Icons.local_offer_rounded),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.grey200),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    _buildSectionLabel('Notes'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes',
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.grey200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Consumer<PaymentProvider>(
                      builder: (context, paymentProvider, child) {
                        return CustomButton(
                          text: 'Record Payment & Send Invoice',
                          onPressed: paymentProvider.state == PaymentState.loading ? null : _handleSubmit,
                          isGradient: true,
                          isLoading: paymentProvider.state == PaymentState.loading,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.red500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/payment_provider.dart';
// import '../../providers/tenant_provider.dart';
// import '../../providers/property_provider.dart';
// import '../../providers/room_provider.dart';
// import '../../widgets/custom_button.dart';

// class RecordPaymentForm extends StatefulWidget {
//   const RecordPaymentForm({super.key});

//   @override
//   State<RecordPaymentForm> createState() => _RecordPaymentFormState();
// }

// class _RecordPaymentFormState extends State<RecordPaymentForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _notesController = TextEditingController();
//   final _lateFeeController = TextEditingController();
//   final _discountController = TextEditingController();
  
//   String? _selectedTenantId;
//   String? _selectedPropertyId;
//   String? _selectedRoomId;
//   String _selectedMethod = 'bank_transfer';
//   String _selectedCurrency = 'GBP';
//   String _selectedPaymentType = 'full';
//   DateTime _selectedPaymentDate = DateTime.now();
//   DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

//   final List<String> _paymentMethods = ['cash', 'bank_transfer', 'credit_card', 'check'];
//   final List<String> _currencies = ['GBP', 'USD', 'NGN'];
//   final List<String> _paymentTypes = ['full', 'partial'];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   void _loadData() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
//     final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
//     if (authProvider.token != null) {
//       tenantProvider.fetchTenants(authProvider.token!);
//       propertyProvider.fetchPropertiesWithToken(authProvider.token!);
//     }
//   }

//   void _loadRoomsForProperty(String propertyId) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    
//     if (authProvider.token != null) {
//       roomProvider.fetchRoomsByProperty(authProvider.token!, propertyId);
//       setState(() {
//         _selectedRoomId = null;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _notesController.dispose();
//     _lateFeeController.dispose();
//     _discountController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isPaymentDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isPaymentDate ? _selectedPaymentDate : _selectedDueDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isPaymentDate) {
//           _selectedPaymentDate = picked;
//         } else {
//           _selectedDueDate = picked;
//         }
//       });
//     }
//   }

//   void _handleSubmit() async {
//     if (_formKey.currentState!.validate()) {
//       if (_selectedTenantId == null || _selectedPropertyId == null || _selectedRoomId == null) {
//         Fluttertoast.showToast(
//           msg: 'Please select tenant, property, and room',
//           backgroundColor: AppColors.red500,
//           textColor: AppColors.white,
//         );
//         return;
//       }

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

//       try {
//         final paymentData = {
//           'tenant': _selectedTenantId!,
//           'property': _selectedPropertyId!,
//           'room': _selectedRoomId!,
//           'amount': double.parse(_amountController.text),
//           'currency': _selectedCurrency,
//           'method': _selectedMethod,
//           'paymentType': _selectedPaymentType,
//           'paymentDate': _selectedPaymentDate.toIso8601String(),
//           'dueDate': _selectedDueDate.toIso8601String(),
//           'lateFee': double.tryParse(_lateFeeController.text) ?? 0.0,
//           'discount': double.tryParse(_discountController.text) ?? 0.0,
//         };

//         if (_notesController.text.isNotEmpty) {
//           paymentData['notes'] = _notesController.text;
//         }

//         debugPrint('📦 Submitting payment data: $paymentData');

//         final success = await paymentProvider.recordPayment(
//           authProvider.token!,
//           paymentData,
//         );

//         if (success) {
//           Fluttertoast.showToast(
//             msg: 'Payment recorded successfully',
//             backgroundColor: AppColors.secondaryTeal,
//             textColor: AppColors.white,
//           );
//           Navigator.of(context).pop();
//         } else {
//           Fluttertoast.showToast(
//             msg: paymentProvider.errorMessage ?? 'Failed to record payment',
//             backgroundColor: AppColors.red500,
//             textColor: AppColors.white,
//           );
//         }
//       } catch (e) {
//         Fluttertoast.showToast(
//           msg: 'Error: ${e.toString()}',
//           backgroundColor: AppColors.red500,
//           textColor: AppColors.white,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 30,
//             offset: const Offset(0, -10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Modern Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primaryBlue.withOpacity(0.1),
//                   AppColors.gradientBlue.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 topRight: Radius.circular(30),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppColors.primaryBlue, AppColors.gradientBlue],
//                     ),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.add_card_rounded, color: Colors.white, size: 24),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Record Payment',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'Enter payment details below',
//                         style: TextStyle(fontSize: 14, color: AppColors.grey600),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   icon: Icon(Icons.close_rounded, color: AppColors.grey600),
//                   style: IconButton.styleFrom(
//                     backgroundColor: AppColors.grey100,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Tenant Selection
//                     _buildSectionLabel('Tenant', required: true),
//                     const SizedBox(height: 8),
//                     Consumer<TenantProvider>(
//                       builder: (context, tenantProvider, child) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.grey50,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: AppColors.grey200),
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value: _selectedTenantId,
//                             decoration: const InputDecoration(
//                               hintText: 'Select tenant',
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               prefixIcon: Icon(Icons.person_rounded),
//                             ),
//                             items: tenantProvider.tenants.map((tenant) {
//                               return DropdownMenuItem(
//                                 value: tenant.id,
//                                 child: Text('${tenant.firstName} ${tenant.lastName}'),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedTenantId = value;
//                               });
//                             },
//                             validator: (value) => value == null ? 'Please select a tenant' : null,
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Property Selection
//                     _buildSectionLabel('Property', required: true),
//                     const SizedBox(height: 8),
//                     Consumer<PropertyProvider>(
//                       builder: (context, propertyProvider, child) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.grey50,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: AppColors.grey200),
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value: _selectedPropertyId,
//                             decoration: const InputDecoration(
//                               hintText: 'Select property',
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               prefixIcon: Icon(Icons.home_rounded),
//                             ),
//                             items: propertyProvider.properties.map((property) {
//                               return DropdownMenuItem(
//                                 value: property.id,
//                                 child: Text(property.name),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedPropertyId = value;
//                                 if (value != null) {
//                                   _loadRoomsForProperty(value);
//                                 }
//                               });
//                             },
//                             validator: (value) => value == null ? 'Please select a property' : null,
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Room Selection
//                     _buildSectionLabel('Room', required: true),
//                     const SizedBox(height: 8),
//                     Consumer<RoomProvider>(
//                       builder: (context, roomProvider, child) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.grey50,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: AppColors.grey200),
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value: _selectedRoomId,
//                             decoration: const InputDecoration(
//                               hintText: 'Select room',
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               prefixIcon: Icon(Icons.meeting_room_rounded),
//                             ),
//                             items: roomProvider.rooms.map((room) {
//                               return DropdownMenuItem(
//                                 value: room.id,
//                                 child: Text('Room ${room.roomNumber}'),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedRoomId = value;
//                               });
//                             },
//                             validator: (value) => value == null ? 'Please select a room' : null,
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Amount and Currency Row
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Amount', required: true),
//                               const SizedBox(height: 8),
//                               TextFormField(
//                                 controller: _amountController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   hintText: '0.00',
//                                   prefixIcon: const Icon(Icons.attach_money_rounded),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) return 'Required';
//                                   if (double.tryParse(value) == null) return 'Invalid amount';
//                                   return null;
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Currency', required: true),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppColors.grey50,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: AppColors.grey200),
//                                 ),
//                                 child: DropdownButtonFormField<String>(
//                                   value: _selectedCurrency,
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                   ),
//                                   items: _currencies.map((currency) {
//                                     return DropdownMenuItem(value: currency, child: Text(currency));
//                                   }).toList(),
//                                   onChanged: (value) {
//                                     setState(() => _selectedCurrency = value!);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Payment Type and Method
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Type', required: true),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppColors.grey50,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: AppColors.grey200),
//                                 ),
//                                 child: DropdownButtonFormField<String>(
//                                   value: _selectedPaymentType,
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                   ),
//                                   items: _paymentTypes.map((type) {
//                                     return DropdownMenuItem(
//                                       value: type,
//                                       child: Text(type.toUpperCase()),
//                                     );
//                                   }).toList(),
//                                   onChanged: (value) {
//                                     setState(() => _selectedPaymentType = value!);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Method', required: true),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppColors.grey50,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: AppColors.grey200),
//                                 ),
//                                 child: DropdownButtonFormField<String>(
//                                   value: _selectedMethod,
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                   ),
//                                   items: _paymentMethods.map((method) {
//                                     return DropdownMenuItem(
//                                       value: method,
//                                       child: Text(method.replaceAll('_', ' ').toUpperCase()),
//                                     );
//                                   }).toList(),
//                                   onChanged: (value) {
//                                     setState(() => _selectedMethod = value!);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Dates
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Payment Date', required: true),
//                               const SizedBox(height: 8),
//                               InkWell(
//                                 onTap: () => _selectDate(context, true),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.grey50,
//                                     border: Border.all(color: AppColors.grey200),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text('${_selectedPaymentDate.day}/${_selectedPaymentDate.month}/${_selectedPaymentDate.year}'),
//                                       const Icon(Icons.calendar_today_rounded, size: 20),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Due Date', required: true),
//                               const SizedBox(height: 8),
//                               InkWell(
//                                 onTap: () => _selectDate(context, false),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.grey50,
//                                     border: Border.all(color: AppColors.grey200),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text('${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}'),
//                                       const Icon(Icons.calendar_today_rounded, size: 20),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Late Fee and Discount
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Late Fee'),
//                               const SizedBox(height: 8),
//                               TextFormField(
//                                 controller: _lateFeeController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   hintText: '0.00',
//                                   prefixIcon: const Icon(Icons.warning_rounded),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildSectionLabel('Discount'),
//                               const SizedBox(height: 8),
//                               TextFormField(
//                                 controller: _discountController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   hintText: '0.00',
//                                   prefixIcon: const Icon(Icons.local_offer_rounded),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: AppColors.grey200),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Notes
//                     _buildSectionLabel('Notes'),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _notesController,
//                       maxLines: 3,
//                       decoration: InputDecoration(
//                         hintText: 'Add any additional notes',
//                         filled: true,
//                         fillColor: AppColors.grey50,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.grey200),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: AppColors.grey200),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Submit Button
//                     Consumer<PaymentProvider>(
//                       builder: (context, paymentProvider, child) {
//                         return CustomButton(
//                           text: 'Record Payment',
//                           onPressed: paymentProvider.state == PaymentState.loading ? null : _handleSubmit,
//                           isGradient: true,
//                           isLoading: paymentProvider.state == PaymentState.loading,
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionLabel(String label, {bool required = false}) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//         if (required) ...[
//           const SizedBox(width: 4),
//           Text(
//             '*',
//             style: TextStyle(
//               color: AppColors.red500,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }