
import 'package:Peeman/providers/due_rent_provider.dart';
import 'package:Peeman/screens/dashboard/view_all_rent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../tenants/tenant_detail_screen.dart';

class DueRentCard extends StatefulWidget {
  const DueRentCard({super.key});

  @override
  State<DueRentCard> createState() => _DueRentCardState();
}

class _DueRentCardState extends State<DueRentCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('PropertiesScreen: Initializing fetchProperties');
      Provider.of<DueRentProvider>(context, listen: false).loadTenants(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duerentprovider = Provider.of<DueRentProvider>(context);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Due Rent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  ViewAllDueRentScreen(duerents:duerentprovider.tenants ,),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: duerentprovider.tenants.map((rent) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TenantDetailScreen(tenantId: rent.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomCard(
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomAvatar(
                                imageUrl: '${rent.firstName[0]}${rent.lastName[0]}',
                                size: 48,
                                fallbackText: '${rent.firstName[0]}${rent.lastName[0]}',
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${rent.firstName} ${rent.lastName} ",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${rent.unit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${rent.rentAmount}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              CustomBadge(
                                text: '${rent.status}',
                                backgroundColor:  AppColors.amber100,
                                textColor:  AppColors.amber500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}