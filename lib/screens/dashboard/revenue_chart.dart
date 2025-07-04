import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_card.dart';

class RevenueChart extends StatelessWidget {
  final List<dynamic>? monthlyRevenue;

  const RevenueChart({super.key, this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    // Calculate maxY dynamically
    double maxY = 10000; // Default
    if (monthlyRevenue != null && monthlyRevenue!.isNotEmpty) {
      maxY = (monthlyRevenue!.map((e) => e['revenue'] as int).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();
      maxY = (maxY / 5000).ceil() * 5000; // Round up to nearest 5000
    }

    // Map month _id to index (0-based, assuming _id starts from 1 for Jan)
    final spots = monthlyRevenue != null
        ? monthlyRevenue!.asMap().entries.map((entry) {
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
                  'Monthly Revenue',
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
                            '\$${value.toInt()}',
                            style: TextStyle(color: AppColors.grey600, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (monthlyRevenue == null || monthlyRevenue!.isEmpty) {
                            return const Text('');
                          }
                          final index = value.toInt();
                          if (index >= 0 && index < monthlyRevenue!.length) {
                            final monthId = monthlyRevenue![index]['_id'] as int;
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            return Text(
                              months[monthId - 1], // _id starts from 1
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



// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../constants/colors.dart';
// import '../../widgets/custom_card.dart';

// class RevenueChart extends StatelessWidget {
//   const RevenueChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomCard(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Monthly Revenue',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'View All',
//                     style: TextStyle(color: AppColors.primaryBlue),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 5000,
//                     getDrawingHorizontalLine: (value) {
//                       return FlLine(
//                         color: AppColors.grey200,
//                         strokeWidth: 1,
//                       );
//                     },
//                   ),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             '\$${value.toInt()}',
//                             style: TextStyle(color: AppColors.grey600, fontSize: 12),
//                           );
//                         },
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
//                           return Text(
//                             months[value.toInt()],
//                             style: TextStyle(color: AppColors.grey600, fontSize: 12),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: const AxisTitles(),
//                     rightTitles: const AxisTitles(),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: const [
//                         FlSpot(0, 18500),
//                         FlSpot(1, 19200),
//                         FlSpot(2, 21000),
//                         FlSpot(3, 22400),
//                         FlSpot(4, 24000),
//                         FlSpot(5, 25600),
//                       ],
//                       isCurved: true,
//                       color: AppColors.primaryBlue,
//                       gradient: LinearGradient(
//                         colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//                       ),
//                       barWidth: 3,
//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
//                           radius: 4,
//                           color: AppColors.primaryBlue,
//                         ),
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.primaryBlue.withOpacity(0.2),
//                             AppColors.secondaryTeal.withOpacity(0.1),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                     ),
//                   ],
//                   minY: 0,
//                   maxY: 30000,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }