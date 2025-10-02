// Updated payment_trends_chart.dart (enhanced with full chart config like revenue)
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/revenue_analytics_provider.dart';
import '../../widgets/custom_card.dart';

class PaymentTrendsChart extends StatelessWidget {
  const PaymentTrendsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RevenueAnalyticsProvider>(context);

    // Calculate maxY dynamically
    double maxY = 10000; // Default
    if (provider.paymentTrends != null && provider.paymentTrends!.isNotEmpty) {
      maxY = (provider.paymentTrends!.map((e) => e['revenue'] as int).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();
      maxY = (maxY / 5000).ceil() * 5000; // Round up to nearest 5000
    }

    final spots = provider.paymentTrends != null
        ? provider.paymentTrends!.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return FlSpot(index.toDouble(), (data['revenue'] as int).toDouble());
          }).toList()
        : <FlSpot>[];

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Optional: Navigate to detailed view
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.grey200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '£${value.toInt()}',
                            style: TextStyle(color: AppColors.grey600, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (provider.paymentTrends == null || provider.paymentTrends!.isEmpty) {
                            return const Text('');
                          }
                          final index = value.toInt();
                          if (index >= 0 && index < provider.paymentTrends!.length) {
                            final monthData = provider.paymentTrends![index]['_id'] as Map<String, dynamic>;
                            final month = monthData['month'] as int;
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            return Text(
                              months[month - 1],
                              style: TextStyle(color: AppColors.grey600, fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primaryBlue,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.2),
                            AppColors.secondaryTeal.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}