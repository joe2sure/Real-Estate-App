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

  String _formatCurrency(double amount, String currency) {
    final symbols = {'USD': '\$', 'GBP': '£', 'NGN': '₦'};
    final symbol = symbols[currency] ?? '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hours:$minutes';
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

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'check':
        return Icons.receipt;
      default:
        return Icons.payment;
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
            return const Center(child: Text('Payment not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Payment Status & Amount Card
                CustomCard(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            payment.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatCurrency(payment.amount, payment.currency),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          payment.paymentType.toUpperCase() + ' PAYMENT',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (payment.lateFee > 0 || payment.discount > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (payment.lateFee > 0) ...[
                                Column(
                                  children: [
                                    Text(
                                      'Late Fee',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(payment.lateFee, payment.currency),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (payment.discount > 0) const SizedBox(width: 32),
                              ],
                              if (payment.discount > 0)
                                Column(
                                  children: [
                                    Text(
                                      'Discount',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '-${_formatCurrency(payment.discount, payment.currency)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                        if (payment.totalAmount != payment.amount) ...[
                          const Divider(color: Colors.white24, height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _formatCurrency(payment.totalAmount, payment.currency),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                        Row(
                          children: [
                            Icon(Icons.person, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            const Text(
                              'Tenant Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                              child: Text(
                                payment.tenant.firstName[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.email, size: 16, color: AppColors.grey600),
                                      const SizedBox(width: 4),
                                      Text(
                                        payment.tenant.email,
                                        style: TextStyle(fontSize: 14, color: AppColors.grey600),
                                      ),
                                    ],
                                  ),
                                  if (payment.tenant.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 16, color: AppColors.grey600),
                                        const SizedBox(width: 4),
                                        Text(
                                          payment.tenant.phone!,
                                          style: TextStyle(fontSize: 14, color: AppColors.grey600),
                                        ),
                                      ],
                                    ),
                                  ],
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

                // Property & Room Information
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            const Text(
                              'Property & Room',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.apartment,
                          'Property',
                          payment.property.name,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Address',
                          payment.property.address,
                        ),
                        if (payment.room != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.meeting_room,
                            'Room',
                            'Room ${payment.room!.roomNumber}',
                          ),
                        ],
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
                        Row(
                          children: [
                            Icon(Icons.receipt_long, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            const Text(
                              'Payment Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('Payment ID', widget.paymentId.substring(0, 12) + '...'),
                        _buildDetailRow('Payment Date', _formatDate(payment.paymentDate)),
                        _buildDetailRow('Due Date', _formatDate(payment.dueDate)),
                        if (payment.startDate != null && payment.endDate != null) ...[
                          _buildDetailRow('Period Start', _formatDate(payment.startDate!)),
                          _buildDetailRow('Period End', _formatDate(payment.endDate!)),
                        ],
                        _buildDetailRow(
                          'Method',
                          payment.method.replaceAll('_', ' ').toUpperCase(),
                          icon: _getMethodIcon(payment.method),
                        ),
                        _buildDetailRow('Currency', payment.currency),
                        _buildDetailRow('Type', payment.paymentType.toUpperCase()),
                        if (payment.description != null)
                          _buildDetailRow('Description', payment.description!),
                        if (payment.notes != null)
                          _buildDetailRow('Notes', payment.notes!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Processed By & Timestamps
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            const Text(
                              'Additional Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (payment.processedBy != null) ...[
                          _buildDetailRow(
                            'Processed By',
                            payment.processedBy!.fullName,
                            icon: Icons.person_outline,
                          ),
                        ],
                        _buildDetailRow(
                          'Created',
                          _formatDateTime(payment.createdAt),
                          icon: Icons.access_time,
                        ),
                        if (payment.updatedAt != payment.createdAt)
                          _buildDetailRow(
                            'Last Updated',
                            _formatDateTime(payment.updatedAt),
                            icon: Icons.update,
                          ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.grey600),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon != null ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(color: AppColors.grey600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/payment_provider.dart';
// import '../../widgets/custom_card.dart';
// import '../../widgets/custom_button.dart';
// import 'edit_payment_screen.dart';

// class PaymentDetailScreen extends StatefulWidget {
//   final String paymentId;

//   const PaymentDetailScreen({super.key, required this.paymentId});

//   @override
//   State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
// }

// class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPaymentDetails();
//     });
//   }

//   void _loadPaymentDetails() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
//     if (authProvider.token != null) {
//       paymentProvider.fetchPaymentById(authProvider.token!, widget.paymentId);
//     }
//   }

//   String _formatCurrency(double amount) {
//     return '\$${amount.toStringAsFixed(2)}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return AppColors.secondaryTeal;
//       case 'pending':
//         return AppColors.amber500;
//       case 'overdue':
//         return AppColors.red500;
//       default:
//         return AppColors.grey500;
//     }
//   }

//   void _editPayment() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => EditPaymentScreen(paymentId: widget.paymentId),
//       ),
//     );
//   }

//   void _deletePayment() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Payment'),
//         content: const Text('Are you sure you want to delete this payment? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: AppColors.red500),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

//       final success = await paymentProvider.deletePayment(authProvider.token!, widget.paymentId);

//       if (success) {
//         Fluttertoast.showToast(
//           msg: 'Payment deleted successfully',
//           backgroundColor: AppColors.secondaryTeal,
//           textColor: AppColors.white,
//         );
//         Navigator.of(context).pop();
//       } else {
//         Fluttertoast.showToast(
//           msg: paymentProvider.errorMessage ?? 'Failed to delete payment',
//           backgroundColor: AppColors.red500,
//           textColor: AppColors.white,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Details'),
//         backgroundColor: AppColors.white,
//         foregroundColor: AppColors.grey800,
//         elevation: 0,
//         actions: [
//           if (isAdmin) ...[
//             IconButton(
//               onPressed: _editPayment,
//               icon: const Icon(Icons.edit),
//             ),
//             IconButton(
//               onPressed: _deletePayment,
//               icon: Icon(Icons.delete, color: AppColors.red500),
//             ),
//           ],
//         ],
//       ),
//       body: Consumer<PaymentProvider>(
//         builder: (context, paymentProvider, child) {
//           if (paymentProvider.state == PaymentState.loading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (paymentProvider.state == PaymentState.error) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, color: AppColors.red500, size: 64),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading payment details',
//                     style: TextStyle(color: AppColors.red500, fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),
//                   CustomButton(
//                     text: 'Retry',
//                     onPressed: _loadPaymentDetails,
//                     isOutline: true,
//                   ),
//                 ],
//               ),
//             );
//           }

//           final payment = paymentProvider.selectedPayment;
//           if (payment == null) {
//             return const Center(
//               child: Text('Payment not found'),
//             );
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Payment Status Card
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(payment.status).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             payment.status.toUpperCase(),
//                             style: TextStyle(
//                               color: _getStatusColor(payment.status),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _formatCurrency(payment.amount),
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         if (payment.lateFee > 0 || payment.discount > 0) ...[
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               if (payment.lateFee > 0) ...[
//                                 Text(
//                                   'Late Fee: ${_formatCurrency(payment.lateFee)}',
//                                   style: TextStyle(
//                                     color: AppColors.red500,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 if (payment.discount > 0) const SizedBox(width: 16),
//                               ],
//                               if (payment.discount > 0)
//                                 Text(
//                                   'Discount: ${_formatCurrency(payment.discount)}',
//                                   style: TextStyle(
//                                     color: AppColors.secondaryTeal,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                         if (payment.totalAmount != payment.amount) ...[
//                           const Divider(),
//                           Text(
//                             'Total: ${_formatCurrency(payment.totalAmount)}',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Tenant Information
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Tenant Information',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//                               child: Text(
//                                 payment.tenant.firstName[0].toUpperCase(),
//                                 style: TextStyle(
//                                   color: AppColors.primaryBlue,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     payment.tenant.fullName,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     payment.tenant.email,
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: AppColors.grey600,
//                                     ),
//                                   ),
//                                   if (payment.tenant.unit != null)
//                                     Text(
//                                       'Unit: ${payment.tenant.unit}',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: AppColors.grey600,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Property Information
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Property Information',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               color: AppColors.primaryBlue,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     payment.property.name,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     payment.property.address,
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: AppColors.grey600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Payment Details
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Payment Details',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildDetailRow('Payment Date', _formatDate(payment.paymentDate)),
//                         _buildDetailRow('Due Date', _formatDate(payment.dueDate)),
//                         _buildDetailRow('Method', payment.method.replaceAll('_', ' ').toUpperCase()),
//                         if (payment.description != null)
//                           _buildDetailRow('Description', payment.description!),
//                         if (payment.notes != null)
//                           _buildDetailRow('Notes', payment.notes!),
//                         if (payment.processedBy != null)
//                           _buildDetailRow('Processed By', payment.processedBy!.fullName),
//                         _buildDetailRow('Created', _formatDate(payment.createdAt)),
//                         if (payment.updatedAt != payment.createdAt)
//                           _buildDetailRow('Last Updated', _formatDate(payment.updatedAt)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: AppColors.grey600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
