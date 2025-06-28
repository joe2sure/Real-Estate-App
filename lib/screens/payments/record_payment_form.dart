import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class RecordPaymentForm extends StatelessWidget {
  const RecordPaymentForm({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter payment details below',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tenant',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Select tenant',
                suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.grey400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Date',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '2025-06-27',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Select payment method',
                suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.grey400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notes (Optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
                   const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Add any additional notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Record Payment',
              onPressed: () {},
              isGradient: true,
            ),
          ],
        ),
      ),
    );
  }
}