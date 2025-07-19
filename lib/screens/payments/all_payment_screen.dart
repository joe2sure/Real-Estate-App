import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_card.dart';
import 'payment_detail_screen.dart';

class AllPaymentsScreen extends StatefulWidget {
  const AllPaymentsScreen({super.key});

  @override
  State<AllPaymentsScreen> createState() => _AllPaymentsScreenState();
}

class _AllPaymentsScreenState extends State<AllPaymentsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  final List<String> _filters = [
    'all',
    'completed',
    'pending',
    'overdue',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMorePayments();
    }
  }

  void _loadPayments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      paymentProvider.fetchPayments(authProvider.token!, refresh: true);
    }
  }

  void _loadMorePayments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.token != null && paymentProvider.hasMorePayments) {
      paymentProvider.fetchPayments(authProvider.token!);
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

  void _navigateToPaymentDetail(String paymentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(paymentId: paymentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Payments'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey800,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: AppColors.grey100,
                      selectedColor: AppColors.primaryBlue.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : AppColors.grey600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Payments List
          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                if (paymentProvider.state == PaymentState.loading && paymentProvider.payments.isEmpty) {
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
                          'Error loading payments',
                          style: TextStyle(color: AppColors.red500, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadPayments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredPayments = paymentProvider.payments;
                if (_selectedFilter != 'all') {
                  filteredPayments = paymentProvider.getPaymentsByStatus(_selectedFilter);
                }

                if (filteredPayments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment_outlined, color: AppColors.grey400, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No payments found',
                          style: TextStyle(color: AppColors.grey600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadPayments();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPayments.length + (paymentProvider.hasMorePayments ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredPayments.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final payment = filteredPayments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: InkWell(
                            onTap: () => _navigateToPaymentDetail(payment.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: _getStatusColor(payment.status).withOpacity(0.1),
                                        child: Text(
                                          payment.tenant.firstName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(payment.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              payment.tenant.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              payment.property.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.grey600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatCurrency(payment.amount),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(payment.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              payment.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: _getStatusColor(payment.status),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Payment Date: ${_formatDate(payment.paymentDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      Text(
                                        payment.method.replaceAll('_', ' ').toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
