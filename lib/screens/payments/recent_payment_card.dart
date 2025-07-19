import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';
import 'payment_detail_screen.dart';

class RecentPaymentCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  
  const RecentPaymentCard({super.key, this.onViewAll});

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.secondaryTeal;
      case 'pending':
        return AppColors.amber500;
      case 'overdue':
        return AppColors.red500;
      default:
        return AppColors.grey500;
    }
  }

  void _navigateToPaymentDetail(BuildContext context, String paymentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(paymentId: paymentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.state == PaymentState.loading && paymentProvider.recentPayments.isEmpty) {
          return const CustomCard(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (paymentProvider.state == PaymentState.error) {
          return CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: AppColors.red500, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading recent payments',
                    style: TextStyle(color: AppColors.red500),
                  ),
                ],
              ),
            ),
          );
        }

        final recentPayments = paymentProvider.recentPayments;

        if (recentPayments.isEmpty) {
          return CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.payment_outlined, color: AppColors.grey400, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'No recent payments',
                    style: TextStyle(color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          );
        }

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
                        'Recent Payments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: onViewAll,
                        child: Text(
                          'View All',
                          style: TextStyle(color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...recentPayments.take(5).map(
                  (payment) => Column(
                    children: [
                      InkWell(
                        onTap: () => _navigateToPaymentDetail(context, payment.id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: _getStatusColor(payment.status).withOpacity(0.1),
                                child: Text(
                                  payment.tenant.firstName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(payment.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment.tenant.fullName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(payment.paymentDate),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatCurrency(payment.amount),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(payment.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            payment.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getStatusColor(payment.status),
                                              fontWeight: FontWeight.w500,
                                            ),
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
                      if (payment != recentPayments.last) const Divider(height: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import '../../models/payment_model.dart';
// import '../../widgets/custom_avatar.dart';
// import '../../widgets/custom_card.dart';

// class RecentPaymentCard extends StatelessWidget {
//   const RecentPaymentCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final payments = [
//       Payment(
//         tenantName: 'Sarah Williams',
//         date: 'June 27, 2025',
//         amount: 1350,
//         image: Assets.tenant4,
//       ),
//       Payment(
//         tenantName: 'Michael Chen',
//         date: 'June 25, 2025',
//         amount: 950,
//         image: Assets.tenant5,
//       ),
//       Payment(
//         tenantName: 'Emma Mitchell',
//         date: 'June 22, 2025',
//         amount: 1250,
//         image: Assets.tenant1,
//       ),
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
//                     'Recent Payments',
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
//             ...payments.map(
//               (payment) => Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(24),
//                           child: Image.asset(
//                             payment.image,
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     payment.tenantName,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     payment.date,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: AppColors.grey500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 '\$${payment.amount}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }