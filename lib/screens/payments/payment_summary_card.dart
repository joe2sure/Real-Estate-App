import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';

class PaymentSummaryCard extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const PaymentSummaryCard({super.key, this.onRefresh});

  String _formatCurrency(double amount) {
    return '£${amount.toStringAsFixed(0).replaceAllMapped(
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatCurrency(currentMonthRevenue),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current month revenue',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.red100.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.red500.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red500.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red500.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: AppColors.red500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Outstanding',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatCurrency(outstandingAmount),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red500,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.red500.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: AppColors.red500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$overdueCount overdue',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.red500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/payment_provider.dart';
// import '../../widgets/custom_card.dart';

// class PaymentSummaryCard extends StatelessWidget {
//   final VoidCallback? onRefresh;
  
//   const PaymentSummaryCard({super.key, this.onRefresh});

//   String _formatCurrency(double amount) {
//     return '\$${amount.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     )}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PaymentProvider>(
//       builder: (context, paymentProvider, child) {
//         if (paymentProvider.state == PaymentState.loading && paymentProvider.paymentSummary == null) {
//           return const CustomCard(
//             child: Padding(
//               padding: EdgeInsets.all(40),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         }

//         if (paymentProvider.state == PaymentState.error) {
//           return CustomCard(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Icon(Icons.error_outline, color: AppColors.red500, size: 48),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Error loading payment summary',
//                     style: TextStyle(color: AppColors.red500),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: onRefresh,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         final currentMonthRevenue = paymentProvider.currentMonthRevenue;
//         final outstandingAmount = paymentProvider.outstandingAmount;
//         final overdueCount = paymentProvider.overduePaymentsCount;

//         return Row(
//           children: [
//             Expanded(
//               child: CustomCard(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppColors.primaryBlue, AppColors.gradientBlue],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'This Month',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.white.withOpacity(0.9),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatCurrency(currentMonthRevenue),
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.arrow_upward,
//                             size: 14,
//                             color: AppColors.white,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Current month revenue',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: CustomCard(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Outstanding',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.grey600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatCurrency(outstandingAmount),
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.grey800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             size: 14,
//                             color: AppColors.red500,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '$overdueCount overdue payments',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.red500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }