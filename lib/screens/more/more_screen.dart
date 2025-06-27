import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../providers/app_state.dart';
import '../../widgets/bottom_navigation.dart';
import 'profile_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                color: white,
                child: const Text(
                  'More',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ProfileCard(),
                        const SizedBox(height: 24),
                        const Text(
                          'MANAGEMENT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.person,
                                iconColor: primaryBlue,
                                bgColor: blue100,
                                title: 'Staff Management',
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.bar_chart,
                                iconColor: purple600,
                                bgColor: purple100,
                                title: 'Reports',
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.description,
                                iconColor: amber500,
                                bgColor: amber100,
                                title: 'Documents',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'COMMUNICATION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.notifications,
                                iconColor: secondaryTeal,
                                bgColor: green100,
                                title: 'Notifications',
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.email,
                                iconColor: primaryBlue,
                                bgColor: blue100,
                                title: 'Messages',
                                badge: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: red500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'PREFERENCES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.settings,
                                iconColor: grey600,
                                bgColor: grey100,
                                title: 'Settings',
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: grey100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.dark_mode,
                                            color: grey600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Dark Mode',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: false,
                                      onChanged: (value) {},
                                      activeColor: primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                iconColor: primaryBlue,
                                bgColor: blue100,
                                title: 'Help & Support',
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.logout,
                                iconColor: red600,
                                bgColor: red100,
                                title: 'Logout',
                                textColor: red600,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                Strings.appVersion,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2025 PropertyPro. All rights reserved.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }

    Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    Color textColor = Colors.black,
    Widget? badge,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
            if (badge != null) badge,
          ],
        ),
      ),
    );
  }
}