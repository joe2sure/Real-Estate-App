import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
// import '../../providers/app_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
// import '../../widgets/fab.dart';
import '../../widgets/fab.dart';
import 'property_card.dart';
import 'addproperty.dart';
import '../../constants/assets.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final List<Property> _properties = [
    Property(
      name: 'Parkview Apartments',
      address: '123 Main Street, New York, NY',
      image: Assets.property1,
      status: 'Active',
      unitsOccupied: 12,
      totalUnits: 15,
      occupancy: 80,
      monthlyIncome: 15400,
    ),
    Property(
      name: 'The Heights',
      address: '456 Park Avenue, Boston, MA',
      image: Assets.property2,
      status: 'Active',
      unitsOccupied: 8,
      totalUnits: 10,
      occupancy: 80,
      monthlyIncome: 12800,
    ),
    Property(
      name: 'Riverside Townhomes',
      address: '789 River Road, Chicago, IL',
      image: Assets.property3,
      status: 'Maintenance',
      unitsOccupied: 5,
      totalUnits: 6,
      occupancy: 83,
      monthlyIncome: 8750,
    ),
  ];

  void _showAddPropertyForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPropertyForm(
        onPropertyAdded: (newProperty) {
          setState(() {
            _properties.add(newProperty);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                      'Properties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Search properties...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.grey100,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.grey600),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.sort, color: AppColors.grey600),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PropertyCard(properties: _properties),
                  ),
                ),
              ),
            ],
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
}