import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class DueRentCard extends StatelessWidget {
  const DueRentCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: dueRents.map((rent) {
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
                            CustomAvatar(
                              imageUrl: rent['image'] as String,
                              fallbackText: rent['name'].toString()[0],
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rent['name'] as String,
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