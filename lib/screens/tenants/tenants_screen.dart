
import 'package:Peeman/models/tenant_model.dart';
import 'package:Peeman/screens/tenants/add_tenant_form';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/colors.dart';
import '../../models/tenant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/fab.dart';

import 'tenant_card.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(context: context);
    });
  }

  void _showAddTenantForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9, // Initial height of the modal (90% of screen)
        minChildSize: 0.5, // Minimum height when dragged down
        maxChildSize: 1.0, // Maximum height when dragged up
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child:  AddTenantForm(),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempPropertyId = _selectedPropertyId;
        return AlertDialog(
          title: const Text('Filter Tenants'),
          content: StatefulBuilder(
            builder: (context, setState) {
              final propertyProvider = Provider.of<PropertyProvider>(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['paid', 'overdue', 'pending', null]
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status ?? 'All'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempPropertyId,
                    decoration: InputDecoration(
                      labelText: 'Property',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...propertyProvider.properties
                          .map((property) => DropdownMenuItem(
                                value: property.id,
                                child: Text(property.name),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempPropertyId = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = tempStatus;
                  _selectedPropertyId = tempPropertyId;
                });
                if (_selectedPropertyId != null) {
                  Provider.of<TenantProvider>(context, listen: false)
                      .fetchTenantsByProperty(context, _selectedPropertyId!);
                } else if (_selectedStatus != null) {
                  Provider.of<TenantProvider>(context, listen: false)
                      .fetchTenantsByStatus(context, _selectedStatus!);
                } else {
                  Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
                }
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final tenantProvider = Provider.of<TenantProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tenants',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search tenants...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.grey100,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                Provider.of<TenantProvider>(context, listen: false)
                                    .searchTenants(context, value);
                              } else {
                                Provider.of<TenantProvider>(context, listen: false)
                                    .loadTenants(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.grey600),
                          onPressed: _showFilterDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tenantProvider.tenants.isEmpty
                    ? const Center(
                        child: Text('No tenants found'),
                      )
                    : SingleChildScrollView(
                        child: Skeletonizer(
                          enabled: tenantProvider.isLoading,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TenantCard(tenants: tenantProvider.tenants),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (isAdmin)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButtonWidget(onPressed: _showAddTenantForm),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}