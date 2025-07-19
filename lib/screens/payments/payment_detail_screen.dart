import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import 'edit_payment_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentDetails();
    });
  }

  void _loadPaymentDetails() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      paymentProvider.fetchPaymentById(authProvider.token!, widget.paymentId);
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  void _editPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPaymentScreen(paymentId: widget.paymentId),
      ),
    );
  }

  void _deletePayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      final success = await paymentProvider.deletePayment(authProvider.token!, widget.paymentId);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Payment deleted successfully',
          backgroundColor: AppColors.secondaryTeal,
          textColor: AppColors.white,
        );
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
          msg: paymentProvider.errorMessage ?? 'Failed to delete payment',
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey800,
        elevation: 0,
        actions: [
          if (isAdmin) ...[
            IconButton(
              onPressed: _editPayment,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: _deletePayment,
              icon: Icon(Icons.delete, color: AppColors.red500),
            ),
          ],
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.state == PaymentState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.state == PaymentState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red500, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading payment details',
                    style: TextStyle(color: AppColors.red500, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    onPressed: _loadPaymentDetails,
                    isOutline: true,
                  ),
                ],
              ),
            );
          }

          final payment = paymentProvider.selectedPayment;
          if (payment == null) {
            return const Center(
              child: Text('Payment not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Payment Status Card
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payment.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            payment.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(payment.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatCurrency(payment.amount),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (payment.lateFee > 0 || payment.discount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (payment.lateFee > 0) ...[
                                Text(
                                  'Late Fee: ${_formatCurrency(payment.lateFee)}',
                                  style: TextStyle(
                                    color: AppColors.red500,
                                    fontSize: 12,
                                  ),
                                ),
                                if (payment.discount > 0) const SizedBox(width: 16),
                              ],
                              if (payment.discount > 0)
                                Text(
                                  'Discount: ${_formatCurrency(payment.discount)}',
                                  style: TextStyle(
                                    color: AppColors.secondaryTeal,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (payment.totalAmount != payment.amount) ...[
                          const Divider(),
                          Text(
                            'Total: ${_formatCurrency(payment.totalAmount)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tenant Information
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tenant Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                              child: Text(
                                payment.tenant.firstName[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    payment.tenant.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  if (payment.tenant.unit != null)
                                    Text(
                                      'Unit: ${payment.tenant.unit}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Property Information
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Property Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.property.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    payment.property.address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Details
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Payment Date', _formatDate(payment.paymentDate)),
                        _buildDetailRow('Due Date', _formatDate(payment.dueDate)),
                        _buildDetailRow('Method', payment.method.replaceAll('_', ' ').toUpperCase()),
                        if (payment.description != null)
                          _buildDetailRow('Description', payment.description!),
                        if (payment.notes != null)
                          _buildDetailRow('Notes', payment.notes!),
                        if (payment.processedBy != null)
                          _buildDetailRow('Processed By', payment.processedBy!.fullName),
                        _buildDetailRow('Created', _formatDate(payment.createdAt)),
                        if (payment.updatedAt != payment.createdAt)
                          _buildDetailRow('Last Updated', _formatDate(payment.updatedAt)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
