import 'package:flutter/material.dart';
import '../../constants/colors.dart';
// import 'package:provider/provider.dart';
// import '../../providers/app_state.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/fab.dart';
import 'payment_summary_card.dart';
import 'recent_payment_card.dart';
import 'record_payment_form.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        SizedBox(height: 24),
                        RecordPaymentForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButtonWidget(),
          ),
        ],
      ),
      // bottomNavigationBar: const BottomNavigation(),
    );
  }
}