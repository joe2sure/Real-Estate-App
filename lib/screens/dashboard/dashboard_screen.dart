import 'package:Peeman/providers/due_rent_provider.dart';
import 'package:Peeman/screens/dashboard/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_avatar.dart';
import 'due_rent_card.dart';
import 'notification_screen.dart';
import 'recent_activity_card.dart';
import 'revenue_chart.dart';
// import 'stats_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = user?.role == 'admin';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()..fetchDashboardData(context)),
        ChangeNotifierProvider(create: (_) => DueRentProvider()..loadTenants(context: context)),
      ],
      child: Scaffold(
        body: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, child) {

            if (dashboardProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dashboardProvider.errorMessage!,
                      style: TextStyle(color: AppColors.red500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          dashboardProvider.fetchDashboardData(context),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }


            return Skeletonizer(
              enabled: dashboardProvider.isLoading,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                    color: AppColors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomAvatar(
                              imageUrl: Assets.user,
                              fallbackText: 'JD',
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user?.firstName ?? "Guest"}!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications),
                              color: AppColors.grey600,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.red500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            StatsCard(stats: dashboardProvider.stats),
                            const SizedBox(height: 24),
                            RevenueChart(
                              monthlyRevenue:
                                  dashboardProvider.monthlyRevenue,
                            ),
                            const SizedBox(height: 24),
                            const DueRentCard(),
                            const SizedBox(height: 24),
                            RecentActivityCard(
                              recentPayments:
                                  dashboardProvider.recentPayments,
                              recentTenants:
                                  dashboardProvider.recentTenants,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }}





// import 'package:Peeman/screens/dashboard/notification_screen.dart';
// import 'package:Peeman/screens/dashboard/stat_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_avatar.dart';
// import 'revenue_chart.dart';
// import 'due_rent_card.dart';
// import 'recent_activity_card.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//         final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;
//     final isAdmin = user?.role == 'admin';
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 color: AppColors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         CustomAvatar(
//                           imageUrl: Assets.user,
//                           fallbackText: 'JD',
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                                             Text(
//                   'Welcome, ${user?.firstName ?? "Guest"}!',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Stack(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.notifications),
//                           color: AppColors.grey600,
//                           onPressed: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => const NotificationScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: AppColors.red500,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: const [
//                         StatsCard(),
//                         SizedBox(height: 24),
//                         RevenueChart(),
//                         SizedBox(height: 24),
//                         DueRentCard(),
//                         SizedBox(height: 24),
//                         RecentActivityCard(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }