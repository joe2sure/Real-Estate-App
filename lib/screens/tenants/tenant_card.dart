import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../models/tenant.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class TenantCard extends StatelessWidget {
  const TenantCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tenants = [
      Tenant(
        name: 'Emma Mitchell',
        unit: 'Unit 3A, Parkview Apartments',
        image: Assets.tenant1,
        status: 'Paid',
        phone: '+1 (555) 123-4567',
      ),
      Tenant(
        name: 'Robert Johnson',
        unit: 'Unit 5B, The Heights',
        image: Assets.tenant2,
        status: 'Overdue',
        phone: '+1 (555) 987-6543',
      ),
      Tenant(
        name: 'Daniel Thompson',
        unit: 'Unit 2C, Riverside Townhomes',
        image: Assets.tenant3,
        status: 'Due Soon',
        phone: '+1 (555) 456-7890',
      ),
      Tenant(
        name: 'Sarah Williams',
        unit: 'Unit 4A, Parkview Apartments',
        image: Assets.tenant4,
        status: 'Paid',
        phone: '+1 (555) 789-0123',
      ),
      Tenant(
        name: 'Michael Chen',
        unit: 'Unit 4A, The Heights',
        image: Assets.tenant5,
        status: 'Paid',
        phone: '+1 (555) 234-5678',
      ),
    ];

    return Column(
      children: tenants
          .map(
            (tenant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CustomAvatar(
                        imageUrl: tenant.image,
                        fallbackText: tenant.name[0],
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tenant.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                CustomBadge(
                                  text: tenant.status,
                                  backgroundColor: tenant.status == 'Paid'
                                      ? AppColors.green100
                                      : tenant.status == 'Overdue'
                                          ? AppColors.red100
                                          : AppColors.amber100,
                                  textColor: tenant.status == 'Paid'
                                      ? AppColors.amber500
                                      : tenant.status == 'Overdue'
                                          ? AppColors.red500
                                          : AppColors.amber500,
                                ),
                              ],
                            ),
                            Text(
                              tenant.unit,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: AppColors.grey500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tenant.phone,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}