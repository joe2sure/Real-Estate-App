import 'package:Peeman/screens/dashboard/recent_activity_detail.dart';
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

  String _getPaymentTitle(dynamic payment) {
    final type = payment['paymentType'] as String? ?? '';
    final method = payment['method'] as String? ?? '';
    final capitalizedType = type.isNotEmpty ? '${type[0].toUpperCase()}${type.substring(1)}' : 'Payment';
    final capitalizedMethod = method.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    return capitalizedMethod.isNotEmpty ? '$capitalizedType Payment via $capitalizedMethod' : capitalizedType;
  }

  @override
  Widget build(BuildContext context) {
    final activities = <Map<String, dynamic>>[];

    // Add payments with null safety
    if (recentPayments != null) {
      for (var payment in recentPayments!) {
        try {
          final tenant = payment['tenant'];
          final amount = payment['amount'] as int? ?? 0;
          
          String tenantName = 'Unknown Tenant';
          if (tenant != null && tenant is Map<String, dynamic>) {
            final firstName = tenant['firstName'] ?? tenant['firstname'] ?? '';
            final lastName = tenant['lastName'] ?? tenant['lastname'] ?? '';
            tenantName = '$firstName $lastName'.trim();
            if (tenantName.isEmpty) tenantName = 'Unknown Tenant';
          }
          
          activities.add({
            'type': 'payment',
            'data': payment,
            'icon': Icons.attach_money,
            'iconColor': AppColors.primaryBlue,
            'bgColor': AppColors.blue100,
            'title': _getPaymentTitle(payment),
            'subtitle': '£${amount.toStringAsFixed(0)} from $tenantName',
            'time': _formatRelativeTime(payment['createdAt'] ?? DateTime.now().toIso8601String()),
            'createdAt': DateTime.tryParse(payment['createdAt'] ?? '') ?? DateTime.now(),
          });
        } catch (e) {
          debugPrint('Error processing payment: $e');
        }
      }
    }

    // Add tenants with null safety
    if (recentTenants != null) {
      for (var tenant in recentTenants!) {
        try {
          final firstName = tenant['firstName'] ?? tenant['firstname'] ?? '';
          final lastName = tenant['lastName'] ?? tenant['lastname'] ?? '';
          final unit = tenant['unit'] ?? 'Unknown Unit';
          
          activities.add({
            'type': 'tenant',
            'data': tenant,
            'icon': Icons.person_add,
            'iconColor': AppColors.secondaryTeal,
            'bgColor': AppColors.green100,
            'title': 'New Tenant',
            'subtitle': '$firstName $lastName signed lease for $unit',
            'time': _formatRelativeTime(tenant['createdAt'] ?? DateTime.now().toIso8601String()),
            'createdAt': DateTime.tryParse(tenant['createdAt'] ?? '') ?? DateTime.now(),
          });
        } catch (e) {
          debugPrint('Error processing tenant: $e');
        }
      }
    }

    // Sort by createdAt (newest first)
    activities.sort((a, b) {
      final aTime = a['createdAt'] as DateTime;
      final bTime = b['createdAt'] as DateTime;
      return bTime.compareTo(aTime);
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
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecentActivityDetailScreen(
                          activity: activity['data'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
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
                  ),
                );
              },
            ),
    );
  }
}



// import 'package:Peeman/screens/dashboard/recent_activity_detail.dart'; // New
// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';

// class AllRecentActivityScreen extends StatelessWidget {
//   final List<dynamic>? recentPayments;
//   final List<dynamic>? recentTenants;

//   const AllRecentActivityScreen({
//     super.key,
//     this.recentPayments,
//     this.recentTenants,
//   });

//   String _formatRelativeTime(String createdAt) {
//     final date = DateTime.parse(createdAt);
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays < 1) {
//       if (difference.inHours < 1) {
//         return '${difference.inMinutes}m ago';
//       }
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else {
//       return '${difference.inDays}d ago';
//     }
//   }

//   String _getPaymentTitle(dynamic payment) {
//     final type = payment['paymentType'] as String;
//     final method = payment['method'] as String;
//     final capitalizedType = type.isNotEmpty ? '${type[0].toUpperCase()}${type.substring(1)}' : '';
//     final capitalizedMethod = method.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
//     return '$capitalizedType Payment via $capitalizedMethod';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final activities = <Map<String, dynamic>>[];

//     if (recentPayments != null) {
//       activities.addAll(recentPayments!.map((payment) {
//         final tenant = payment['tenant'];
//         final amount = payment['amount'] as int;
//         return {
//           'type': 'payment',
//           'data': payment,
//           'icon': Icons.attach_money,
//           'iconColor': AppColors.primaryBlue,
//           'bgColor': AppColors.blue100,
//           'title': _getPaymentTitle(payment), // Changed title
//           'subtitle': '£${amount.toStringAsFixed(0)} from ${tenant['firstName']} ${tenant['lastName']}', // £
//           'time': _formatRelativeTime(payment['createdAt']),
//           'createdAt': DateTime.parse(payment['createdAt']),
//         };
//       }));
//     }

//     if (recentTenants != null) {
//       activities.addAll(recentTenants!.map((tenant) {
//         return {
//           'type': 'tenant',
//           'data': tenant,
//           'icon': Icons.person_add,
//           'iconColor': AppColors.secondaryTeal,
//           'bgColor': AppColors.green100,
//           'title': 'New Tenant',
//           'subtitle': '${tenant['firstName']} ${tenant['lastName']} signed lease for ${tenant['unit']}',
//           'time': _formatRelativeTime(tenant['createdAt']),
//           'createdAt': DateTime.parse(tenant['createdAt']),
//         };
//       }));
//     }

//     activities.sort((a, b) {
//       final aTime = a['createdAt'] as DateTime;
//       final bTime = b['createdAt'] as DateTime;
//       return bTime.compareTo(aTime); // Newest first
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Recent Activity'),
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: Colors.white,
//       ),
//       body: activities.isEmpty
//           ? const Center(child: Text('No recent activity found.'))
//           : ListView.separated(
//               itemCount: activities.length,
//               separatorBuilder: (_, __) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 final activity = activities[index];
//                 return GestureDetector( // Added onTap
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => RecentActivityDetailScreen(activity: activity['data']),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: activity['bgColor'] as Color,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             activity['icon'] as IconData,
//                             color: activity['iconColor'] as Color,
//                             size: 18,
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
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 activity['subtitle'] as String,
//                                 style: TextStyle(
//                                   fontSize: 13,
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
//                 );
//               },
//             ),
//     );
//   }
// }