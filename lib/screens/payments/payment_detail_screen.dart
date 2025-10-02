import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import 'edit_payment_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentDetails();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadPaymentDetails() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      paymentProvider.fetchPaymentById(authProvider.token!, widget.paymentId);
    }
  }

  String _formatCurrency(double amount, String currency) {
    final symbols = {'USD': '£', 'GBP': '£', 'NGN': '₦'};
    final symbol = symbols[currency] ?? '£';
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
        return Icons.account_balance_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'cash':
        return Icons.money_rounded;
      case 'check':
        return Icons.receipt_rounded;
      default:
        return Icons.payment_rounded;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.red500),
            const SizedBox(width: 12),
            const Text('Delete Payment'),
          ],
        ),
        content: const Text('Are you sure you want to delete this payment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red500,
              foregroundColor: Colors.white,
            ),
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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.grey800),
          ),
        ),
        actions: [
          if (isAdmin) ...[
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _editPayment,
                icon: Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _deletePayment,
                icon: Icon(Icons.delete_rounded, color: AppColors.red500),
              ),
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
                  Icon(Icons.error_outline_rounded, color: AppColors.red500, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading payment details',
                    style: TextStyle(color: AppColors.red500, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadPaymentDetails,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
            child: Column(
              children: [
                // Hero Header with Status & Amount
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(payment.status),
                        _getStatusColor(payment.status).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(payment.status).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    payment.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _formatCurrency(payment.amount, payment.currency),
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                payment.paymentType.toUpperCase() + ' PAYMENT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (payment.lateFee > 0 || payment.discount > 0) ...[
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (payment.lateFee > 0) ...[
                                    _buildAmountChip(
                                      'Late Fee',
                                      _formatCurrency(payment.lateFee, payment.currency),
                                      Icons.warning_rounded,
                                    ),
                                    if (payment.discount > 0) const SizedBox(width: 16),
                                  ],
                                  if (payment.discount > 0)
                                    _buildAmountChip(
                                      'Discount',
                                      '-${_formatCurrency(payment.discount, payment.currency)}',
                                      Icons.local_offer_rounded,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Tenant Information Card
                        _buildModernCard(
                          icon: Icons.person_rounded,
                          title: 'Tenant Information',
                          color: AppColors.primaryBlue,
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.gradientBlue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    payment.tenant.firstName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.tenant.fullName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoChip(Icons.email_rounded, payment.tenant.email),
                                    if (payment.tenant.phone != null) ...[
                                      const SizedBox(height: 6),
                                      _buildInfoChip(Icons.phone_rounded, payment.tenant.phone!),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Property & Room Card
                        _buildModernCard(
                          icon: Icons.home_rounded,
                          title: 'Property & Room',
                          color: AppColors.secondaryTeal,
                          child: Column(
                            children: [
                              _buildPropertyInfoRow(
                                Icons.apartment_rounded,
                                'Property',
                                payment.property.name,
                              ),
                              const SizedBox(height: 16),
                              _buildPropertyInfoRow(
                                Icons.location_on_rounded,
                                'Address',
                                payment.property.address,
                              ),
                              if (payment.room != null) ...[
                                const SizedBox(height: 16),
                                _buildPropertyInfoRow(
                                  Icons.meeting_room_rounded,
                                  'Room',
                                  'Room ${payment.room!.roomNumber}',
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Details Card
                        _buildModernCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Payment Details',
                          color: AppColors.purple600,
                          child: Column(
                            children: [
                              _buildDetailGrid([
                                _DetailItem('Payment ID', widget.paymentId.substring(0, 12) + '...'),
                                _DetailItem('Currency', payment.currency),
                                _DetailItem('Payment Date', _formatDate(payment.paymentDate)),
                                _DetailItem('Due Date', _formatDate(payment.dueDate)),
                              ]),
                              if (payment.startDate != null && payment.endDate != null) ...[
                                const SizedBox(height: 16),
                                _buildDetailGrid([
                                  _DetailItem('Period Start', _formatDate(payment.startDate!)),
                                  _DetailItem('Period End', _formatDate(payment.endDate!)),
                                ]),
                              ],
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.purple600.withOpacity(0.1),
                                      AppColors.purple600.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.purple600.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.purple600.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getMethodIcon(payment.method),
                                        color: AppColors.purple600,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Payment Method',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            payment.method.replaceAll('_', ' ').toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (payment.description != null || payment.notes != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (payment.description != null) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.description_rounded, size: 18, color: AppColors.grey600),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Description',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          payment.description!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                      if (payment.description != null && payment.notes != null)
                                        const Divider(height: 24),
                                      if (payment.notes != null) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.note_rounded, size: 18, color: AppColors.grey600),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Notes',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          payment.notes!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Additional Information Card
                        _buildModernCard(
                          icon: Icons.info_outline_rounded,
                          title: 'Additional Information',
                          color: AppColors.amber500,
                          child: Column(
                            children: [
                              if (payment.processedBy != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.amber500.withOpacity(0.1),
                                        AppColors.amber500.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.amber500.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.amber500,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Processed By',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              payment.processedBy!.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildTimestampRow(
                                Icons.access_time_rounded,
                                'Created',
                                _formatDateTime(payment.createdAt),
                              ),
                              if (payment.updatedAt != payment.createdAt) ...[
                                const SizedBox(height: 12),
                                _buildTimestampRow(
                                  Icons.update_rounded,
                                  'Last Updated',
                                  _formatDateTime(payment.updatedAt),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildAmountChip(String label, String amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColors.grey800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.secondaryTeal),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimestampRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.amber500),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
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

//   String _formatCurrency(double amount, String currency) {
//     final symbols = {'USD': '\$', 'GBP': '£', 'NGN': '₦'};
//     final symbol = symbols[currency] ?? '\$';
//     return '$symbol${amount.toStringAsFixed(2)}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _formatDateTime(DateTime date) {
//     final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     final hours = date.hour.toString().padLeft(2, '0');
//     final minutes = date.minute.toString().padLeft(2, '0');
//     return '${months[date.month - 1]} ${date.day}, ${date.year} at $hours:$minutes';
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

//   IconData _getMethodIcon(String method) {
//     switch (method.toLowerCase()) {
//       case 'bank_transfer':
//         return Icons.account_balance;
//       case 'credit_card':
//         return Icons.credit_card;
//       case 'cash':
//         return Icons.money;
//       case 'check':
//         return Icons.receipt;
//       default:
//         return Icons.payment;
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
//             return const Center(child: Text('Payment not found'));
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Payment Status & Amount Card
//                 CustomCard(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [AppColors.primaryBlue, AppColors.gradientBlue],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             payment.status.toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _formatCurrency(payment.amount, payment.currency),
//                           style: const TextStyle(
//                             fontSize: 40,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           payment.paymentType.toUpperCase() + ' PAYMENT',
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                         if (payment.lateFee > 0 || payment.discount > 0) ...[
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               if (payment.lateFee > 0) ...[
//                                 Column(
//                                   children: [
//                                     Text(
//                                       'Late Fee',
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     Text(
//                                       _formatCurrency(payment.lateFee, payment.currency),
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 if (payment.discount > 0) const SizedBox(width: 32),
//                               ],
//                               if (payment.discount > 0)
//                                 Column(
//                                   children: [
//                                     Text(
//                                       'Discount',
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     Text(
//                                       '-${_formatCurrency(payment.discount, payment.currency)}',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                         ],
//                         if (payment.totalAmount != payment.amount) ...[
//                           const Divider(color: Colors.white24, height: 32),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Total Amount',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 _formatCurrency(payment.totalAmount, payment.currency),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
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
//                         Row(
//                           children: [
//                             Icon(Icons.person, color: AppColors.primaryBlue),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Tenant Information',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 24),
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 30,
//                               backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//                               child: Text(
//                                 payment.tenant.firstName[0].toUpperCase(),
//                                 style: TextStyle(
//                                   color: AppColors.primaryBlue,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 24,
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
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.email, size: 16, color: AppColors.grey600),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         payment.tenant.email,
//                                         style: TextStyle(fontSize: 14, color: AppColors.grey600),
//                                       ),
//                                     ],
//                                   ),
//                                   if (payment.tenant.phone != null) ...[
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.phone, size: 16, color: AppColors.grey600),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           payment.tenant.phone!,
//                                           style: TextStyle(fontSize: 14, color: AppColors.grey600),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
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

//                 // Property & Room Information
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.home, color: AppColors.primaryBlue),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Property & Room',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 24),
//                         _buildInfoRow(
//                           Icons.apartment,
//                           'Property',
//                           payment.property.name,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildInfoRow(
//                           Icons.location_on,
//                           'Address',
//                           payment.property.address,
//                         ),
//                         if (payment.room != null) ...[
//                           const SizedBox(height: 12),
//                           _buildInfoRow(
//                             Icons.meeting_room,
//                             'Room',
//                             'Room ${payment.room!.roomNumber}',
//                           ),
//                         ],
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
//                         Row(
//                           children: [
//                             Icon(Icons.receipt_long, color: AppColors.primaryBlue),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Payment Details',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 24),
//                         _buildDetailRow('Payment ID', widget.paymentId.substring(0, 12) + '...'),
//                         _buildDetailRow('Payment Date', _formatDate(payment.paymentDate)),
//                         _buildDetailRow('Due Date', _formatDate(payment.dueDate)),
//                         if (payment.startDate != null && payment.endDate != null) ...[
//                           _buildDetailRow('Period Start', _formatDate(payment.startDate!)),
//                           _buildDetailRow('Period End', _formatDate(payment.endDate!)),
//                         ],
//                         _buildDetailRow(
//                           'Method',
//                           payment.method.replaceAll('_', ' ').toUpperCase(),
//                           icon: _getMethodIcon(payment.method),
//                         ),
//                         _buildDetailRow('Currency', payment.currency),
//                         _buildDetailRow('Type', payment.paymentType.toUpperCase()),
//                         if (payment.description != null)
//                           _buildDetailRow('Description', payment.description!),
//                         if (payment.notes != null)
//                           _buildDetailRow('Notes', payment.notes!),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Processed By & Timestamps
//                 CustomCard(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.info_outline, color: AppColors.primaryBlue),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Additional Information',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 24),
//                         if (payment.processedBy != null) ...[
//                           _buildDetailRow(
//                             'Processed By',
//                             payment.processedBy!.fullName,
//                             icon: Icons.person_outline,
//                           ),
//                         ],
//                         _buildDetailRow(
//                           'Created',
//                           _formatDateTime(payment.createdAt),
//                           icon: Icons.access_time,
//                         ),
//                         if (payment.updatedAt != payment.createdAt)
//                           _buildDetailRow(
//                             'Last Updated',
//                             _formatDateTime(payment.updatedAt),
//                             icon: Icons.update,
//                           ),
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

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: AppColors.primaryBlue),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 12, color: AppColors.grey600),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value, {IconData? icon}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (icon != null) ...[
//             Icon(icon, size: 18, color: AppColors.grey600),
//             const SizedBox(width: 8),
//           ],
//           SizedBox(
//             width: icon != null ? 100 : 120,
//             child: Text(
//               label,
//               style: TextStyle(color: AppColors.grey600, fontSize: 14),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }