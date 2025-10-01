import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/fab.dart';
import 'all_payment_screen.dart';
import 'payment_summary_card.dart';
import 'recent_payment_card.dart';
import 'record_payment_form.dart';
import 'make_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentData();
    });
  }

  void _loadPaymentData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.token != null) {
      paymentProvider.fetchPaymentSummary(authProvider.token!);
      paymentProvider.fetchRecentPayments(authProvider.token!);
      paymentProvider.fetchPayments(authProvider.token!, refresh: true);
    }
  }

  void _showRecordPaymentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const RecordPaymentForm(),
    );
  }

  void _showMakePaymentScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MakePaymentScreen(),
      ),
    );
  }

  void _showAllPayments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllPaymentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payments',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            if (!isAdmin)
                              TextButton.icon(
                                onPressed: _showMakePaymentScreen,
                                icon: Icon(Icons.payment,
                                    color: AppColors.primaryBlue),
                                label: Text(
                                  'Pay Rent',
                                  style:
                                      TextStyle(color: AppColors.primaryBlue),
                                ),
                              ),
                            IconButton(
                              onPressed: _loadPaymentData,
                              icon: Icon(Icons.refresh,
                                  color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage and track all payment transactions',
                      style: TextStyle(fontSize: 14, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadPaymentData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Summary Cards
                          PaymentSummaryCard(onRefresh: _loadPaymentData),
                          const SizedBox(height: 24),

                          // Quick Stats
                          Consumer<PaymentProvider>(
                            builder: (context, paymentProvider, child) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickStatCard(
                                      'Total Payments',
                                      '${paymentProvider.paymentSummary?.totalPayments ?? 0}',
                                      Icons.receipt_long,
                                      AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickStatCard(
                                      'Completed',
                                      '${paymentProvider.paymentSummary?.completedPayments ?? 0}',
                                      Icons.check_circle,
                                      AppColors.secondaryTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickStatCard(
                                      'Pending',
                                      '${paymentProvider.paymentSummary?.pendingPayments ?? 0}',
                                      Icons.pending,
                                      AppColors.amber500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Revenue Breakdown
                          Consumer<PaymentProvider>(
                            builder: (context, paymentProvider, child) {
                              if (paymentProvider.paymentSummary != null) {
                                return CustomCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Revenue by Currency',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...paymentProvider
                                            .paymentSummary!.revenue.entries
                                            .map(
                                          (entry) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getCurrencyColor(
                                                                entry.key),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      entry.key,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            AppColors.grey600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _formatCurrency(
                                                      entry.value, entry.key),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Recent Payments Section
                          Row(
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
                                onPressed: _showAllPayments,
                                child: Text(
                                  'View All',
                                  style:
                                      TextStyle(color: AppColors.primaryBlue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RecentPaymentCard(onViewAll: _showAllPayments),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isAdmin)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButtonWidget(
                onPressed: _showRecordPaymentForm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCurrencyColor(String currency) {
    switch (currency) {
      case 'USD':
        return AppColors.primaryBlue;
      case 'GBP':
        return AppColors.secondaryTeal;
      case 'NGN':
        return AppColors.amber500;
      default:
        return AppColors.grey500;
    }
  }

  String _formatCurrency(double amount, String currency) {
    final symbols = {'USD': '\$', 'GBP': '£', 'NGN': '₦'};
    final symbol = symbols[currency] ?? '\$';
    return '$symbol${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // String _formatCurrency(double amount, String currency) {
  //   final symbols = {'USD': '\, 'GBP': '£', 'NGN': '₦'};
  //   final symbol = symbols[currency] ?? '\;
  //   return '$symbol${amount.toStringAsFixed(0).replaceAllMapped(
  //     RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  //     (Match m) => '${m[1]},',
  //   )}';
  // }
}





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/payment_provider.dart';
// import '../../widgets/bottom_navigation.dart';
// import '../../widgets/fab.dart';
// import 'all_payment_screen.dart';
// import 'payment_summary_card.dart';
// import 'recent_payment_card.dart';
// import 'record_payment_form.dart';
// import 'make_payment_screen.dart';
// // import 'all_payments_screen.dart';

// class PaymentsScreen extends StatefulWidget {
//   const PaymentsScreen({super.key});

//   @override
//   State<PaymentsScreen> createState() => _PaymentsScreenState();
// }

// class _PaymentsScreenState extends State<PaymentsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPaymentData();
//     });
//   }

//   void _loadPaymentData() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
//     if (authProvider.token != null) {
//       paymentProvider.fetchPaymentSummary(authProvider.token!);
//       paymentProvider.fetchRecentPayments(authProvider.token!);
//     }
//   }

//   void _showRecordPaymentForm() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => const RecordPaymentForm(),
//     );
//   }

//   void _showMakePaymentScreen() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const MakePaymentScreen(),
//       ),
//     );
//   }

//   void _showAllPayments() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const AllPaymentsScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 color: AppColors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Payments',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         if (!isAdmin)
//                           TextButton.icon(
//                             onPressed: _showMakePaymentScreen,
//                             icon: Icon(Icons.payment, color: AppColors.primaryBlue),
//                             label: Text(
//                               'Pay Rent',
//                               style: TextStyle(color: AppColors.primaryBlue),
//                             ),
//                           ),
//                         TextButton(
//                           onPressed: _showAllPayments,
//                           child: Text(
//                             'View All',
//                             style: TextStyle(color: AppColors.primaryBlue),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     _loadPaymentData();
//                   },
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           PaymentSummaryCard(onRefresh: _loadPaymentData),
//                           const SizedBox(height: 24),
//                           RecentPaymentCard(onViewAll: _showAllPayments),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (isAdmin)
//             Positioned(
//               bottom: 80,
//               right: 16,
//               child: FloatingActionButtonWidget(
//                 onPressed: _showRecordPaymentForm,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }