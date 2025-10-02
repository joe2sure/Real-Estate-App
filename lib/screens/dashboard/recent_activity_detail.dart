// New recent_activity_detail.dart
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class RecentActivityDetailScreen extends StatelessWidget {
  final dynamic activity;

  const RecentActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // Assuming activity is a payment object; adjust if tenant
    final tenant = activity['tenant'];
    final property = activity['property'];
    final amount = activity['amount'];
    final paymentDate = activity['paymentDate'];
    final dueDate = activity['dueDate'];
    final method = activity['method'];
    final paymentType = activity['paymentType'];
    final status = activity['status'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tenant: ${tenant['firstName']} ${tenant['lastName']}'),
            Text('Property: ${property['name']}'),
            Text('Amount: £$amount'),
            Text('Payment Date: $paymentDate'),
            Text('Due Date: $dueDate'),
            Text('Method: ${method.replaceAll('_', ' ').toUpperCase()}'),
            Text('Type: ${paymentType.toUpperCase()}'),
            Text('Status: ${status.toUpperCase()}'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}