import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class PaymentDebugScreen extends StatelessWidget {
  const PaymentDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Debug'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey800,
        elevation: 0,
      ),
      body: Consumer2<PaymentProvider, AuthProvider>(
        builder: (context, paymentProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Provider State',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('State: ${paymentProvider.state}'),
                        Text('Error: ${paymentProvider.errorMessage ?? 'None'}'),
                        Text('Total Payments: ${paymentProvider.payments.length}'),
                        Text('Recent Payments: ${paymentProvider.recentPayments.length}'),
                        Text('Has More: ${paymentProvider.hasMorePayments}'),
                        Text('Current Page: ${paymentProvider.currentPage}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auth State',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Is Logged In: ${authProvider.isLoggedIn}'),
                        Text('User Role: ${authProvider.currentUser?.role ?? 'None'}'),
                        Text('Token Available: ${authProvider.token != null}'),
                        if (authProvider.token != null)
                          Text('Token Length: ${authProvider.token!.length}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (paymentProvider.payments.isNotEmpty) ...[
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Payments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...paymentProvider.payments.take(5).map((payment) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${payment.tenant.fullName} - \$${payment.amount} - ${payment.status}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (authProvider.token != null) {
                      paymentProvider.fetchPayments(authProvider.token!, refresh: true);
                    }
                  },
                  child: const Text('Refresh Payments'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
