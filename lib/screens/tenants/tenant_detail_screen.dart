import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/tenant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/property_provider.dart';

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  Tenant? _tenant;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _securityDepositController = TextEditingController();
  final TextEditingController _leaseStartDateController = TextEditingController();
  final TextEditingController _leaseEndDateController = TextEditingController();
  final TextEditingController _nextPaymentDueController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _emergencyRelationshipController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  String? _selectedPropertyId;
  String _status = 'paid';
  final _formKey = GlobalKey<FormState>();
  String activeTab = 'Main';

  @override
  void initState() {
    super.initState();
    _fetchTenant();
  }

  Future<void> _fetchTenant() async {
    try {
      final tenant = await Provider.of<TenantProvider>(context, listen: false)
          .fetchTenantById(context, widget.tenantId);
      setState(() {
        _tenant = tenant;
        _firstNameController.text = tenant.firstName;
        _lastNameController.text = tenant.lastName;
        _emailController.text = tenant.email;
        _phoneController.text = tenant.phone;
        _unitController.text = tenant.unit;
        _rentAmountController.text = tenant.rentAmount.toString();
        _securityDepositController.text = tenant.securityDeposit.toString();
        _leaseStartDateController.text = tenant.leaseStartDate.toIso8601String().split('T')[0];
        _leaseEndDateController.text = tenant.leaseEndDate.toIso8601String().split('T')[0];
        _nextPaymentDueController.text = tenant.nextPaymentDue.toIso8601String().split('T')[0];
        _emergencyNameController.text = tenant.emergencyContact.name;
        _emergencyPhoneController.text = tenant.emergencyContact.phone;
        _emergencyRelationshipController.text = tenant.emergencyContact.relationship;
        _notesController.text = tenant.notes ?? '';
        _selectedPropertyId = tenant.property.id;
        _status = tenant.status;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tenant: $error')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _updateTenant() async {
    if (_formKey.currentState!.validate()) {
      final tenantData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'unit': _unitController.text,
        'property': _selectedPropertyId,
        'rentAmount': double.parse(_rentAmountController.text),
        'securityDeposit': double.parse(_securityDepositController.text),
        'leaseStartDate': _leaseStartDateController.text,
        'leaseEndDate': _leaseEndDateController.text,
        'nextPaymentDue': _nextPaymentDueController.text,
        'status': _status,
        'emergencyContact': {
          'name': _emergencyNameController.text,
          'phone': _emergencyPhoneController.text,
          'relationship': _emergencyRelationshipController.text,
        },
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };
      await Provider.of<TenantProvider>(context, listen: false)
          .updateTenant(context, widget.tenantId, tenantData);
      if (Provider.of<TenantProvider>(context, listen: false).state == TenantState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  Provider.of<TenantProvider>(context, listen: false).errorMessage ??
                      'Failed to update tenant')),
        );
      } else {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant updated successfully')),
        );
        _fetchTenant();
      }
    }
  }

  Future<void> _deleteTenant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: const Text('Are you sure you want to delete this tenant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<TenantProvider>(context, listen: false).deleteTenant(context, widget.tenantId);
      if (Provider.of<TenantProvider>(context, listen: false).state == TenantState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  Provider.of<TenantProvider>(context, listen: false).errorMessage ??
                      'Failed to delete tenant')),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant deleted successfully')),
        );
      }
    }
  }

  Future<void> _sendPaymentReminder() async {
    final message = _reminderController.text.isEmpty
        ? 'Dear ${_tenant!.firstName}, your rent payment of \$${_tenant!.rentAmount} is due on ${DateFormat('MMMM d').format(_tenant!.nextPaymentDue)}. Please make payment to avoid late fees. Thank you!'
        : _reminderController.text;
    await Provider.of<TenantProvider>(context, listen: false)
        .sendPaymentReminder(context, widget.tenantId, message);
    if (Provider.of<TenantProvider>(context, listen: false).state == TenantState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                Provider.of<TenantProvider>(context, listen: false).errorMessage ??
                    'Failed to send payment reminder')),
      );
    } else {
      _reminderController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment reminder sent successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(_tenant != null ? '${_tenant!.firstName} ${_tenant!.lastName}' : 'Tenant Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,

        actions: isAdmin && _tenant != null
            ? [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      _updateTenant();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red500),
                  onPressed: _deleteTenant,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenant == null
              ? const Center(child: Text('Failed to load tenant'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isEditing
                      ? Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter first name' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter last name' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedPropertyId,
                                decoration: InputDecoration(
                                  labelText: 'Property',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                items: propertyProvider.properties
                                    .map((property) => DropdownMenuItem(
                                          value: property.id,
                                          child: Text(property.name),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPropertyId = value;
                                  });
                                },
                                validator: (value) => value == null ? 'Please select a property' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _unitController,
                                decoration: InputDecoration(
                                  labelText: 'Unit Number',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter unit number' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _rentAmountController,
                                decoration: InputDecoration(
                                  labelText: 'Rent Amount',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty ? 'Please enter rent amount' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _securityDepositController,
                                decoration: InputDecoration(
                                  labelText: 'Security Deposit',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty ? 'Please enter security deposit' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _leaseStartDateController,
                                decoration: InputDecoration(
                                  labelText: 'Lease Start Date (YYYY-MM-DD)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context, _leaseStartDateController),
                                validator: (value) => value!.isEmpty ? 'Please select lease start date' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _leaseEndDateController,
                                decoration: InputDecoration(
                                  labelText: 'Lease End Date (YYYY-MM-DD)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context, _leaseEndDateController),
                                validator: (value) => value!.isEmpty ? 'Please select lease end date' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nextPaymentDueController,
                                decoration: InputDecoration(
                                  labelText: 'Next Payment Due (YYYY-MM-DD)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context, _nextPaymentDueController),
                                validator: (value) => value!.isEmpty ? 'Please select next payment due date' : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _status,
                                decoration: InputDecoration(
                                  labelText: 'Payment Status',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                items: ['paid', 'overdue', 'pending']
                                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _status = value!;
                                  });
                                },
                                validator: (value) => value == null ? 'Please select a status' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emergencyNameController,
                                decoration: InputDecoration(
                                  labelText: 'Emergency Contact Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter emergency contact name' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emergencyPhoneController,
                                decoration: InputDecoration(
                                  labelText: 'Emergency Contact Phone',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty ? 'Please enter emergency contact phone' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emergencyRelationshipController,
                                decoration: InputDecoration(
                                  labelText: 'Emergency Contact Relationship',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter relationship' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes (Optional)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                  Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color:  Colors.blue[50]
        ,
                    elevation: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),

                        child: Column(
                          children: [
                             CircleAvatar(
                               backgroundColor: Colors.blue[50],
                              radius: 40,
                              child: Text("${_tenant!.firstName[0]} ",style: TextStyle(fontSize: 36)),

                )
                          ]
                        )
                    )),

                                const SizedBox(height: 12),

                                // Name

                                Container(
                                  padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: Colors.blue[50],



                                        borderRadius:  BorderRadius.all(Radius.circular(10))
                                    ),

                                  child: Row(
                                    children: [

                                      _buildTab('Main'),
                                      _buildTab('other'),
                                      _buildTab('emergency_info'),
                                    ],

                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Content
                                if (activeTab == 'Main') _buildmaintab(),
                                if (activeTab == 'other') _buildOthertab(),
                                if (activeTab == 'emergency_info') _buildEmergencytab(),



                                const SizedBox(height: 20),
                                 Divider(color: Colors.blue[50]),
                                _infoRow(label: 'Notes', value: _tenant!.notes ?? 'None'),

                                 Divider(height: 40, color: Colors.blue[50]),

                                // Apartment Info
                                const SizedBox(height: 30),

                                // Actions

                              ],
                            ),

                            if (isAdmin) ...[
                              const SizedBox(height: 16),
                              const Text('Send Payment Reminder',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _reminderController,
                                decoration: InputDecoration(
                                  labelText: 'Reminder Message (Optional)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: AppColors.grey50,
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: _sendPaymentReminder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _unitController.dispose();
    _rentAmountController.dispose();
    _securityDepositController.dispose();
    _leaseStartDateController.dispose();
    _leaseEndDateController.dispose();
    _nextPaymentDueController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    _notesController.dispose();
    _reminderController.dispose();
    super.dispose();
  }
  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTab(String tab) {
    final isActive = activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = tab),
        child: Container(

          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
color: isActive ? Colors.white : Colors.transparent,
            border: Border.all(color: isActive ? Colors.blue : Colors.transparent, width: 2,), borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Text(
            tab[0].toUpperCase() + tab.substring(1),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildmaintab() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildmainRow(Icons.person, 'Full Name', '${_tenant!.firstName} ${_tenant!.lastName}'),

            _buildmainRow(Icons.phone, 'Phone', '${_tenant!.phone}'),

            _buildmainRow(Icons.email, 'Email', '${_tenant!.email}'),

// Assuming "Status" refers to a membership/tenant status (like "Active", "Pending", etc.)
            _buildmainRow(Icons.verified_user, 'Status', '${_tenant!.status}'),

// Assuming "Available" refers to whether the tenant is currently active/available
            _buildmainRow(Icons.check_circle, 'Available', '${_tenant!.isActive}'),

          ],
        ),
      ),
    );
  }

  Widget _buildOthertab() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildmainRow(Icons.house, 'Property', '${_tenant!.property}'),
            const Divider(),

            _buildmainRow(Icons.apartment, 'Unit', '${_tenant!.unit}'),
            const Divider(),

            _buildmainRow(Icons.attach_money, 'Rent Amount', '${_tenant!.rentAmount}'),
            const Divider(),

            _buildmainRow(Icons.savings, 'Security Deposit', '${_tenant!.securityDeposit}'),
            const Divider(),

            _buildmainRow(Icons.date_range, 'Lease Start', '${_tenant!.leaseStartDate}'),
            const Divider(),

            _buildmainRow(Icons.event, 'Lease End', '${_tenant!.leaseEndDate}'),
            const Divider(),

            _buildmainRow(Icons.calendar_today, 'Next Payment Date', '${_tenant!.nextPaymentDue}'),

          ],
        ),
      ),
    );
  }
  Widget _buildEmergencytab() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildmainRow(Icons.person,'Name',  '${_tenant!.emergencyContact}'),
            const Divider(),

          ],
        ),
      ),
    );
  }Widget _buildmainRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
