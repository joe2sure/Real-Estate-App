import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_state.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final items = [
      {'icon': Icons.home, 'label': 'Home', 'tab': 'dashboard'},
      {'icon': Icons.apartment, 'label': 'Properties', 'tab': 'properties'},
      {'icon': Icons.people, 'label': 'Tenants', 'tab': 'tenants'},
      {'icon': Icons.payments, 'label': 'Payments', 'tab': 'payments'},
      {'icon': Icons.more_horiz, 'label': 'More', 'tab': 'more'},
    ];

    return BottomNavigationBar(
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(
                  item['icon'] as IconData,
                  color: appState.activeTab == item['tab']
                      ? AppColors.primaryBlue
                      : AppColors.grey500,
                ),
                label: item['label'] as String,
              ))
          .toList(),
      currentIndex: items.indexWhere((item) => item['tab'] == appState.activeTab),
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.grey500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        appState.setActiveTab(items[index]['tab'] as String);
      },
    );
  }
}