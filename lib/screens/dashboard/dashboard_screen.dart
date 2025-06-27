import 'package:Peeman/screens/dashboard/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/fab.dart';
// import 'stats_card.dart';
import 'revenue_chart.dart';
import 'due_rent_card.dart';
import 'recent_activity_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                              'Welcome back,',
                              style: TextStyle(color: AppColors.grey600, fontSize: 14),
                            ),
                            const Text(
                              'James Davidson',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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
                          onPressed: () {},
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
                      children: const [
                        StatsCard(),
                        SizedBox(height: 24),
                        RevenueChart(),
                        SizedBox(height: 24),
                        DueRentCard(),
                        SizedBox(height: 24),
                        RecentActivityCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButtonWidget(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}