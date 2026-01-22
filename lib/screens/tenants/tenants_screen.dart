// import 'package:Peeman/models/tenant_model.dart';
import 'package:Peeman/screens/tenants/add_tenant_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/colors.dart';
// import '../../models/tenant.dart';
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

class _TenantsScreenState extends State<TenantsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPropertyId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
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
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: AddTenantForm(),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempPropertyId = _selectedPropertyId;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              final propertyProvider = Provider.of<PropertyProvider>(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Tenants',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['paid', 'overdue', 'pending'].map((status) {
                      final isSelected = tempStatus == status;
                      return FilterChip(
                        label: Text(status.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            tempStatus = selected ? status : null;
                          });
                        },
                        selectedColor: status == 'paid'
                            ? AppColors.green100
                            : status == 'overdue'
                                ? AppColors.red100
                                : AppColors.amber100,
                        checkmarkColor: status == 'paid'
                            ? AppColors.green500
                            : status == 'overdue'
                                ? AppColors.red500
                                : AppColors.amber500,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (status == 'paid'
                                  ? AppColors.green500
                                  : status == 'overdue'
                                      ? AppColors.red500
                                      : AppColors.amber500)
                              : AppColors.grey600,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Property',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: tempPropertyId,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('All Properties'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Properties')),
                        ...propertyProvider.properties.map((property) => DropdownMenuItem(
                              value: property.id,
                              child: Text(property.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tempPropertyId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            this.setState(() {
                              _selectedStatus = null;
                              _selectedPropertyId = null;
                            });
                            Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.grey300),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              this.setState(() {
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient Background Header
          Container(
            height: 280,
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
          
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${authProvider.currentUser?.firstName ?? "User"}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tenants',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${tenantProvider.tenants.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search tenants...',
                              hintStyle: TextStyle(color: AppColors.grey400),
                              prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppColors.grey400),
                                      onPressed: () {
                                        _searchController.clear();
                                        Provider.of<TenantProvider>(context, listen: false)
                                            .loadTenants(context);
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onChanged: (value) {
                              setState(() {});
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
                        const SizedBox(height: 16),
                        
                        // Filter Button
                        GestureDetector(
                          onTap: _showFilterDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.filter_list, color: AppColors.primaryBlue, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Filter',
                                  style: TextStyle(
                                    color: AppColors.grey800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_selectedStatus != null || _selectedPropertyId != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tenants List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: tenantProvider.tenants.isEmpty && !tenantProvider.isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
                                const SizedBox(height: 16),
                                Text(
                                  'No tenants found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Skeletonizer(
                            enabled: tenantProvider.isLoading,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              children: [
                                TenantCard(tenants: tenantProvider.tenants),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
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
    _animationController.dispose();
    super.dispose();
  }
}






// import 'package:Peeman/models/tenant_model.dart';
// import 'package:Peeman/screens/tenants/add_tenant_form.dart';
// // import 'package:Peeman/screens/tenants/add_tenant_form';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import '../../constants/colors.dart';
// import '../../models/tenant.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/tenant_provider.dart';
// import '../../providers/property_provider.dart';
// import '../../widgets/fab.dart';

// import 'tenant_card.dart';

// class TenantsScreen extends StatefulWidget {
//   const TenantsScreen({super.key});

//   @override
//   State<TenantsScreen> createState() => _TenantsScreenState();
// }

// class _TenantsScreenState extends State<TenantsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String? _selectedStatus;
//   String? _selectedPropertyId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
//       Provider.of<PropertyProvider>(context, listen: false).fetchProperties(context: context);
//     });
//   }

//   void _showAddTenantForm() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9, // Initial height of the modal (90% of screen)
//         minChildSize: 0.5, // Minimum height when dragged down
//         maxChildSize: 1.0, // Maximum height when dragged up
//         builder: (context, scrollController) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               child:  AddTenantForm(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String? tempStatus = _selectedStatus;
//         String? tempPropertyId = _selectedPropertyId;
//         return AlertDialog(
//           title: const Text('Filter Tenants'),
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               final propertyProvider = Provider.of<PropertyProvider>(context);
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: tempStatus,
//                     decoration: InputDecoration(
//                       labelText: 'Status',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     items: ['paid', 'overdue', 'pending', null]
//                         .map((status) => DropdownMenuItem(
//                               value: status,
//                               child: Text(status ?? 'All'),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         tempStatus = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     value: tempPropertyId,
//                     decoration: InputDecoration(
//                       labelText: 'Property',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     items: [
//                       const DropdownMenuItem(value: null, child: Text('All')),
//                       ...propertyProvider.properties
//                           .map((property) => DropdownMenuItem(
//                                 value: property.id,
//                                 child: Text(property.name),
//                               ))
//                           .toList(),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         tempPropertyId = value;
//                       });
//                     },
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedStatus = tempStatus;
//                   _selectedPropertyId = tempPropertyId;
//                 });
//                 if (_selectedPropertyId != null) {
//                   Provider.of<TenantProvider>(context, listen: false)
//                       .fetchTenantsByProperty(context, _selectedPropertyId!);
//                 } else if (_selectedStatus != null) {
//                   Provider.of<TenantProvider>(context, listen: false)
//                       .fetchTenantsByStatus(context, _selectedStatus!);
//                 } else {
//                   Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
//                 }
//                 Navigator.pop(context);
//               },
//               child: const Text('Apply'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final tenantProvider = Provider.of<TenantProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 color: AppColors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Tenants',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: _searchController,
//                             decoration: InputDecoration(
//                               hintText: 'Search tenants...',
//                               prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               fillColor: AppColors.grey100,
//                             ),
//                             onChanged: (value) {
//                               if (value.isNotEmpty) {
//                                 Provider.of<TenantProvider>(context, listen: false)
//                                     .searchTenants(context, value);
//                               } else {
//                                 Provider.of<TenantProvider>(context, listen: false)
//                                     .loadTenants(context);
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(Icons.filter_list, color: AppColors.grey600),
//                           onPressed: _showFilterDialog,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: tenantProvider.tenants.isEmpty
//                     ? const Center(
//                         child: Text('No tenants found'),
//                       )
//                     : SingleChildScrollView(
//                         child: Skeletonizer(
//                           enabled: tenantProvider.isLoading,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: TenantCard(tenants: tenantProvider.tenants),
//                           ),
//                         ),
//                       ),
//               ),
//             ],
//           ),
//           if (isAdmin)
//             Positioned(
//               bottom: 80,
//               right: 16,
//               child: FloatingActionButtonWidget(onPressed: _showAddTenantForm),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }