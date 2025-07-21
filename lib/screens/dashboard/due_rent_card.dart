import 'package:Peeman/providers/due_rent_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class DueRentCard extends StatefulWidget {
  const DueRentCard({super.key});

  @override
  State<DueRentCard> createState() => _DueRentCardState();
}

class _DueRentCardState extends State<DueRentCard> {
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
    final dueRents = [
      {
        'name': 'Emma Mitchell',
        'unit': 'Unit 3A, Parkview',
        'amount': 1250.0,
        'status': 'Due in 2 days',
        'image': Assets.tenant1,
        'badgeColor': AppColors.amber100,
        'textColor': AppColors.amber500,
      },
      {
        'name': 'Robert Johnson',
        'unit': 'Unit 5B, The Heights',
        'amount': 950.0,
        'status': '3 days overdue',
        'image': Assets.tenant2,
        'badgeColor': AppColors.red100,
        'textColor': AppColors.red500,
      },
      {
        'name': 'Daniel Thompson',
        'unit': 'Unit 2C, Riverside',
        'amount': 1450.0,
        'status': 'Due tomorrow',
        'image': Assets.tenant3,
        'badgeColor': AppColors.amber100,
        'textColor': AppColors.amber500,
      },
    ];

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
              onPressed: () {},
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
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CustomCard(
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "SS",
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
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
                                  rent['unit'] as String,
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
                              '\$${rent['amount']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            CustomBadge(
                              text: rent['status'] as String,
                              backgroundColor: rent['badgeColor'] as Color,
                              textColor: rent['textColor'] as Color,
                            ),
                          ],
                        ),
                      ],
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