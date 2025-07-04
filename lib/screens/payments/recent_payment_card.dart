import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../models/payment_model.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_card.dart';

class RecentPaymentCard extends StatelessWidget {
  const RecentPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = [
      Payment(
        tenantName: 'Sarah Williams',
        date: 'June 27, 2025',
        amount: 1350,
        image: Assets.tenant4,
      ),
      Payment(
        tenantName: 'Michael Chen',
        date: 'June 25, 2025',
        amount: 950,
        image: Assets.tenant5,
      ),
      Payment(
        tenantName: 'Emma Mitchell',
        date: 'June 22, 2025',
        amount: 1250,
        image: Assets.tenant1,
      ),
    ];

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
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...payments.map(
              (payment) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            payment.image,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.tenantName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    payment.date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${payment.amount}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}