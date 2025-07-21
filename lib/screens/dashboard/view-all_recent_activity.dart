import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AllRecentActivityScreen extends StatelessWidget {
  final List<dynamic>? recentPayments;
  final List<dynamic>? recentTenants;

  const AllRecentActivityScreen({
    super.key,
    this.recentPayments,
    this.recentTenants,
  });

  String _formatRelativeTime(String createdAt) {
    final date = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = <Map<String, dynamic>>[];

    if (recentPayments != null) {
      activities.addAll(recentPayments!.map((payment) {
        final tenant = payment['tenant'];
        final amount = payment['amount'] as int;
        return {
          'icon': Icons.attach_money,
          'iconColor': AppColors.primaryBlue,
          'bgColor': AppColors.blue100,
          'title': 'Payment Received',
          'subtitle': '\$${amount.toStringAsFixed(0)} from ${tenant['firstName']} ${tenant['lastName']}',
          'time': _formatRelativeTime(payment['createdAt']),
          'createdAt': DateTime.parse(payment['createdAt']),
        };
      }));
    }

    if (recentTenants != null) {
      activities.addAll(recentTenants!.map((tenant) {
        return {
          'icon': Icons.person_add,
          'iconColor': AppColors.secondaryTeal,
          'bgColor': AppColors.green100,
          'title': 'New Tenant',
          'subtitle': '${tenant['firstName']} ${tenant['lastName']} signed lease for ${tenant['unit']}',
          'time': _formatRelativeTime(tenant['createdAt']),
          'createdAt': DateTime.parse(tenant['createdAt']),
        };
      }));
    }

    activities.sort((a, b) {
      final aTime = a['createdAt'] as DateTime;
      final bTime = b['createdAt'] as DateTime;
      return bTime.compareTo(aTime); // Newest first
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recent Activity'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: activities.isEmpty
          ? const Center(child: Text('No recent activity found.'))
          : ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: activity['bgColor'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['iconColor'] as Color,
                    size: 18,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
