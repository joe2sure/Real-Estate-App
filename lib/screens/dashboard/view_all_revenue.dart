// New view_all_revenue.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ViewAllRevenueScreen extends StatelessWidget {
  final List<dynamic>? monthlyRevenue;

  const ViewAllRevenueScreen({super.key, this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    final spots = monthlyRevenue?.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), (data['revenue'] as int).toDouble());
    }).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Revenue Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 300, // Larger chart
              child: LineChart(
                LineChartData(
                  lineBarsData: [LineChartBarData(spots: spots)],
                  // Similar config, but larger
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: monthlyRevenue?.length ?? 0,
                itemBuilder: (context, index) {
                  final data = monthlyRevenue![index];
                  final monthId = data['_id'] as int;
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  return ListTile(
                    title: Text(months[monthId - 1]),
                    subtitle: Text('Revenue: £${data['revenue']} | Count: ${data['count']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}