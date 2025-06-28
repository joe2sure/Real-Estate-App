import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../models/property.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = [
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

    return Column(
      children: properties
          .map(
            (property) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomCard(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            property.image,
                            height: 192,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: CustomBadge(
                            text: property.status,
                            backgroundColor: property.status == 'Active' ? AppColors.green500 : AppColors.amber500,
                            textColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Units',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  Text(
                                    '${property.unitsOccupied} / ${property.totalUnits}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Occupancy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  Text(
                                    '${property.occupancy}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Income',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  Text(
                                    '\$${property.monthlyIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
          )
          .toList(),
    );
  }
}