import 'package:Peeman/models/room_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/tenant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/custom_toaster.dart';

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> with SingleTickerProviderStateMixin {
  Tenant? _tenant;
  bool _isLoading = true;
  bool _isEditing = false;
  String _activeTab = 'overview';
  
  late TabController _tabController;
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
  String? _selectedRoomId;
  String _status = 'paid';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTenant();
  }

  Future<void> _fetchTenant() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
        _leaseStartDateController.text =
            tenant.leaseStartDate.toIso8601String().split('T')[0];
        _leaseEndDateController.text =
            tenant.leaseEndDate.toIso8601String().split('T')[0];
        _nextPaymentDueController.text =
            tenant.nextPaymentDue.toIso8601String().split('T')[0];
        _emergencyNameController.text = tenant.emergencyContact.name;
        _emergencyPhoneController.text = tenant.emergencyContact.phone;
        _emergencyRelationshipController.text =
            tenant.emergencyContact.relationship;
        _notesController.text = tenant.notes ?? '';
        _selectedPropertyId = tenant.property.id;
        _selectedRoomId = tenant.room;
        _status = tenant.status;
      });

      if (_selectedPropertyId != null) {
        try {
          await Provider.of<RoomProvider>(context, listen: false)
              .fetchRoomsByProperty(authProvider.token!, _selectedPropertyId!);

          final roomProvider = Provider.of<RoomProvider>(context, listen: false);
          if (_selectedRoomId != null) {
            final roomExists = roomProvider.rooms.any((room) => room.id == _selectedRoomId);
            if (!roomExists) {
              setState(() {
                _selectedRoomId = null;
              });
            }
          }
        } catch (e) {
          debugPrint('Error fetching rooms for property: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      CustomToast.show(context, 'Failed to load tenant: $error', isSuccess: false);
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
        CustomToast.show(
            context,
            Provider.of<TenantProvider>(context, listen: false).errorMessage ??
                'Failed to update tenant',
            isSuccess: false);
      } else {
        setState(() {
          _isEditing = false;
        });
        CustomToast.show(context, 'Tenant updated successfully');
        _fetchTenant();
      }
    }
  }

  Future<void> _deleteTenant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      await Provider.of<TenantProvider>(context, listen: false)
          .deleteTenant(context, widget.tenantId);
      if (Provider.of<TenantProvider>(context, listen: false).state == TenantState.error) {
        CustomToast.show(
            context,
            Provider.of<TenantProvider>(context, listen: false).errorMessage ??
                'Failed to delete tenant',
            isSuccess: false);
      } else {
        Navigator.pop(context);
        CustomToast.show(context, 'Tenant deleted successfully');
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
      CustomToast.show(
          context,
          Provider.of<TenantProvider>(context, listen: false).errorMessage ??
              'Failed to send payment reminder',
          isSuccess: false);
    } else {
      _reminderController.clear();
      CustomToast.show(context, 'Payment reminder sent successfully');
    }
  }

  Future<void> _assignTenantToRoom() async {
    if (_selectedRoomId == null || _selectedRoomId!.isEmpty) {
      CustomToast.show(context, 'Please select a room', isSuccess: false);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    try {
      await roomProvider.assignTenantToRoom(
          authProvider.token!, _selectedRoomId!, widget.tenantId);

      if (roomProvider.state != RoomState.error && roomProvider.errorMessage == null) {
        CustomToast.show(context, 'Tenant assigned to room successfully');
        await _fetchTenant();
      } else {
        CustomToast.show(context,
            roomProvider.errorMessage ?? 'Failed to assign tenant to room',
            isSuccess: false);
      }
    } catch (e) {
      CustomToast.show(context, 'Failed to assign tenant: $e', isSuccess: false);
    }
  }

  Future<void> _removeTenantFromRoom() async {
    if (_tenant?.room == null || _tenant!.room!.isEmpty) {
      CustomToast.show(context, 'Tenant is not assigned to any room', isSuccess: false);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Tenant from Room'),
        content: const Text('Are you sure you want to remove this tenant from their room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);

      try {
        await roomProvider.removeTenantFromRoom(authProvider.token!, _tenant!.room!);

        if (roomProvider.state != RoomState.error && roomProvider.errorMessage == null) {
          CustomToast.show(context, 'Tenant removed from room successfully');
          await _fetchTenant();
        } else {
          CustomToast.show(context,
              roomProvider.errorMessage ?? 'Failed to remove tenant from room',
              isSuccess: false);
        }
      } catch (e) {
        CustomToast.show(context, 'Failed to remove tenant: $e', isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenant == null
              ? const Center(child: Text('Failed to load tenant'))
              : Stack(
                  children: [
                    // Gradient Header Background
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.gradientBlue,
                            AppColors.primaryBlue.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    
                    // Content
                    SafeArea(
                      child: Column(
                        children: [
                          // Custom AppBar
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                if (isAdmin)
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            _isEditing ? Icons.save : Icons.edit,
                                            color: Colors.white,
                                          ),
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
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.red500.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.white),
                                          onPressed: _deleteTenant,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          
                          // Profile Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${_tenant!.firstName[0]}${_tenant!.lastName[0]}",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Name
                                  Text(
                                    '${_tenant!.firstName} ${_tenant!.lastName}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _tenant!.status == 'paid'
                                          ? AppColors.green100
                                          : _tenant!.status == 'overdue'
                                              ? AppColors.red100
                                              : AppColors.amber100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _tenant!.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _tenant!.status == 'paid'
                                            ? AppColors.green500
                                            : _tenant!.status == 'overdue'
                                                ? AppColors.red500
                                                : AppColors.amber500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Quick Info
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildQuickInfo(Icons.home, _tenant!.property.name),
                                      _buildQuickInfo(Icons.apartment, _tenant!.unit),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Tab Bar
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.grey600,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              tabs: const [
                                Tab(text: 'Overview'),
                                Tab(text: 'Details'),
                                Tab(text: 'Emergency'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tab Content
                          Expanded(
                            child: _isEditing
                                ? _buildEditForm(propertyProvider, roomProvider, authProvider)
                                : TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildOverviewTab(),
                                      _buildDetailsTab(),
                                      _buildEmergencyTab(),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow(Icons.email, 'Email', _tenant!.email),
              const Divider(height: 24),
              _buildInfoRow(Icons.phone, 'Phone', _tenant!.phone),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Financial Information',
            icon: Icons.attach_money,
            children: [
              _buildInfoRow(Icons.payment, 'Rent Amount', '\${_tenant!.rentAmount}'),
              const Divider(height: 24),
              _buildInfoRow(Icons.account_balance_wallet, 'Security Deposit', '\${_tenant!.securityDeposit}'),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.calendar_today, 
                'Next Payment Due', 
                DateFormat('MMM dd, yyyy').format(_tenant!.nextPaymentDue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_tenant!.notes != null && _tenant!.notes!.isNotEmpty)
            _buildSectionCard(
              title: 'Notes',
              icon: Icons.note,
              children: [
                Text(
                  _tenant!.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Property Details',
            icon: Icons.business,
            children: [
              _buildInfoRow(Icons.location_city, 'Property', _tenant!.property.name),
              const Divider(height: 24),
              _buildInfoRow(Icons.meeting_room, 'Unit', _tenant!.unit),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Lease Information',
            icon: Icons.description,
            children: [
              _buildInfoRow(
                Icons.event_available, 
                'Lease Start', 
                DateFormat('MMM dd, yyyy').format(_tenant!.leaseStartDate),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.event_busy, 
                'Lease End', 
                DateFormat('MMM dd, yyyy').format(_tenant!.leaseEndDate),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.verified, 
                'Status', 
                _tenant!.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
          
          if (isAdmin) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.meeting_room, color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Room Assignment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedPropertyId,
                    decoration: InputDecoration(
                      labelText: 'Property',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                    items: propertyProvider.properties
                        .map((property) => DropdownMenuItem(
                              value: property.id,
                              child: Text(property.name),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedPropertyId = value;
                        _selectedRoomId = null;
                      });
                      if (value != null) {
                        await Provider.of<RoomProvider>(context, listen: false)
                            .fetchRoomsByProperty(authProvider.token!, value);

                        if (_tenant?.room != null) {
                          final roomExists = roomProvider.rooms.any((room) => room.id == _tenant!.room);
                          if (roomExists) {
                            setState(() {
                              _selectedRoomId = _tenant!.room;
                            });
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    value: () {
                      if (_selectedRoomId != null) {
                        final roomExists = roomProvider.rooms.any(
                            (room) => (room.isAvailable || room.id == _tenant?.room) && room.id == _selectedRoomId);
                        return roomExists ? _selectedRoomId : null;
                      }
                      return null;
                    }(),
                    decoration: InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                    items: () {
                      final Map<String, Room> uniqueRooms = {};
                      for (var room in roomProvider.rooms) {
                        if (room.isAvailable || room.id == _tenant?.room) {
                          uniqueRooms[room.id] = room;
                        }
                      }
                      return uniqueRooms.values
                          .map((room) => DropdownMenuItem(
                                value: room.id,
                                child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
                              ))
                          .toList();
                    }(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRoomId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _assignTenantToRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Assign Room', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _removeTenantFromRoom,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.red500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Remove', style: TextStyle(color: AppColors.red500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.amber100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications_active, color: AppColors.amber500, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Send Payment Reminder',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _reminderController,
                    decoration: InputDecoration(
                      labelText: 'Custom Message (Optional)',
                      hintText: 'Leave empty for default message',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.amber500, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _sendPaymentReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Emergency Contact',
            icon: Icons.emergency,
            children: [
              _buildInfoRow(Icons.person, 'Name', _tenant!.emergencyContact.name),
              const Divider(height: 24),
              _buildInfoRow(Icons.phone, 'Phone', _tenant!.emergencyContact.phone),
              const Divider(height: 24),
              _buildInfoRow(Icons.people, 'Relationship', _tenant!.emergencyContact.relationship),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(PropertyProvider propertyProvider, RoomProvider roomProvider, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection('Personal Information', [
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Property & Unit', [
              DropdownButtonFormField<String>(
                value: _selectedPropertyId,
                decoration: _inputDecoration('Property', Icons.business),
                items: propertyProvider.properties
                    .map((property) => DropdownMenuItem(value: property.id, child: Text(property.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyId = value;
                    _selectedRoomId = null;
                    if (value != null) {
                      Provider.of<RoomProvider>(context, listen: false)
                          .fetchRoomsByProperty(authProvider.token!, value);
                    }
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRoomId,
                decoration: _inputDecoration('Room', Icons.meeting_room),
                items: () {
                  final Map<String, Room> uniqueRooms = {};
                  for (var room in roomProvider.rooms) {
                    if (room.isAvailable || room.id == _tenant?.room) {
                      uniqueRooms[room.id] = room;
                    }
                  }
                  return uniqueRooms.values
                      .map((room) => DropdownMenuItem(
                            value: room.id,
                            child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
                          ))
                      .toList();
                }(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(_unitController, 'Unit Number', Icons.apartment),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Financial', [
              _buildTextField(_rentAmountController, 'Rent Amount', Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_securityDepositController, 'Security Deposit', Icons.account_balance_wallet, keyboardType: TextInputType.number),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Lease Dates', [
              _buildDateField(_leaseStartDateController, 'Lease Start Date', Icons.event_available),
              const SizedBox(height: 12),
              _buildDateField(_leaseEndDateController, 'Lease End Date', Icons.event_busy),
              const SizedBox(height: 12),
              _buildDateField(_nextPaymentDueController, 'Next Payment Due', Icons.calendar_today),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Status', [
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _inputDecoration('Payment Status', Icons.payment),
                items: ['paid', 'overdue', 'pending']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Emergency Contact', [
              _buildTextField(_emergencyNameController, 'Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_emergencyPhoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_emergencyRelationshipController, 'Relationship', Icons.people),
            ]),
            
            const SizedBox(height: 20),
            
            _buildFormSection('Notes', [
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Notes (Optional)', Icons.note),
                maxLines: 4,
              ),
            ]),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

Widget _buildDateField(
  TextEditingController controller,
  String label,
  IconData icon,
) {
  return TextFormField(
    controller: controller,
    decoration: _inputDecoration(label, icon),
    readOnly: true,
    onTap: () => _selectDate(context, controller),
    validator: (value) => value!.isEmpty ? 'Required' : null,
  );
}

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: AppColors.grey50,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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

}



// import 'package:Peeman/models/room_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../models/tenant.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/tenant_provider.dart';
// import '../../providers/property_provider.dart';
// import '../../providers/room_provider.dart';
// import '../../widgets/custom_toaster.dart';

// class TenantDetailScreen extends StatefulWidget {
//   final String tenantId;

//   const TenantDetailScreen({super.key, required this.tenantId});

//   @override
//   State<TenantDetailScreen> createState() => _TenantDetailScreenState();
// }

// class _TenantDetailScreenState extends State<TenantDetailScreen> {
//   Tenant? _tenant;
//   bool _isLoading = true;
//   bool _isEditing = false;
//   String _activeTab = 'Main';

//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _unitController = TextEditingController();
//   final TextEditingController _rentAmountController = TextEditingController();
//   final TextEditingController _securityDepositController =
//       TextEditingController();
//   final TextEditingController _leaseStartDateController =
//       TextEditingController();
//   final TextEditingController _leaseEndDateController = TextEditingController();
//   final TextEditingController _nextPaymentDueController =
//       TextEditingController();
//   final TextEditingController _emergencyNameController =
//       TextEditingController();
//   final TextEditingController _emergencyPhoneController =
//       TextEditingController();
//   final TextEditingController _emergencyRelationshipController =
//       TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _reminderController = TextEditingController();
//   String? _selectedPropertyId;
//   String? _selectedRoomId;
//   String _status = 'paid';
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _fetchTenant();
//   }

//   Future<void> _fetchTenant() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final tenant = await Provider.of<TenantProvider>(context, listen: false)
//           .fetchTenantById(context, widget.tenantId);

//       setState(() {
//         _tenant = tenant;
//         _firstNameController.text = tenant.firstName;
//         _lastNameController.text = tenant.lastName;
//         _emailController.text = tenant.email;
//         _phoneController.text = tenant.phone;
//         _unitController.text = tenant.unit;
//         _rentAmountController.text = tenant.rentAmount.toString();
//         _securityDepositController.text = tenant.securityDeposit.toString();
//         _leaseStartDateController.text =
//             tenant.leaseStartDate.toIso8601String().split('T')[0];
//         _leaseEndDateController.text =
//             tenant.leaseEndDate.toIso8601String().split('T')[0];
//         _nextPaymentDueController.text =
//             tenant.nextPaymentDue.toIso8601String().split('T')[0];
//         _emergencyNameController.text = tenant.emergencyContact.name;
//         _emergencyPhoneController.text = tenant.emergencyContact.phone;
//         _emergencyRelationshipController.text =
//             tenant.emergencyContact.relationship;
//         _notesController.text = tenant.notes ?? '';
//         _selectedPropertyId = tenant.property.id;
//         _selectedRoomId = tenant.room; // SET THIS - it's the room ID string
//         _status = tenant.status;
//       });

//       // Fetch rooms for the tenant's property
//       if (_selectedPropertyId != null) {
//         try {
//           await Provider.of<RoomProvider>(context, listen: false)
//               .fetchRoomsByProperty(authProvider.token!, _selectedPropertyId!);

//           // After fetching rooms, verify the selected room ID exists in the list
//           final roomProvider =
//               Provider.of<RoomProvider>(context, listen: false);
//           if (_selectedRoomId != null) {
//             final roomExists =
//                 roomProvider.rooms.any((room) => room.id == _selectedRoomId);
//             if (!roomExists) {
//               // If the selected room doesn't exist in the list, clear it
//               debugPrint(
//                   'Warning: Selected room $_selectedRoomId not found in fetched rooms');
//               setState(() {
//                 _selectedRoomId = null;
//               });
//             }
//           }
//         } catch (e) {
//           debugPrint('Error fetching rooms for property: $e');
//           // Don't fail the entire fetch if rooms can't be loaded
//         }
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//       });
//       CustomToast.show(context, 'Failed to load tenant: $error',
//           isSuccess: false);
//     }
//   }

//   Future<void> _selectDate(
//       BuildContext context, TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         controller.text = picked.toIso8601String().split('T')[0];
//       });
//     }
//   }

//   Future<void> _updateTenant() async {
//     if (_formKey.currentState!.validate()) {
//       final tenantData = {
//         'firstName': _firstNameController.text,
//         'lastName': _lastNameController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//         'unit': _unitController.text,
//         'property': _selectedPropertyId,
//         'rentAmount': double.parse(_rentAmountController.text),
//         'securityDeposit': double.parse(_securityDepositController.text),
//         'leaseStartDate': _leaseStartDateController.text,
//         'leaseEndDate': _leaseEndDateController.text,
//         'nextPaymentDue': _nextPaymentDueController.text,
//         'status': _status,
//         'emergencyContact': {
//           'name': _emergencyNameController.text,
//           'phone': _emergencyPhoneController.text,
//           'relationship': _emergencyRelationshipController.text,
//         },
//         'notes': _notesController.text.isEmpty ? null : _notesController.text,
//       };
//       await Provider.of<TenantProvider>(context, listen: false)
//           .updateTenant(context, widget.tenantId, tenantData);
//       if (Provider.of<TenantProvider>(context, listen: false).state ==
//           TenantState.error) {
//         CustomToast.show(
//             context,
//             Provider.of<TenantProvider>(context, listen: false).errorMessage ??
//                 'Failed to update tenant',
//             isSuccess: false);
//       } else {
//         setState(() {
//           _isEditing = false;
//         });
//         CustomToast.show(context, 'Tenant updated successfully');
//         _fetchTenant();
//       }
//     }
//   }

//   Future<void> _deleteTenant() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Tenant'),
//         content: const Text('Are you sure you want to delete this tenant?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child:
//                 const Text('Delete', style: TextStyle(color: AppColors.red500)),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await Provider.of<TenantProvider>(context, listen: false)
//           .deleteTenant(context, widget.tenantId);
//       if (Provider.of<TenantProvider>(context, listen: false).state ==
//           TenantState.error) {
//         CustomToast.show(
//             context,
//             Provider.of<TenantProvider>(context, listen: false).errorMessage ??
//                 'Failed to delete tenant',
//             isSuccess: false);
//       } else {
//         Navigator.pop(context);
//         CustomToast.show(context, 'Tenant deleted successfully');
//       }
//     }
//   }

//   Future<void> _sendPaymentReminder() async {
//     final message = _reminderController.text.isEmpty
//         ? 'Dear ${_tenant!.firstName}, your rent payment of \$${_tenant!.rentAmount} is due on ${DateFormat('MMMM d').format(_tenant!.nextPaymentDue)}. Please make payment to avoid late fees. Thank you!'
//         : _reminderController.text;
//     await Provider.of<TenantProvider>(context, listen: false)
//         .sendPaymentReminder(context, widget.tenantId, message);
//     if (Provider.of<TenantProvider>(context, listen: false).state ==
//         TenantState.error) {
//       CustomToast.show(
//           context,
//           Provider.of<TenantProvider>(context, listen: false).errorMessage ??
//               'Failed to send payment reminder',
//           isSuccess: false);
//     } else {
//       _reminderController.clear();
//       CustomToast.show(context, 'Payment reminder sent successfully');
//     }
//   }

//   Future<void> _assignTenantToRoom() async {
//     if (_selectedRoomId == null || _selectedRoomId!.isEmpty) {
//       CustomToast.show(context, 'Please select a room', isSuccess: false);
//       return;
//     }

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final roomProvider = Provider.of<RoomProvider>(context, listen: false);

//     try {
//       // Clear any previous error
//       // roomProvider._errorMessage = null;

//       await roomProvider.assignTenantToRoom(
//           authProvider.token!, _selectedRoomId!, widget.tenantId);

//       // Check if operation was successful
//       if (roomProvider.state != RoomState.error &&
//           roomProvider.errorMessage == null) {
//         CustomToast.show(context, 'Tenant assigned to room successfully');
//         await _fetchTenant(); // Refresh tenant data
//       } else {
//         CustomToast.show(context,
//             roomProvider.errorMessage ?? 'Failed to assign tenant to room',
//             isSuccess: false);
//       }
//     } catch (e) {
//       CustomToast.show(context, 'Failed to assign tenant: $e',
//           isSuccess: false);
//     }
//   }

//   Future<void> _removeTenantFromRoom() async {
//     // Check if tenant has a room assigned
//     if (_tenant?.room == null || _tenant!.room!.isEmpty) {
//       CustomToast.show(context, 'Tenant is not assigned to any room',
//           isSuccess: false);
//       return;
//     }

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Remove Tenant from Room'),
//         content: const Text(
//             'Are you sure you want to remove this tenant from their room?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child:
//                 const Text('Remove', style: TextStyle(color: AppColors.red500)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final roomProvider = Provider.of<RoomProvider>(context, listen: false);

//       try {
//         // Clear any previous error
//         // roomProvider._errorMessage = null;

//         await roomProvider.removeTenantFromRoom(
//             authProvider.token!, _tenant!.room!);

//         // Check if operation was successful
//         if (roomProvider.state != RoomState.error &&
//             roomProvider.errorMessage == null) {
//           CustomToast.show(context, 'Tenant removed from room successfully');
//           await _fetchTenant(); // Refresh tenant data
//         } else {
//           CustomToast.show(context,
//               roomProvider.errorMessage ?? 'Failed to remove tenant from room',
//               isSuccess: false);
//         }
//       } catch (e) {
//         CustomToast.show(context, 'Failed to remove tenant: $e',
//             isSuccess: false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final propertyProvider = Provider.of<PropertyProvider>(context);
//     final roomProvider = Provider.of<RoomProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Text(
//           _tenant != null
//               ? '${_tenant!.firstName} ${_tenant!.lastName}'
//               : 'Tenant Details',
//           style: const TextStyle(color: Colors.black),
//         ),
//         centerTitle: true,
//         actions: isAdmin && _tenant != null
//             ? [
//                 IconButton(
//                   icon: Icon(_isEditing ? Icons.save : Icons.edit),
//                   onPressed: () {
//                     if (_isEditing) {
//                       _updateTenant();
//                     } else {
//                       setState(() {
//                         _isEditing = true;
//                       });
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: AppColors.red500),
//                   onPressed: _deleteTenant,
//                 ),
//               ]
//             : null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _tenant == null
//               ? const Center(child: Text('Failed to load tenant'))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: _isEditing
//                       ? Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               TextFormField(
//                                 controller: _firstNameController,
//                                 decoration: InputDecoration(
//                                   labelText: 'First Name',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter first name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _lastNameController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Last Name',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter last name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _emailController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Email',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 keyboardType: TextInputType.emailAddress,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter email'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _phoneController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Phone Number',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 keyboardType: TextInputType.phone,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter phone number'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedPropertyId,
//                                 decoration: InputDecoration(
//                                   labelText: 'Property',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 items: propertyProvider.properties
//                                     .map((property) => DropdownMenuItem(
//                                           value: property.id,
//                                           child: Text(property.name),
//                                         ))
//                                     .toList(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedPropertyId = value;
//                                     _selectedRoomId = null;
//                                     if (value != null) {
//                                       Provider.of<RoomProvider>(context,
//                                               listen: false)
//                                           .fetchRoomsByProperty(
//                                               authProvider.token!, value);
//                                     }
//                                   });
//                                 },
//                                 validator: (value) => value == null
//                                     ? 'Please select a property'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               DropdownButtonFormField<String>(
//                                 value: _selectedRoomId,
//                                 decoration: InputDecoration(
//                                   labelText: 'Room',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 items: () {
//                                   // Create a map to ensure unique room IDs
//                                   final Map<String, Room> uniqueRooms = {};
//                                   for (var room in roomProvider.rooms) {
//                                     if (room.isAvailable ||
//                                         room.id == _tenant?.room) {
//                                       uniqueRooms[room.id] = room;
//                                     }
//                                   }
//                                   return uniqueRooms.values
//                                       .map((room) => DropdownMenuItem(
//                                             value: room.id,
//                                             child: Text(
//                                                 'Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
//                                           ))
//                                       .toList();
//                                 }(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedRoomId = value;
//                                   });
//                                 },
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _unitController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Unit Number',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter unit number'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _rentAmountController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Rent Amount',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter rent amount'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _securityDepositController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Security Deposit',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter security deposit'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _leaseStartDateController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Lease Start Date (YYYY-MM-DD)',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 readOnly: true,
//                                 onTap: () => _selectDate(
//                                     context, _leaseStartDateController),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please select lease start date'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _leaseEndDateController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Lease End Date (YYYY-MM-DD)',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 readOnly: true,
//                                 onTap: () => _selectDate(
//                                     context, _leaseEndDateController),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please select lease end date'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _nextPaymentDueController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Next Payment Due (YYYY-MM-DD)',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 readOnly: true,
//                                 onTap: () => _selectDate(
//                                     context, _nextPaymentDueController),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please select next payment due date'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               DropdownButtonFormField<String>(
//                                 value: _status,
//                                 decoration: InputDecoration(
//                                   labelText: 'Payment Status',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 items: ['paid', 'overdue', 'pending']
//                                     .map((status) => DropdownMenuItem(
//                                         value: status, child: Text(status)))
//                                     .toList(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _status = value!;
//                                   });
//                                 },
//                                 validator: (value) => value == null
//                                     ? 'Please select a status'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _emergencyNameController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Emergency Contact Name',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter emergency contact name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _emergencyPhoneController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Emergency Contact Phone',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 keyboardType: TextInputType.phone,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter emergency contact phone'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _emergencyRelationshipController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Emergency Contact Relationship',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter relationship'
//                                     : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: _notesController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Notes (Optional)',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 maxLines: 3,
//                               ),
//                             ],
//                           ),
//                         )
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Card(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               color: Colors.blue[50],
//                               elevation: 1,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(24.0),
//                                 child: Column(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor: Colors.blue[50],
//                                       radius: 40,
//                                       child: Text(
//                                         "${_tenant!.firstName[0]}",
//                                         style: const TextStyle(fontSize: 36),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(1),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(10)),
//                               ),
//                               child: Row(
//                                 children: [
//                                   _buildTab('Main'),
//                                   _buildTab('other'),
//                                   _buildTab('emergency_info'),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             if (_activeTab == 'Main') _buildMainTab(),
//                             if (_activeTab == 'other') _buildOtherTab(),
//                             if (_activeTab == 'emergency_info')
//                               _buildEmergencyTab(),
//                             const SizedBox(height: 20),
//                             Divider(color: Colors.blue[50]),
//                             _infoRow(
//                                 label: 'Notes',
//                                 value: _tenant!.notes ?? 'None'),
//                             Divider(height: 40, color: Colors.blue[50]),
//                             if (isAdmin) ...[
//                               const SizedBox(height: 16),
//                               const Text(
//                                 'Room Assignment',
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                               const SizedBox(height: 8),

//                               DropdownButtonFormField<String>(
//                                 value: _selectedPropertyId,
//                                 decoration: InputDecoration(
//                                   labelText: 'Property',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 items: propertyProvider.properties
//                                     .map((property) => DropdownMenuItem(
//                                           value: property.id,
//                                           child: Text(property.name),
//                                         ))
//                                     .toList(),
//                                 onChanged: (value) async {
//                                   setState(() {
//                                     _selectedPropertyId = value;
//                                     _selectedRoomId =
//                                         null; // Clear room selection when property changes
//                                   });
//                                   if (value != null) {
//                                     await Provider.of<RoomProvider>(context,
//                                             listen: false)
//                                         .fetchRoomsByProperty(
//                                             authProvider.token!, value);

//                                     // After fetching rooms, check if tenant's current room is in this property
//                                     if (_tenant?.room != null) {
//                                       final roomExists = roomProvider.rooms.any(
//                                           (room) => room.id == _tenant!.room);
//                                       if (roomExists) {
//                                         setState(() {
//                                           _selectedRoomId = _tenant!.room;
//                                         });
//                                       }
//                                     }
//                                   }
//                                 },
//                               ),
//                               const SizedBox(height: 12),

//                               // FIXED DROPDOWN - ensures value is null if not in items list
//                               DropdownButtonFormField<String>(
//                                 value: () {
//                                   // Only set value if it exists in the available rooms
//                                   if (_selectedRoomId != null) {
//                                     final roomExists = roomProvider.rooms.any(
//                                         (room) =>
//                                             (room.isAvailable ||
//                                                 room.id == _tenant?.room) &&
//                                             room.id == _selectedRoomId);
//                                     return roomExists ? _selectedRoomId : null;
//                                   }
//                                   return null;
//                                 }(),
//                                 decoration: InputDecoration(
//                                   labelText: 'Room',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 items: () {
//                                   // Create a map to ensure unique room IDs
//                                   final Map<String, Room> uniqueRooms = {};
//                                   for (var room in roomProvider.rooms) {
//                                     if (room.isAvailable ||
//                                         room.id == _tenant?.room) {
//                                       uniqueRooms[room.id] = room;
//                                     }
//                                   }
//                                   return uniqueRooms.values
//                                       .map((room) => DropdownMenuItem(
//                                             value: room.id,
//                                             child: Text(
//                                                 'Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
//                                           ))
//                                       .toList();
//                                 }(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedRoomId = value;
//                                   });
//                                 },
//                               ),
//                               const SizedBox(height: 12),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             AppColors.primaryBlue,
//                                             AppColors.secondaryTeal
//                                           ],
//                                         ),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: ElevatedButton(
//                                         onPressed: _assignTenantToRoom,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.transparent,
//                                           shadowColor: Colors.transparent,
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                         ),
//                                         child: const Text('Assign Room',
//                                             style:
//                                                 TextStyle(color: Colors.white)),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             AppColors.red500,
//                                             AppColors.red600
//                                           ],
//                                         ),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: ElevatedButton(
//                                         onPressed: _removeTenantFromRoom,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.transparent,
//                                           shadowColor: Colors.transparent,
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                         ),
//                                         child: const Text('Remove from Room',
//                                             style:
//                                                 TextStyle(color: Colors.white)),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               const Text('Send Payment Reminder',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600)),
//                               const SizedBox(height: 8),
//                               TextFormField(
//                                 controller: _reminderController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Reminder Message (Optional)',
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                   filled: true,
//                                   fillColor: AppColors.grey50,
//                                 ),
//                                 maxLines: 3,
//                               ),
//                               const SizedBox(height: 12),
//                               Container(
//                                 width: double.infinity,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       AppColors.primaryBlue,
//                                       AppColors.secondaryTeal
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: _sendPaymentReminder,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.transparent,
//                                     shadowColor: Colors.transparent,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8)),
//                                   ),
//                                   child: const Text('Send Reminder',
//                                       style: TextStyle(color: Colors.white)),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                 ),
//     );
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _unitController.dispose();
//     _rentAmountController.dispose();
//     _securityDepositController.dispose();
//     _leaseStartDateController.dispose();
//     _leaseEndDateController.dispose();
//     _nextPaymentDueController.dispose();
//     _emergencyNameController.dispose();
//     _emergencyPhoneController.dispose();
//     _emergencyRelationshipController.dispose();
//     _notesController.dispose();
//     _reminderController.dispose();
//     super.dispose();
//   }

//   Widget _infoRow({required String label, required String value}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String tab) {
//     final isActive = _activeTab == tab;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _activeTab = tab),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive ? Colors.white : Colors.transparent,
//             border: Border.all(
//                 color: isActive ? Colors.blue : Colors.transparent, width: 2),
//             borderRadius: const BorderRadius.all(Radius.circular(10)),
//           ),
//           child: Text(
//             tab[0].toUpperCase() + tab.substring(1),
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isActive ? Colors.blue : Colors.blue,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainTab() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       color: Colors.blue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildMainRow(Icons.person, 'Full Name',
//                 '${_tenant!.firstName} ${_tenant!.lastName}'),
//             _buildMainRow(Icons.phone, 'Phone', '${_tenant!.phone}'),
//             _buildMainRow(Icons.email, 'Email', '${_tenant!.email}'),
//             _buildMainRow(Icons.verified_user, 'Status', '${_tenant!.status}'),
//             _buildMainRow(
//                 Icons.check_circle, 'Available', '${_tenant!.isActive}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOtherTab() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildMainRow(Icons.house, 'Property', '${_tenant!.property.name}'),
//             const Divider(),
//             _buildMainRow(Icons.apartment, 'Unit', '${_tenant!.unit}'),
//             const Divider(),
//             _buildMainRow(
//                 Icons.attach_money, 'Rent Amount', '${_tenant!.rentAmount}'),
//             const Divider(),
//             _buildMainRow(Icons.savings, 'Security Deposit',
//                 '${_tenant!.securityDeposit}'),
//             const Divider(),
//             _buildMainRow(
//                 Icons.date_range, 'Lease Start', '${_tenant!.leaseStartDate}'),
//             const Divider(),
//             _buildMainRow(Icons.event, 'Lease End', '${_tenant!.leaseEndDate}'),
//             const Divider(),
//             _buildMainRow(Icons.calendar_today, 'Next Payment Date',
//                 '${_tenant!.nextPaymentDue}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmergencyTab() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildMainRow(
//                 Icons.person, 'Name', '${_tenant!.emergencyContact.name}'),
//             const Divider(),
//             _buildMainRow(
//                 Icons.phone, 'Number', '${_tenant!.emergencyContact.phone}'),
//             const Divider(),
//             _buildMainRow(Icons.family_restroom, 'Relationship',
//                 '${_tenant!.emergencyContact.relationship}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainRow(IconData icon, String label, String value) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.blue, size: 20),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }