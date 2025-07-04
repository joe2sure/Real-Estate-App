import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_card.dart';

class RecentActivityCard extends StatelessWidget {
  final List<dynamic>? recentPayments;
  final List<dynamic>? recentTenants;

  const RecentActivityCard({super.key, this.recentPayments, this.recentTenants});

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

  Future<void> _showToast(BuildContext context, String message, {bool isError = false}) async {
    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
        backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
        textColor: AppColors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.white, fontSize: 14.0),
          ),
          backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug toast to confirm data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (recentPayments == null || recentTenants == null) {
        _showToast(context, 'No recent activity data loaded', isError: true);
      } else {
        _showToast(context, 'Recent activity data loaded successfully');
      }
    });

    final activities = <Map<String, dynamic>>[];

    // Add payments
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

    // Add tenants
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

    // Sort by createdAt (newest first)
    activities.sort((a, b) {
      final aTime = a['createdAt'] as DateTime;
      final bTime = b['createdAt'] as DateTime;
      return bTime.compareTo(aTime); // Newest first
    });

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
                      style: TextStyle(color: AppColors.primaryBlue),
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


// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../widgets/custom_card.dart';

// class RecentActivityCard extends StatelessWidget {
//   const RecentActivityCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final activities = [
//       {
//         'icon': Icons.attach_money,
//         'iconColor': AppColors.primaryBlue,
//         'bgColor': AppColors.blue100,
//         'title': 'Payment Received',
//         'subtitle': '\$1,350 from Sarah Williams',
//         'time': '2h ago',
//       },
//       {
//         'icon': Icons.person_add,
//         'iconColor': AppColors.secondaryTeal,
//         'bgColor': AppColors.green100,
//         'title': 'New Tenant',
//         'subtitle': 'Michael Chen signed lease for Unit 4A',
//         'time': 'Yesterday',
//       },
//       {
//         'icon': Icons.build,
//         'iconColor': AppColors.amber500,
//         'bgColor': AppColors.amber100,
//         'title': 'Maintenance Request',
//         'subtitle': 'Plumbing issue in Unit 2B',
//         'time': '2d ago',
//       },
//     ];

//     return CustomCard(
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 8),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Recent Activity',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       'View All',
//                       style: TextStyle(color: AppColors.primaryBlue),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             ...activities.map((activity) {
//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: activity['bgColor'] as Color,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             activity['icon'] as IconData,
//                             color: activity['iconColor'] as Color,
//                             size: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 activity['title'] as String,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Text(
//                                 activity['subtitle'] as String,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.grey500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           activity['time'] as String,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.grey500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }