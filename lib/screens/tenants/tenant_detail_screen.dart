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
        _selectedPropertyId = tenant.property!.id;
        _status = tenant.status;
        // CRITICAL: Set room ID to null initially to prevent dropdown errors
        _selectedRoomId = null;
      });

      // Fetch rooms for the tenant's property
      if (_selectedPropertyId != null && authProvider.token != null) {
        try {
          await Provider.of<RoomProvider>(context, listen: false)
              .fetchRoomsByProperty(authProvider.token!, _selectedPropertyId!);

          // NOW we can safely set the room ID after rooms are loaded
          final roomProvider = Provider.of<RoomProvider>(context, listen: false);
          if (tenant.room != null && tenant.room!.isNotEmpty) {
            // Create unique rooms map to check availability
            final Map<String, Room> uniqueRooms = {};
            for (var room in roomProvider.rooms) {
              if (room.isAvailable || room.id == tenant.room) {
                uniqueRooms[room.id] = room;
              }
            }
            
            // Only set room ID if it exists in available rooms
            final roomExists = uniqueRooms.containsKey(tenant.room);
            
            if (roomExists) {
              setState(() {
                _selectedRoomId = tenant.room;
              });
            } else {
              // Room doesn't exist or is not available - keep it null
              setState(() {
                _selectedRoomId = null;
              });
              debugPrint('Warning: Tenant ${tenant.id} assigned to room ${tenant.room} which does not exist or is not available');
            }
          }
        } catch (e) {
          debugPrint('Error fetching rooms for property: $e');
          // If rooms fail to load, ensure room ID stays null
          setState(() {
            _selectedRoomId = null;
          });
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
                                      _buildQuickInfo(Icons.home, _tenant!.property!.name),
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

// COMPLETE FIX: Replace your _buildDetailsTab method with this version

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
            _buildInfoRow(Icons.location_city, 'Property', _tenant!.property!.name),
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
                      _selectedRoomId = null; // ALWAYS clear room when property changes
                    });
                    if (value != null) {
                      await Provider.of<RoomProvider>(context, listen: false)
                          .fetchRoomsByProperty(authProvider.token!, value);

                      // Don't auto-restore room - let user select manually
                      setState(() {
                        _selectedRoomId = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // FIXED: Room dropdown with bulletproof validation
                Builder(
                  builder: (context) {
                    // Create unique room map
                    final Map<String, Room> uniqueRooms = {};
                    for (var room in roomProvider.rooms) {
                      if (room.isAvailable || room.id == _tenant?.room) {
                        uniqueRooms[room.id] = room;
                      }
                    }
                    
                    // Determine safe value for dropdown
                    String? safeValue;
                    if (_selectedRoomId != null && uniqueRooms.containsKey(_selectedRoomId)) {
                      safeValue = _selectedRoomId;
                    } else {
                      safeValue = null;
                    }
                    
                    return DropdownButtonFormField<String>(
                      key: ValueKey('room_dropdown_$safeValue'), // Force rebuild when value changes
                      value: safeValue,
                      decoration: InputDecoration(
                        labelText: 'Room',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.grey50,
                      ),
                      items: uniqueRooms.isEmpty
                          ? [
                              DropdownMenuItem(
                                value: null,
                                child: Text('No rooms available'),
                              )
                            ]
                          : uniqueRooms.values
                              .map((room) => DropdownMenuItem(
                                    value: room.id,
                                    child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
                                  ))
                              .toList(),
                      onChanged: uniqueRooms.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRoomId = value;
                              });
                            },
                    );
                  }
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
                onChanged: (value) async {
                  setState(() {
                    _selectedPropertyId = value;
                    _selectedRoomId = null; // Clear room when property changes
                  });
                  if (value != null && authProvider.token != null) {
                    await Provider.of<RoomProvider>(context, listen: false)
                        .fetchRoomsByProperty(authProvider.token!, value);
                    // Keep room selection cleared - let user select manually
                    setState(() {
                      _selectedRoomId = null;
                    });
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              // FIXED: Room dropdown in edit form
              Builder(
                builder: (context) {
                  // Create unique rooms map
                  final Map<String, Room> uniqueRooms = {};
                  for (var room in roomProvider.rooms) {
                    if (room.isAvailable || room.id == _tenant?.room) {
                      uniqueRooms[room.id] = room;
                    }
                  }
                  
                  // Determine safe value for dropdown
                  String? safeValue;
                  if (_selectedRoomId != null && uniqueRooms.containsKey(_selectedRoomId)) {
                    safeValue = _selectedRoomId;
                  } else {
                    safeValue = null;
                  }
                  
                  return DropdownButtonFormField<String>(
                    key: ValueKey('room_edit_dropdown_$safeValue'), // Force rebuild
                    value: safeValue,
                    decoration: _inputDecoration('Room', Icons.meeting_room),
                    items: uniqueRooms.isEmpty
                        ? [
                            DropdownMenuItem(
                              value: null,
                              child: Text('No rooms available'),
                            )
                          ]
                        : uniqueRooms.values
                            .map((room) => DropdownMenuItem(
                                  value: room.id,
                                  child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
                                ))
                            .toList(),
                    onChanged: uniqueRooms.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _selectedRoomId = value;
                            });
                          },
                  );
                }
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




    // Future<void> _fetchTenant() async {
    //   try {
    //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //     final tenant = await Provider.of<TenantProvider>(context, listen: false)
    //         .fetchTenantById(context, widget.tenantId);

    //     setState(() {
    //       _tenant = tenant;
    //       _firstNameController.text = tenant.firstName;
    //       _lastNameController.text = tenant.lastName;
    //       _emailController.text = tenant.email;
    //       _phoneController.text = tenant.phone;
    //       _unitController.text = tenant.unit;
    //       _rentAmountController.text = tenant.rentAmount.toString();
    //       _securityDepositController.text = tenant.securityDeposit.toString();
    //       _leaseStartDateController.text =
    //           tenant.leaseStartDate.toIso8601String().split('T')[0];
    //       _leaseEndDateController.text =
    //           tenant.leaseEndDate.toIso8601String().split('T')[0];
    //       _nextPaymentDueController.text =
    //           tenant.nextPaymentDue.toIso8601String().split('T')[0];
    //       _emergencyNameController.text = tenant.emergencyContact.name;
    //       _emergencyPhoneController.text = tenant.emergencyContact.phone;
    //       _emergencyRelationshipController.text =
    //           tenant.emergencyContact.relationship;
    //       _notesController.text = tenant.notes ?? '';
    //       _selectedPropertyId = tenant.property.id;
    //       _status = tenant.status;
    //       // Don't set _selectedRoomId yet - wait for rooms to load
    //     });

    //     // Fetch rooms for the tenant's property
    //     if (_selectedPropertyId != null && authProvider.token != null) {
    //       try {
    //         await Provider.of<RoomProvider>(context, listen: false)
    //             .fetchRoomsByProperty(authProvider.token!, _selectedPropertyId!);

    //         // NOW we can safely set the room ID after rooms are loaded
    //         final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    //         if (tenant.room != null && tenant.room!.isNotEmpty) {
    //           // Check if the tenant's room exists in the loaded rooms
    //           final roomExists = roomProvider.rooms.any((room) => room.id == tenant.room);
    //           setState(() {
    //             _selectedRoomId = roomExists ? tenant.room : null;
    //           });
              
    //           // Log warning if room doesn't exist
    //           if (!roomExists) {
    //             debugPrint('Warning: Tenant ${tenant.id} assigned to room ${tenant.room} which does not exist or is not available');
    //           }
    //         } else {
    //           setState(() {
    //             _selectedRoomId = null;
    //           });
    //         }
    //       } catch (e) {
    //         debugPrint('Error fetching rooms for property: $e');
    //         // If rooms fail to load, set room ID to null to prevent dropdown error
    //         setState(() {
    //           _selectedRoomId = null;
    //         });
    //       }
    //     }

    //     setState(() {
    //       _isLoading = false;
    //     });
    //   } catch (error) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     CustomToast.show(context, 'Failed to load tenant: $error', isSuccess: false);
    //   }
    // }



      // Widget _buildEditForm(PropertyProvider propertyProvider, RoomProvider roomProvider, AuthProvider authProvider) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(20),
  //     child: Form(
  //       key: _formKey,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildFormSection('Personal Information', [
  //             _buildTextField(_firstNameController, 'First Name', Icons.person),
  //             const SizedBox(height: 12),
  //             _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
  //             const SizedBox(height: 12),
  //             _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
  //             const SizedBox(height: 12),
  //             _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Property & Unit', [
  //             DropdownButtonFormField<String>(
  //               value: _selectedPropertyId,
  //               decoration: _inputDecoration('Property', Icons.business),
  //               items: propertyProvider.properties
  //                   .map((property) => DropdownMenuItem(value: property.id, child: Text(property.name)))
  //                   .toList(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   _selectedPropertyId = value;
  //                   _selectedRoomId = null;
  //                   if (value != null) {
  //                     Provider.of<RoomProvider>(context, listen: false)
  //                         .fetchRoomsByProperty(authProvider.token!, value);
  //                   }
  //                 });
  //               },
  //               validator: (value) => value == null ? 'Required' : null,
  //             ),
  //             const SizedBox(height: 12),

  //             DropdownButtonFormField<String>(
  //               value: () {
  //                 // Only set value if rooms are loaded and the selected room exists in the list
  //                 if (_selectedRoomId == null || roomProvider.rooms.isEmpty) {
  //                   return null;
  //                 }
                  
  //                 // Create unique room map to prevent duplicates
  //                 final Map<String, Room> uniqueRooms = {};
  //                 for (var room in roomProvider.rooms) {
  //                   if (room.isAvailable || room.id == _tenant?.room) {
  //                     uniqueRooms[room.id] = room;
  //                   }
  //                 }
                  
  //                 // Check if selected room exists in unique rooms
  //                 final roomExists = uniqueRooms.containsKey(_selectedRoomId);
  //                 return roomExists ? _selectedRoomId : null;
  //               }(),
  //               decoration: _inputDecoration('Room', Icons.meeting_room),
  //               items: () {
  //                 // Create unique room map to prevent duplicate values
  //                 final Map<String, Room> uniqueRooms = {};
  //                 for (var room in roomProvider.rooms) {
  //                   if (room.isAvailable || room.id == _tenant?.room) {
  //                     uniqueRooms[room.id] = room;
  //                   }
  //                 }
                  
  //                 // Convert to dropdown items
  //                 return uniqueRooms.values
  //                     .map((room) => DropdownMenuItem(
  //                           value: room.id,
  //                           child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
  //                         ))
  //                     .toList();
  //               }(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   _selectedRoomId = value;
  //                 });
  //               },
  //             ),

  //             const SizedBox(height: 12),
  //             _buildTextField(_unitController, 'Unit Number', Icons.apartment),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Financial', [
  //             _buildTextField(_rentAmountController, 'Rent Amount', Icons.attach_money, keyboardType: TextInputType.number),
  //             const SizedBox(height: 12),
  //             _buildTextField(_securityDepositController, 'Security Deposit', Icons.account_balance_wallet, keyboardType: TextInputType.number),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Lease Dates', [
  //             _buildDateField(_leaseStartDateController, 'Lease Start Date', Icons.event_available),
  //             const SizedBox(height: 12),
  //             _buildDateField(_leaseEndDateController, 'Lease End Date', Icons.event_busy),
  //             const SizedBox(height: 12),
  //             _buildDateField(_nextPaymentDueController, 'Next Payment Due', Icons.calendar_today),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Status', [
  //             DropdownButtonFormField<String>(
  //               value: _status,
  //               decoration: _inputDecoration('Payment Status', Icons.payment),
  //               items: ['paid', 'overdue', 'pending']
  //                   .map((status) => DropdownMenuItem(value: status, child: Text(status)))
  //                   .toList(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   _status = value!;
  //                 });
  //               },
  //             ),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Emergency Contact', [
  //             _buildTextField(_emergencyNameController, 'Name', Icons.person),
  //             const SizedBox(height: 12),
  //             _buildTextField(_emergencyPhoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
  //             const SizedBox(height: 12),
  //             _buildTextField(_emergencyRelationshipController, 'Relationship', Icons.people),
  //           ]),
            
  //           const SizedBox(height: 20),
            
  //           _buildFormSection('Notes', [
  //             TextFormField(
  //               controller: _notesController,
  //               decoration: _inputDecoration('Notes (Optional)', Icons.note),
  //               maxLines: 4,
  //             ),
  //           ]),
            
  //           const SizedBox(height: 100),
  //         ],
  //       ),
  //     ),
  //   );
  // }

    // Widget _buildDetailsTab() {
  //   final authProvider = Provider.of<AuthProvider>(context);
  //   final propertyProvider = Provider.of<PropertyProvider>(context);
  //   final roomProvider = Provider.of<RoomProvider>(context);
  //   final isAdmin = authProvider.currentUser?.role == 'admin';

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionCard(
  //           title: 'Property Details',
  //           icon: Icons.business,
  //           children: [
  //             _buildInfoRow(Icons.location_city, 'Property', _tenant!.property.name),
  //             const Divider(height: 24),
  //             _buildInfoRow(Icons.meeting_room, 'Unit', _tenant!.unit),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
          
  //         _buildSectionCard(
  //           title: 'Lease Information',
  //           icon: Icons.description,
  //           children: [
  //             _buildInfoRow(
  //               Icons.event_available, 
  //               'Lease Start', 
  //               DateFormat('MMM dd, yyyy').format(_tenant!.leaseStartDate),
  //             ),
  //             const Divider(height: 24),
  //             _buildInfoRow(
  //               Icons.event_busy, 
  //               'Lease End', 
  //               DateFormat('MMM dd, yyyy').format(_tenant!.leaseEndDate),
  //             ),
  //             const Divider(height: 24),
  //             _buildInfoRow(
  //               Icons.verified, 
  //               'Status', 
  //               _tenant!.isActive ? 'Active' : 'Inactive',
  //             ),
  //           ],
  //         ),
          
  //         if (isAdmin) ...[
  //           const SizedBox(height: 24),
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.primaryBlue.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: const Icon(Icons.meeting_room, color: AppColors.primaryBlue, size: 20),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Room Assignment',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.grey800,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 DropdownButtonFormField<String>(
  //                   value: _selectedPropertyId,
  //                   decoration: InputDecoration(
  //                     labelText: 'Property',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   items: propertyProvider.properties
  //                       .map((property) => DropdownMenuItem(
  //                             value: property.id,
  //                             child: Text(property.name),
  //                           ))
  //                       .toList(),
  //                   onChanged: (value) async {
  //                     setState(() {
  //                       _selectedPropertyId = value;
  //                       _selectedRoomId = null; // Clear room selection when property changes
  //                     });
  //                     if (value != null) {
  //                       await Provider.of<RoomProvider>(context, listen: false)
  //                           .fetchRoomsByProperty(authProvider.token!, value);

  //                       // Only restore room selection if it exists in the new room list
  //                       if (_tenant?.room != null) {
  //                         final roomExists = roomProvider.rooms.any((room) => room.id == _tenant!.room);
  //                         if (roomExists) {
  //                           setState(() {
  //                             _selectedRoomId = _tenant!.room;
  //                           });
  //                         }
  //                       }
  //                     }
  //                   },
  //                 ),
  //                 const SizedBox(height: 12),
                  
  //                 // FIXED: Properly handle room dropdown with null safety and duplicate prevention
  //                 DropdownButtonFormField<String>(
  //                   value: () {
  //                     // Only set value if rooms are loaded and the selected room exists in the list
  //                     if (_selectedRoomId == null || roomProvider.rooms.isEmpty) {
  //                       return null;
  //                     }
                      
  //                     // Create unique room map to prevent duplicates
  //                     final Map<String, Room> uniqueRooms = {};
  //                     for (var room in roomProvider.rooms) {
  //                       if (room.isAvailable || room.id == _tenant?.room) {
  //                         uniqueRooms[room.id] = room;
  //                       }
  //                     }
                      
  //                     // Check if selected room exists in unique rooms
  //                     final roomExists = uniqueRooms.containsKey(_selectedRoomId);
  //                     return roomExists ? _selectedRoomId : null;
  //                   }(),
  //                   decoration: InputDecoration(
  //                     labelText: 'Room',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   items: () {
  //                     // Create unique room map to prevent duplicate values
  //                     final Map<String, Room> uniqueRooms = {};
  //                     for (var room in roomProvider.rooms) {
  //                       if (room.isAvailable || room.id == _tenant?.room) {
  //                         uniqueRooms[room.id] = room;
  //                       }
  //                     }
                      
  //                     // Convert to dropdown items
  //                     return uniqueRooms.values
  //                         .map((room) => DropdownMenuItem(
  //                               value: room.id,
  //                               child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
  //                             ))
  //                         .toList();
  //                   }(),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       _selectedRoomId = value;
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
  //                           ),
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: ElevatedButton(
  //                           onPressed: _assignTenantToRoom,
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.transparent,
  //                             shadowColor: Colors.transparent,
  //                             padding: const EdgeInsets.symmetric(vertical: 14),
  //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                           ),
  //                           child: const Text('Assign Room', style: TextStyle(color: Colors.white)),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: OutlinedButton(
  //                         onPressed: _removeTenantFromRoom,
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 14),
  //                           side: const BorderSide(color: AppColors.red500),
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                         ),
  //                         child: const Text('Remove', style: TextStyle(color: AppColors.red500)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 16),
            
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.amber100,
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: const Icon(Icons.notifications_active, color: AppColors.amber500, size: 20),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Send Payment Reminder',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.grey800,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 TextFormField(
  //                   controller: _reminderController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Custom Message (Optional)',
  //                     hintText: 'Leave empty for default message',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   maxLines: 4,
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 Container(
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [AppColors.amber500, Colors.orange],
  //                     ),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: ElevatedButton(
  //                     onPressed: _sendPaymentReminder,
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.transparent,
  //                       shadowColor: Colors.transparent,
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                     ),
  //                     child: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
          
  //         const SizedBox(height: 100),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDetailsTab() {
  //   final authProvider = Provider.of<AuthProvider>(context);
  //   final propertyProvider = Provider.of<PropertyProvider>(context);
  //   final roomProvider = Provider.of<RoomProvider>(context);
  //   final isAdmin = authProvider.currentUser?.role == 'admin';

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionCard(
  //           title: 'Property Details',
  //           icon: Icons.business,
  //           children: [
  //             _buildInfoRow(Icons.location_city, 'Property', _tenant!.property.name),
  //             const Divider(height: 24),
  //             _buildInfoRow(Icons.meeting_room, 'Unit', _tenant!.unit),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
          
  //         _buildSectionCard(
  //           title: 'Lease Information',
  //           icon: Icons.description,
  //           children: [
  //             _buildInfoRow(
  //               Icons.event_available, 
  //               'Lease Start', 
  //               DateFormat('MMM dd, yyyy').format(_tenant!.leaseStartDate),
  //             ),
  //             const Divider(height: 24),
  //             _buildInfoRow(
  //               Icons.event_busy, 
  //               'Lease End', 
  //               DateFormat('MMM dd, yyyy').format(_tenant!.leaseEndDate),
  //             ),
  //             const Divider(height: 24),
  //             _buildInfoRow(
  //               Icons.verified, 
  //               'Status', 
  //               _tenant!.isActive ? 'Active' : 'Inactive',
  //             ),
  //           ],
  //         ),
          
  //         if (isAdmin) ...[
  //           const SizedBox(height: 24),
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.primaryBlue.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: const Icon(Icons.meeting_room, color: AppColors.primaryBlue, size: 20),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Room Assignment',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.grey800,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 DropdownButtonFormField<String>(
  //                   value: _selectedPropertyId,
  //                   decoration: InputDecoration(
  //                     labelText: 'Property',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   items: propertyProvider.properties
  //                       .map((property) => DropdownMenuItem(
  //                             value: property.id,
  //                             child: Text(property.name),
  //                           ))
  //                       .toList(),
  //                   onChanged: (value) async {
  //                     setState(() {
  //                       _selectedPropertyId = value;
  //                       _selectedRoomId = null;
  //                     });
  //                     if (value != null) {
  //                       await Provider.of<RoomProvider>(context, listen: false)
  //                           .fetchRoomsByProperty(authProvider.token!, value);

  //                       if (_tenant?.room != null) {
  //                         final roomExists = roomProvider.rooms.any((room) => room.id == _tenant!.room);
  //                         if (roomExists) {
  //                           setState(() {
  //                             _selectedRoomId = _tenant!.room;
  //                           });
  //                         }
  //                       }
  //                     }
  //                   },
  //                 ),
  //                 const SizedBox(height: 12),
                  
  //                 DropdownButtonFormField<String>(
  //                   value: () {
  //                     if (_selectedRoomId != null) {
  //                       final roomExists = roomProvider.rooms.any(
  //                           (room) => (room.isAvailable || room.id == _tenant?.room) && room.id == _selectedRoomId);
  //                       return roomExists ? _selectedRoomId : null;
  //                     }
  //                     return null;
  //                   }(),
  //                   decoration: InputDecoration(
  //                     labelText: 'Room',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   items: () {
  //                     final Map<String, Room> uniqueRooms = {};
  //                     for (var room in roomProvider.rooms) {
  //                       if (room.isAvailable || room.id == _tenant?.room) {
  //                         uniqueRooms[room.id] = room;
  //                       }
  //                     }
  //                     return uniqueRooms.values
  //                         .map((room) => DropdownMenuItem(
  //                               value: room.id,
  //                               child: Text('Room ${room.roomNumber}${room.id == _tenant?.room ? ' (Current)' : ''}'),
  //                             ))
  //                         .toList();
  //                   }(),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       _selectedRoomId = value;
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
  //                           ),
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: ElevatedButton(
  //                           onPressed: _assignTenantToRoom,
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.transparent,
  //                             shadowColor: Colors.transparent,
  //                             padding: const EdgeInsets.symmetric(vertical: 14),
  //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                           ),
  //                           child: const Text('Assign Room', style: TextStyle(color: Colors.white)),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: OutlinedButton(
  //                         onPressed: _removeTenantFromRoom,
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 14),
  //                           side: const BorderSide(color: AppColors.red500),
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                         ),
  //                         child: const Text('Remove', style: TextStyle(color: AppColors.red500)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 16),
            
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.amber100,
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: const Icon(Icons.notifications_active, color: AppColors.amber500, size: 20),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Send Payment Reminder',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.grey800,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 TextFormField(
  //                   controller: _reminderController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Custom Message (Optional)',
  //                     hintText: 'Leave empty for default message',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                     filled: true,
  //                     fillColor: AppColors.grey50,
  //                   ),
  //                   maxLines: 4,
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 Container(
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [AppColors.amber500, Colors.orange],
  //                     ),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: ElevatedButton(
  //                     onPressed: _sendPaymentReminder,
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.transparent,
  //                       shadowColor: Colors.transparent,
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                     ),
  //                     child: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
          
  //         const SizedBox(height: 100),
  //       ],
  //     ),
  //   );
  // }