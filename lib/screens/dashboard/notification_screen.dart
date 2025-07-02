import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.payment,
        'title': 'Payment Received',
        'subtitle': 'You have received a payment from John Doe.',
        'time': '2 min ago',
        'color': AppColors.green100,
        'iconColor': AppColors.secondaryTeal,
      },
      {
        'icon': Icons.home,
        'title': 'New Property Added',
        'subtitle': 'A new property has been added to your list.',
        'time': '10 min ago',
        'color': AppColors.blue100,
        'iconColor': AppColors.primaryBlue,
      },
      {
        'icon': Icons.warning,
        'title': 'Pending Action',
        'subtitle': 'Lease agreement needs your attention.',
        'time': '1 hr ago',
        'color': AppColors.amber100,
        'iconColor': AppColors.amber500,
      },
      {
        'icon': Icons.person,
        'title': 'New Tenant',
        'subtitle': 'Jane Smith has joined as a tenant.',
        'time': 'Yesterday',
        'color': AppColors.purple100,
        'iconColor': AppColors.purple600,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return CustomCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notif['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif['icon'] as IconData,
                  color: notif['iconColor'] as Color,
                  size: 22,
                ),
              ),
              title: Text(
                notif['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                notif['subtitle'] as String,
                style: TextStyle(color: AppColors.grey500, fontSize: 13),
              ),
              trailing: Text(
                notif['time'] as String,
                style: TextStyle(color: AppColors.grey400, fontSize: 11),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          );
        },
      ),
    );
  }
}
