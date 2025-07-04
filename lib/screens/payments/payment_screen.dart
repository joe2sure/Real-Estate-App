import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/fab.dart';
import 'payment_summary_card.dart';
import 'recent_payment_card.dart';
import 'record_payment_form.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  void _showRecordPaymentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const RecordPaymentForm(),
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
                child: const Text(
                  'Payments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        PaymentSummaryCard(),
                        SizedBox(height: 24),
                        RecentPaymentCard(),
                      ],
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