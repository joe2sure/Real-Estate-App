import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
// import '../../widgets/custom_card.dart';
import '../../widgets/fab.dart';
import 'all_payment_screen.dart';
import 'payment_summary_card.dart';
import 'payment_detail_screen.dart';
import 'record_payment_form.dart';
import 'make_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadPaymentData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

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
      backgroundColor: Colors.transparent,
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.03),
                    AppColors.secondaryTeal.withOpacity(0.02),
                    AppColors.purple600.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              // Modern Header with glassmorphism
              Container(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.95),
                      AppColors.gradientBlue.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Colors.white70],
                              ).createShader(bounds),
                              child: const Text(
                                'Payments',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage transactions seamlessly',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (!isAdmin)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _showMakePaymentScreen,
                                  icon: const Icon(Icons.add_card, color: Colors.white),
                                  tooltip: 'Pay Rent',
                                ),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: IconButton(
                                onPressed: _loadPaymentData,
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadPaymentData();
                  },
                  color: AppColors.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Summary Cards
                          FadeTransition(
                            opacity: _animationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: PaymentSummaryCard(onRefresh: _loadPaymentData),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick Stats with modern cards
                          Consumer<PaymentProvider>(
                            builder: (context, paymentProvider, child) {
                              return FadeTransition(
                                opacity: _animationController,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildModernStatCard(
                                        'Total',
                                        '${paymentProvider.paymentSummary?.totalPayments ?? 0}',
                                        Icons.receipt_long_rounded,
                                        [AppColors.primaryBlue, AppColors.gradientBlue],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildModernStatCard(
                                        'Completed',
                                        '${paymentProvider.paymentSummary?.completedPayments ?? 0}',
                                        Icons.check_circle_rounded,
                                        [AppColors.secondaryTeal, const Color(0xFF10B981)],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildModernStatCard(
                                        'Pending',
                                        '${paymentProvider.paymentSummary?.pendingPayments ?? 0}',
                                        Icons.pending_rounded,
                                        [AppColors.amber500, const Color(0xFFFBBF24)],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Revenue Breakdown with modern design
                          Consumer<PaymentProvider>(
                            builder: (context, paymentProvider, child) {
                              if (paymentProvider.paymentSummary != null) {
                                return FadeTransition(
                                  opacity: _animationController,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          AppColors.blue100.withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryBlue.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primaryBlue.withOpacity(0.2),
                                                      AppColors.gradientBlue.withOpacity(0.1),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.trending_up_rounded,
                                                  color: AppColors.primaryBlue,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Revenue by Currency',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          ...paymentProvider.paymentSummary!.revenue.entries.map(
                                            (entry) => Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: _getCurrencyColor(entry.key).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _getCurrencyColor(entry.key).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                _getCurrencyColor(entry.key),
                                                                _getCurrencyColor(entry.key).withOpacity(0.6),
                                                              ],
                                                            ),
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: _getCurrencyColor(entry.key).withOpacity(0.5),
                                                                blurRadius: 8,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Text(
                                                          entry.key,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w600,
                                                            color: AppColors.grey800,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      _formatCurrency(entry.value, entry.key),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getCurrencyColor(entry.key),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Recent Activity Section with modern header
                          FadeTransition(
                            opacity: _animationController,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryBlue.withOpacity(0.2),
                                            AppColors.gradientBlue.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.history_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Recent Activity',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _showAllPayments,
                                  icon: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryBlue),
                                  label: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Recent Payments List
                          Consumer<PaymentProvider>(
                            builder: (context, paymentProvider, child) {
                              // Use recent payments if available, otherwise use regular payments
                              var availablePayments = paymentProvider.recentPayments.isNotEmpty
                                  ? paymentProvider.recentPayments
                                  : paymentProvider.payments;
                              
                              // Limit to 5 recent payments
                              final recentPayments = availablePayments.take(5).toList();
                              
                              // Check if we're loading and have no data yet
                              if (paymentProvider.state == PaymentState.loading && 
                                  recentPayments.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }
                              
                              // Show empty state if no payments at all
                              if (recentPayments.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.grey200.withOpacity(0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.receipt_long_outlined, color: AppColors.grey400, size: 64),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No recent activity',
                                        style: TextStyle(color: AppColors.grey600, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Payment transactions will appear here',
                                        style: TextStyle(color: AppColors.grey500, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: recentPayments.map((payment) {
                                  return FadeTransition(
                                    opacity: _animationController,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            _getStatusColor(payment.status).withOpacity(0.05),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _getStatusColor(payment.status).withOpacity(0.2),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getStatusColor(payment.status).withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PaymentDetailScreen(paymentId: payment.id),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        _getStatusColor(payment.status),
                                                        _getStatusColor(payment.status).withOpacity(0.7),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _getStatusColor(payment.status).withOpacity(0.3),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    payment.tenant.firstName[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        payment.tenant.fullName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.calendar_today, size: 12, color: AppColors.grey500),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            _formatDate(payment.paymentDate),
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: AppColors.grey600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      _formatCurrency(payment.amount, payment.currency),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            _getStatusColor(payment.status),
                                                            _getStatusColor(payment.status).withOpacity(0.8),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        payment.status.toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
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
              bottom: 90,
              right: 20,
              child: FloatingActionButtonWidget(
                onPressed: _showRecordPaymentForm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String label,
    String value,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    final symbols = {'USD': '£', 'GBP': '£', 'NGN': '₦'};
    final symbol = symbols[currency] ?? '£';
    return '$symbol${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/payment_provider.dart';
// import '../../widgets/custom_card.dart';
// import '../../widgets/fab.dart';
// import 'all_payment_screen.dart';
// import 'payment_summary_card.dart';
// import 'recent_payment_card.dart';
// import 'record_payment_form.dart';
// import 'make_payment_screen.dart';

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
//     final paymentProvider =
//         Provider.of<PaymentProvider>(context, listen: false);

//     if (authProvider.token != null) {
//       paymentProvider.fetchPaymentSummary(authProvider.token!);
//       paymentProvider.fetchRecentPayments(authProvider.token!);
//       paymentProvider.fetchPayments(authProvider.token!, refresh: true);
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
//               // Header
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Payments',
//                           style: TextStyle(
//                               fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         Row(
//                           children: [
//                             if (!isAdmin)
//                               TextButton.icon(
//                                 onPressed: _showMakePaymentScreen,
//                                 icon: Icon(Icons.payment,
//                                     color: AppColors.primaryBlue),
//                                 label: Text(
//                                   'Pay Rent',
//                                   style:
//                                       TextStyle(color: AppColors.primaryBlue),
//                                 ),
//                               ),
//                             IconButton(
//                               onPressed: _loadPaymentData,
//                               icon: Icon(Icons.refresh,
//                                   color: AppColors.primaryBlue),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Manage and track all payment transactions',
//                       style: TextStyle(fontSize: 14, color: AppColors.grey600),
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
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Payment Summary Cards
//                           PaymentSummaryCard(onRefresh: _loadPaymentData),
//                           const SizedBox(height: 24),

//                           // Quick Stats
//                           Consumer<PaymentProvider>(
//                             builder: (context, paymentProvider, child) {
//                               return Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildQuickStatCard(
//                                       'Total Payments',
//                                       '${paymentProvider.paymentSummary?.totalPayments ?? 0}',
//                                       Icons.receipt_long,
//                                       AppColors.primaryBlue,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildQuickStatCard(
//                                       'Completed',
//                                       '${paymentProvider.paymentSummary?.completedPayments ?? 0}',
//                                       Icons.check_circle,
//                                       AppColors.secondaryTeal,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildQuickStatCard(
//                                       'Pending',
//                                       '${paymentProvider.paymentSummary?.pendingPayments ?? 0}',
//                                       Icons.pending,
//                                       AppColors.amber500,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 24),

//                           // Revenue Breakdown
//                           Consumer<PaymentProvider>(
//                             builder: (context, paymentProvider, child) {
//                               if (paymentProvider.paymentSummary != null) {
//                                 return CustomCard(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text(
//                                           'Revenue by Currency',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         ...paymentProvider
//                                             .paymentSummary!.revenue.entries
//                                             .map(
//                                           (entry) => Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 12),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 8,
//                                                       height: 8,
//                                                       decoration: BoxDecoration(
//                                                         color:
//                                                             _getCurrencyColor(
//                                                                 entry.key),
//                                                         shape: BoxShape.circle,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 8),
//                                                     Text(
//                                                       entry.key,
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         color:
//                                                             AppColors.grey600,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Text(
//                                                   _formatCurrency(
//                                                       entry.value, entry.key),
//                                                   style: const TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                           const SizedBox(height: 24),

//                           // Recent Payments Section
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Recent Activity',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: _showAllPayments,
//                                 child: Text(
//                                   'View All',
//                                   style:
//                                       TextStyle(color: AppColors.primaryBlue),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           RecentPaymentCard(onViewAll: _showAllPayments),
//                           const SizedBox(height: 80),
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

//   Widget _buildQuickStatCard(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return CustomCard(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.grey600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getCurrencyColor(String currency) {
//     switch (currency) {
//       case 'USD':
//         return AppColors.primaryBlue;
//       case 'GBP':
//         return AppColors.secondaryTeal;
//       case 'NGN':
//         return AppColors.amber500;
//       default:
//         return AppColors.grey500;
//     }
//   }

//   String _formatCurrency(double amount, String currency) {
//     final symbols = {'USD': '\$', 'GBP': '£', 'NGN': '₦'};
//     final symbol = symbols[currency] ?? '\$';
//     return '$symbol${amount.toStringAsFixed(0).replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//         )}';
//   }
// }