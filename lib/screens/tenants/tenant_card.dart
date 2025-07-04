import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../models/tenant_model.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class TenantCard extends StatelessWidget {
  final List<Tenant> tenants;

  const TenantCard({super.key, required this.tenants});

  @override
  Widget build(BuildContext context) {
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