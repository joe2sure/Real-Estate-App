import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': Icons.attach_money,
        'iconColor': primaryBlue,
        'bgColor': blue100,
        'title': 'Payment Received',
        'subtitle': '\$1,350 from Sarah Williams',
        'time': '2h ago',
      },
      {
        'icon': Icons.person_add,
        'iconColor': secondaryTeal,
        'bgColor': green100,
        'title': 'New Tenant',
        'subtitle': 'Michael Chen signed lease for Unit 4A',
        'time': 'Yesterday',
      },
      {
        'icon': Icons.build,
        'iconColor': amber500,
        'bgColor': amber100,
        'title': 'Maintenance Request',
        'subtitle': 'Plumbing issue in Unit 2B',
        'time': '2d ago',
      },
    ];

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(color: primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...activities.map((activity) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: activity['bgColor'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: activity['iconColor'] as Color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                activity['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}