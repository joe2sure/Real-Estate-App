import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';

class RecentActivityDetailScreen extends StatefulWidget {
  final dynamic activity;

  const RecentActivityDetailScreen({super.key, required this.activity});

  @override
  State<RecentActivityDetailScreen> createState() => _RecentActivityDetailScreenState();
}

class _RecentActivityDetailScreenState extends State<RecentActivityDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppColors.green500;
      case 'pending':
        return AppColors.amber500;
      case 'overdue':
      case 'failed':
        return AppColors.red500;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = widget.activity['tenant'];
    final property = widget.activity['property'];
    final amount = widget.activity['amount'];
    final paymentDate = widget.activity['paymentDate'];
    final dueDate = widget.activity['dueDate'];
    final method = widget.activity['method'];
    final paymentType = widget.activity['paymentType'];
    final status = widget.activity['status'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroCard(amount, status),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Payment Details',
                              Icons.receipt_long,
                              [
                                _buildInfoRow('Type', _formatPaymentType(paymentType), Icons.category),
                                _buildInfoRow('Method', _formatMethod(method), Icons.payment),
                                _buildInfoRow('Status', _formatStatus(status), _getStatusIcon(status), 
                                    valueColor: _getStatusColor(status)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoSection(
                              'Timeline',
                              Icons.access_time,
                              [
                                _buildInfoRow('Payment Date', _formatDate(paymentDate), Icons.calendar_today),
                                _buildInfoRow('Due Date', _formatDate(dueDate), Icons.event),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoSection(
                              'Tenant Information',
                              Icons.person,
                              [
                                _buildInfoRow('Name', '${tenant['firstName']} ${tenant['lastName']}', Icons.badge),
                                _buildInfoRow('Email', tenant['email'] ?? 'N/A', Icons.email),
                                _buildInfoRow('Phone', tenant['phone'] ?? 'N/A', Icons.phone),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoSection(
                              'Property Details',
                              Icons.home,
                              [
                                _buildInfoRow('Property', property['name'], Icons.apartment),
                                _buildInfoRow('Address', property['address'] ?? 'N/A', Icons.location_on),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(int amount, String status) {
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.gradientBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Amount',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(status), color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatStatus(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '£',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                amount.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Transaction Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.1),
                        AppColors.secondaryTeal.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.grey600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.gradientBlue],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle download receipt
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Download Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue),
          ),
          child: IconButton(
            onPressed: () {
              // Handle share
            },
            icon: const Icon(Icons.share, color: AppColors.primaryBlue),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  String _formatPaymentType(String type) {
    return type.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  String _formatMethod(String method) {
    return method.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  String _formatStatus(String status) {
    return status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : '';
  }
}




// // New recent_activity_detail.dart
// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';

// class RecentActivityDetailScreen extends StatelessWidget {
//   final dynamic activity;

//   const RecentActivityDetailScreen({super.key, required this.activity});

//   @override
//   Widget build(BuildContext context) {
//     // Assuming activity is a payment object; adjust if tenant
//     final tenant = activity['tenant'];
//     final property = activity['property'];
//     final amount = activity['amount'];
//     final paymentDate = activity['paymentDate'];
//     final dueDate = activity['dueDate'];
//     final method = activity['method'];
//     final paymentType = activity['paymentType'];
//     final status = activity['status'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Activity Details'),
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Tenant: ${tenant['firstName']} ${tenant['lastName']}'),
//             Text('Property: ${property['name']}'),
//             Text('Amount: £$amount'),
//             Text('Payment Date: $paymentDate'),
//             Text('Due Date: $dueDate'),
//             Text('Method: ${method.replaceAll('_', ' ').toUpperCase()}'),
//             Text('Type: ${paymentType.toUpperCase()}'),
//             Text('Status: ${status.toUpperCase()}'),
//             // Add more fields as needed
//           ],
//         ),
//       ),
//     );
//   }
// }