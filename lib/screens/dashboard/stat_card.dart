import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_card.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
Widget build(BuildContext context) {
  final stats = [
    {
      'icon': Icons.apartment,
      'color': AppColors.blue100,
      'iconColor': AppColors.primaryBlue,
      'title': 'Properties',
      'value': '12',
    },
    {
      'icon': Icons.people,
      'color': AppColors.green100,
      'iconColor': AppColors.secondaryTeal,
      'title': 'Tenants',
      'value': '48',
    },
    {
      'icon': Icons.attach_money,
      'color': AppColors.purple100,
      'iconColor': AppColors.purple600,
      'title': 'Revenue',
      'value': '\$25.6K',
    },
    {
      'icon': Icons.pending_actions,
      'color': AppColors.amber100,
      'iconColor': AppColors.amber500,
      'title': 'Pending',
      'value': '5',
    },
  ];

  return GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.4, // wider, shorter cards
    children: stats.map((stat) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(8), // less padding = less height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: stat['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: stat['iconColor'] as Color,
                  size: 16,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 12, // smaller font
                    ),
                  ),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}
}