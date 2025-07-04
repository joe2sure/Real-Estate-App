import 'package:Peeman/screens/tenants/add_tenant_form';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/assets.dart';
import '../../models/tenant_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/fab.dart';
import 'tenant_card.dart';
// import 'add_tenant_form.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final List<Tenant> _tenants = [
    Tenant(
      name: 'Emma Mitchell',
      unit: 'Unit 3A, Parkview Apartments',
      image: Assets.tenant1,
      status: 'Paid',
      phone: '+1 (555) 123-4567',
    ),
    // ... other existing tenants ...
  ];

  void _showAddTenantForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTenantForm(
        onTenantAdded: (Tenant newTenant) {
          setState(() => _tenants.add(newTenant));
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
                      'Tenants',
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
                              hintText: 'Search tenants...',
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
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TenantCard(tenants: _tenants),
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
}