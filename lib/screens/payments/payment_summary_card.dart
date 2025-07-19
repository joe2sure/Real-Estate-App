import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';

class PaymentSummaryCard extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const PaymentSummaryCard({super.key, this.onRefresh});

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.state == PaymentState.loading && paymentProvider.paymentSummary == null) {
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
                    'Error loading payment summary',
                    style: TextStyle(color: AppColors.red500),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentMonthRevenue = paymentProvider.currentMonthRevenue;
        final outstandingAmount = paymentProvider.outstandingAmount;
        final overdueCount = paymentProvider.overduePaymentsCount;

        return Row(
          children: [
            Expanded(
              child: CustomCard(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(currentMonthRevenue),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Current month revenue',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(outstandingAmount),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: AppColors.red500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$overdueCount overdue payments',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.red500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../widgets/custom_card.dart';

// class PaymentSummaryCard extends StatelessWidget {
//   const PaymentSummaryCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: CustomCard(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColors.primaryBlue, AppColors.gradientBlue],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'This Month',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.white.withOpacity(0.9),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '\$25,600',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.arrow_upward,
//                         size: 14,
//                         color: AppColors.white,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '12% from last month',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: CustomCard(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Outstanding',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.grey600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '\$3,450',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.grey800,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 14,
//                         color: AppColors.red500,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '5 overdue payments',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.red500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }