import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/fab.dart';
import 'all_payment_screen.dart';
import 'payment_summary_card.dart';
import 'recent_payment_card.dart';
import 'record_payment_form.dart';
import 'make_payment_screen.dart';
// import 'all_payments_screen.dart';

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
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      paymentProvider.fetchPaymentSummary(authProvider.token!);
      paymentProvider.fetchRecentPayments(authProvider.token!);
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
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                color: AppColors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        if (!isAdmin)
                          TextButton.icon(
                            onPressed: _showMakePaymentScreen,
                            icon: Icon(Icons.payment, color: AppColors.primaryBlue),
                            label: Text(
                              'Pay Rent',
                              style: TextStyle(color: AppColors.primaryBlue),
                            ),
                          ),
                        TextButton(
                          onPressed: _showAllPayments,
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          PaymentSummaryCard(onRefresh: _loadPaymentData),
                          const SizedBox(height: 24),
                          RecentPaymentCard(onViewAll: _showAllPayments),
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
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/bottom_navigation.dart';
// import '../../widgets/fab.dart';
// import 'payment_summary_card.dart';
// import 'recent_payment_card.dart';
// import 'record_payment_form.dart';

// class PaymentsScreen extends StatefulWidget {
//   const PaymentsScreen({super.key});

//   @override
//   State<PaymentsScreen> createState() => _PaymentsScreenState();
// }

// class _PaymentsScreenState extends State<PaymentsScreen> {
//   void _showRecordPaymentForm() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => const RecordPaymentForm(),
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
//                 child: const Text(
//                   'Payments',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: const [
//                         PaymentSummaryCard(),
//                         SizedBox(height: 24),
//                         RecentPaymentCard(),
//                       ],
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