import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/occupancy_provider.dart';
import 'dart:math' as math;

class OccupancyCard extends StatefulWidget {
  const OccupancyCard({super.key});

  @override
  State<OccupancyCard> createState() => _OccupancyCardState();
}

class _OccupancyCardState extends State<OccupancyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OccupancyProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.05),
            AppColors.secondaryTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricPatternPainter(
                  animation: _animation,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 24),
                  _buildOccupancyStats(provider),
                  const SizedBox(height: 32),
                  _buildTenantDistribution(provider),
                  const SizedBox(height: 32),
                  _buildTopPropertiesSection(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OccupancyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.gradientBlue],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Occupancy Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time insights',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: AppColors.green500.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: AppColors.green500.withOpacity(0.3)),
        //   ),
        //   child: Row(
        //     children: [
        //       Container(
        //         width: 6,
        //         height: 6,
        //         decoration: const BoxDecoration(
        //           color: AppColors.green500,
        //           shape: BoxShape.circle,
        //         ),
        //       ),
        //       const SizedBox(width: 6),
        //       const Text(
        //         'Live',
        //         style: TextStyle(
        //           color: AppColors.green500,
        //           fontSize: 12,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildOccupancyStats(OccupancyProvider provider) {
    final rateValue = provider.occupancyRate;
    final rate = (rateValue is int) ? rateValue!.toDouble() : (rateValue ?? 0.0) as double;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.gradientBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Rate',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${rate.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: rate / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Icon(
                    rate >= 80 ? Icons.trending_up : Icons.trending_flat,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantDistribution(OccupancyProvider provider) {
    final distribution = provider.tenantDistribution ?? [];
    
    if (distribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tenant Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: distribution.map((dist) {
                final id = dist['_id'] as String;
                final count = dist['count'] as int;
                Color color;
                IconData icon;
                String label;
                
                switch (id) {
                  case 'paid':
                    color = AppColors.green500;
                    icon = Icons.check_circle;
                    label = 'Paid';
                    break;
                  case 'overdue':
                    color = AppColors.red500;
                    icon = Icons.warning;
                    label = 'Overdue';
                    break;
                  case 'due_soon':
                    color = AppColors.amber500;
                    icon = Icons.schedule;
                    label = 'Due Soon';
                    break;
                  default:
                    color = AppColors.grey500;
                    icon = Icons.info;
                    label = id;
                }

                final cardWidth = (constraints.maxWidth - 16) / 3;

                return Container(
                  width: cardWidth,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopPropertiesSection(OccupancyProvider provider) {
    final properties = provider.topProperties ?? [];
    
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Properties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.purple100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${properties.length} Properties',
                style: const TextStyle(
                  color: AppColors.purple600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...properties.asMap().entries.map((entry) {
          final index = entry.key;
          final prop = entry.value;
          final occupancyRate = (prop['occupancyRate'] is int) 
              ? (prop['occupancyRate'] as int).toDouble() 
              : prop['occupancyRate'] as double;
          final monthlyIncome = prop['monthlyIncome'] is double 
              ? (prop['monthlyIncome'] as double).toInt() 
              : prop['monthlyIncome'] as int;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.8),
                        AppColors.secondaryTeal.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prop['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.payment, size: 14, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          Text(
                            '£${monthlyIncome.toStringAsFixed(0)}/mo',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: occupancyRate >= 80
                              ? [AppColors.green500, AppColors.secondaryTeal]
                              : occupancyRate >= 60
                                  ? [AppColors.amber500, AppColors.amber500]
                                  : [AppColors.red500, AppColors.red600],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (occupancyRate >= 80
                                    ? AppColors.green500
                                    : occupancyRate >= 60
                                        ? AppColors.amber500
                                        : AppColors.red500)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${occupancyRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final Animation<double> animation;

  GeometricPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 50.0;
    final offset = animation.value * spacing;

    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      for (double j = -spacing; j < size.height + spacing; j += spacing) {
        final x = i + (offset % spacing);
        final y = j + (offset % spacing);
        canvas.drawCircle(Offset(x, y), 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GeometricPatternPainter oldDelegate) => true;
}




// // Updated occupancy_card.dart (added pie chart for attractive design)
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/occupancy_provider.dart';
// import '../../widgets/custom_card.dart';

// class OccupancyCard extends StatelessWidget {
//   const OccupancyCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OccupancyProvider>(context);

//     final pieSections = provider.tenantDistribution?.map((dist) {
//       final id = dist['_id'] as String;
//       final count = dist['count'] as int;
//       Color color;
//       switch (id) {
//         case 'paid':
//           color = AppColors.green500;
//           break;
//         case 'overdue':
//           color = AppColors.red500;
//           break;
//         case 'due_soon':
//           color = AppColors.amber500;
//           break;
//         default:
//           color = AppColors.grey500;
//       }
//       return PieChartSectionData(
//         value: count.toDouble(),
//         color: color,
//         title: id,
//         radius: 50,
//         titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
//       );
//     }).toList() ?? [];

//     return CustomCard(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Occupancy Overview',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Rate: ${provider.occupancyRate?.toStringAsFixed(2) ?? '0'}%',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // Optional: Navigate to detailed view
//                   },
//                   child: Text(
//                     'View Details',
//                     style: TextStyle(color: AppColors.primaryBlue),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: pieSections,
//                   centerSpaceRadius: 40,
//                   sectionsSpace: 2,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Top Properties',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: provider.topProperties?.length ?? 0,
//               itemBuilder: (context, index) {
//                 final prop = provider.topProperties![index];
//                 return ListTile(
//                   title: Text(prop['name']),
//                   subtitle: Text('Occupancy: ${prop['occupancyRate'].toStringAsFixed(2)}% | Income: £${prop['monthlyIncome']}'),
//                   trailing: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: AppColors.blue100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Center(
//                       child: Text(
//                         '${prop['occupancyRate'].toStringAsFixed(0)}%',
//                         style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }