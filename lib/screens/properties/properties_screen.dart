import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/fab.dart';
import 'property_card.dart';
import 'add_property.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, occupancy, income
  List<String> _selectedStatuses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('PropertiesScreen: Initializing fetchProperties');
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(context: context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPropertyForm() {
    debugPrint('PropertiesScreen: Showing AddPropertyForm');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPropertyForm(),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Properties',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['active', 'inactive', 'maintenance'].map((status) {
                final isSelected = _selectedStatuses.contains(status);
                return FilterChip(
                  label: Text(status.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedStatuses.add(status);
                      } else {
                        _selectedStatuses.remove(status);
                      }
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryBlue,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatuses.clear();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey100,
                  foregroundColor: AppColors.grey800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSortOption('Name', 'name'),
            _buildSortOption('Occupancy', 'occupancy'),
            _buildSortOption('Monthly Income', 'income'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primaryBlue)
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.blue100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  List<Property> _filterAndSortProperties(List<Property> properties) {
    var filtered = properties.where((property) {
      // Search filter
      final matchesSearch = property.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          property.address.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(property.status);

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'occupancy':
          return b.occupancy.compareTo(a.occupancy);
        case 'income':
          return b.monthlyIncome.compareTo(a.monthlyIncome);
        case 'name':
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    final filteredProperties = _filterAndSortProperties(propertyProvider.properties);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient Background
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
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                                'Properties',
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
                              '${propertyProvider.properties.length}',
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
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search properties...',
                            hintStyle: TextStyle(color: AppColors.grey400),
                            prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.grey400),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter & Sort Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.filter_list,
                              label: 'Filter',
                              badge: _selectedStatuses.isNotEmpty ? _selectedStatuses.length : null,
                              onTap: _showFilterSheet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.sort,
                              label: 'Sort',
                              onTap: _showSortSheet,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Properties List
                Expanded(
                  child: propertyProvider.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppColors.grey400),
                              const SizedBox(height: 16),
                              Text(
                                propertyProvider.errorMessage!,
                                style: TextStyle(color: AppColors.grey600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Provider.of<PropertyProvider>(context, listen: false)
                                      .fetchProperties(context: context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Skeletonizer(
                            enabled: propertyProvider.isLoading,
                            child: filteredProperties.isEmpty && !propertyProvider.isLoading
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.home_work_outlined, size: 64, color: AppColors.grey400),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedStatuses.isNotEmpty
                                              ? 'No properties match your filters'
                                              : 'No properties found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                                    children: [
                                      PropertyCard(properties: filteredProperties),
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
              child: FloatingActionButtonWidget(
                onPressed: _showAddPropertyForm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.grey800,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
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
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../models/property_model.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/property_provider.dart';
// import '../../widgets/fab.dart';
// import 'property_card.dart';
// import 'add_property.dart';

// class PropertiesScreen extends StatefulWidget {
//   const PropertiesScreen({super.key});

//   @override
//   State<PropertiesScreen> createState() => _PropertiesScreenState();
// }

// class _PropertiesScreenState extends State<PropertiesScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       debugPrint('PropertiesScreen: Initializing fetchProperties');
//       Provider.of<PropertyProvider>(context, listen: false).fetchProperties(context: context);
//     });
//   }

//   void _showAddPropertyForm() {
//     debugPrint('PropertiesScreen: Showing AddPropertyForm');
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       enableDrag: true,
//       builder: (context) => const AddPropertyForm(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final propertyProvider = Provider.of<PropertyProvider>(context);
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
//                       'Properties',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               hintText: 'Search properties...',
//                               prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               fillColor: AppColors.grey100,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(Icons.filter_list, color: AppColors.grey600),
//                           onPressed: () {},
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.sort, color: AppColors.grey600),
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child:  propertyProvider.errorMessage != null
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(propertyProvider.errorMessage!),
//                                 const SizedBox(height: 16),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Provider.of<PropertyProvider>(context, listen: false)
//                                         .fetchProperties(context: context);
//                                   },
//                                   child: const Text('Retry'),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : SingleChildScrollView(
//                             child:Skeletonizer (
//                               enabled: propertyProvider.isLoading,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: PropertyCard(properties: propertyProvider.properties),
//                               ),
//                             ),
//                           ),
//               ),
//             ],
//           ),
//           if (isAdmin)
//             Positioned(
//               bottom: 80,
//               right: 16,
//               child: FloatingActionButtonWidget(
//                 onPressed: _showAddPropertyForm,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }