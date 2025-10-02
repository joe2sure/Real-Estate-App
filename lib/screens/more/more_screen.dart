import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../auth/auth_screen.dart';
import 'profile_card.dart';
import 'edit_profile_screen.dart';
import 'user_management_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.03),
              AppColors.secondaryTeal.withOpacity(0.03),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.1),
                      AppColors.primaryBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Modern Header with Glassmorphism
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.secondaryTeal,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'More',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isAdmin
                                ? [
                                    AppColors.purple600.withOpacity(0.1),
                                    AppColors.primaryBlue.withOpacity(0.1),
                                  ]
                                : [
                                    AppColors.secondaryTeal.withOpacity(0.1),
                                    AppColors.green500.withOpacity(0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAdmin
                                ? AppColors.purple600.withOpacity(0.3)
                                : AppColors.secondaryTeal.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person,
                              size: 16,
                              color: isAdmin
                                  ? AppColors.purple600
                                  : AppColors.secondaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAdmin ? 'Admin' : 'User',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAdmin
                                    ? AppColors.purple600
                                    : AppColors.secondaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileCard(
                            onEditProfile: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          // Admin Section
                          if (isAdmin) ...[
                            _buildSectionHeader(
                              'ADMINISTRATION',
                              Icons.security,
                              AppColors.purple600,
                            ),
                            const SizedBox(height: 12),
                            _buildModernCard(
                              children: [
                                _buildFuturisticMenuItem(
                                  context,
                                  icon: Icons.group_rounded,
                                  iconColor: AppColors.primaryBlue,
                                  gradientColors: [
                                    AppColors.primaryBlue.withOpacity(0.1),
                                    AppColors.blue100.withOpacity(0.3),
                                  ],
                                  title: 'User Management',
                                  subtitle: 'Manage users & permissions',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserManagementScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildFuturisticMenuItem(
                                  context,
                                  icon: Icons.bar_chart_rounded,
                                  iconColor: AppColors.purple600,
                                  gradientColors: [
                                    AppColors.purple600.withOpacity(0.1),
                                    AppColors.purple100.withOpacity(0.3),
                                  ],
                                  title: 'Reports',
                                  subtitle: 'Analytics & insights',
                                  onTap: () {},
                                ),
                                _buildDivider(),
                                _buildFuturisticMenuItem(
                                  context,
                                  icon: Icons.folder_rounded,
                                  iconColor: AppColors.amber500,
                                  gradientColors: [
                                    AppColors.amber500.withOpacity(0.1),
                                    AppColors.amber100.withOpacity(0.3),
                                  ],
                                  title: 'Documents',
                                  subtitle: 'Files & resources',
                                  onTap: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                          
                          // Communication Section
                          _buildSectionHeader(
                            'COMMUNICATION',
                            Icons.chat_bubble_rounded,
                            AppColors.secondaryTeal,
                          ),
                          const SizedBox(height: 12),
                          _buildModernCard(
                            children: [
                              _buildFuturisticMenuItem(
                                context,
                                icon: Icons.notifications_active_rounded,
                                iconColor: AppColors.secondaryTeal,
                                gradientColors: [
                                  AppColors.secondaryTeal.withOpacity(0.1),
                                  AppColors.green100.withOpacity(0.3),
                                ],
                                title: 'Notifications',
                                subtitle: 'Alerts & updates',
                                badge: _buildBadge('5'),
                                onTap: () {},
                              ),
                              _buildDivider(),
                              _buildFuturisticMenuItem(
                                context,
                                icon: Icons.mail_rounded,
                                iconColor: AppColors.primaryBlue,
                                gradientColors: [
                                  AppColors.primaryBlue.withOpacity(0.1),
                                  AppColors.blue100.withOpacity(0.3),
                                ],
                                title: 'Messages',
                                subtitle: 'Chat & conversations',
                                badge: _buildBadge('3'),
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Preferences Section
                          _buildSectionHeader(
                            'PREFERENCES',
                            Icons.tune_rounded,
                            AppColors.grey600,
                          ),
                          const SizedBox(height: 12),
                          _buildModernCard(
                            children: [
                              _buildFuturisticMenuItem(
                                context,
                                icon: Icons.settings_rounded,
                                iconColor: AppColors.grey600,
                                gradientColors: [
                                  AppColors.grey600.withOpacity(0.1),
                                  AppColors.grey100.withOpacity(0.3),
                                ],
                                title: 'Settings',
                                subtitle: 'App preferences',
                                onTap: () {},
                              ),
                              _buildDivider(),
                              _buildDarkModeToggle(context),
                              _buildDivider(),
                              _buildFuturisticMenuItem(
                                context,
                                icon: Icons.help_outline_rounded,
                                iconColor: AppColors.primaryBlue,
                                gradientColors: [
                                  AppColors.primaryBlue.withOpacity(0.1),
                                  AppColors.blue100.withOpacity(0.3),
                                ],
                                title: 'Help & Support',
                                subtitle: 'Get assistance',
                                onTap: () {},
                              ),
                              _buildDivider(),
                              _buildFuturisticMenuItem(
                                context,
                                icon: Icons.logout_rounded,
                                iconColor: AppColors.red600,
                                gradientColors: [
                                  AppColors.red600.withOpacity(0.1),
                                  AppColors.red100.withOpacity(0.3),
                                ],
                                title: 'Logout',
                                subtitle: 'Sign out of account',
                                textColor: AppColors.red600,
                                onTap: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Footer
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    Strings.appVersion,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '© 2025 Peeman Property',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'All rights reserved',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFuturisticMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    Color textColor = Colors.black,
    Widget? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              badge
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.grey400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.grey600.withOpacity(0.1),
                  AppColors.grey100.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.grey600.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.dark_mode_rounded,
              color: AppColors.grey600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Toggle theme',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.grey200.withOpacity(0),
              AppColors.grey200,
              AppColors.grey200.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.red500, AppColors.red600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.red500.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red600),
            SizedBox(width: 12),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.logout();
              if (success) {
                Fluttertoast.showToast(
                  msg: 'Logout successful',
                  backgroundColor: AppColors.secondaryTeal,
                  textColor: AppColors.white,
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(initialTab: 'login'),
                  ),
                  (route) => false,
                );
              } else {
                Fluttertoast.showToast(
                  msg: authProvider.errorMessage ?? 'Logout failed',
                  backgroundColor: AppColors.red500,
                  textColor: AppColors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import '../../constants/strings.dart';
// import '../../providers/app_state.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_card.dart';
// import '../auth/auth_screen.dart';
// import 'profile_card.dart';

// class MoreScreen extends StatelessWidget {
//   const MoreScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 color: AppColors.white,
//                 child: const Text(
//                   'More',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const ProfileCard(),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'MANAGEMENT',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.grey500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         CustomCard(
//                           child: Column(
//                             children: [
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.person,
//                                 iconColor: AppColors.primaryBlue,
//                                 bgColor: AppColors.blue100,
//                                 title: 'Staff Management',
//                                 onTap: () {},
//                               ),
//                               const Divider(height: 1),
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.bar_chart,
//                                 iconColor: AppColors.purple600,
//                                 bgColor: AppColors.purple100,
//                                 title: 'Reports',
//                                 onTap: () {},
//                               ),
//                               const Divider(height: 1),
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.description,
//                                 iconColor: AppColors.amber500,
//                                 bgColor: AppColors.amber100,
//                                 title: 'Documents',
//                                 onTap: () {},
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'COMMUNICATION',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.grey500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         CustomCard(
//                           child: Column(
//                             children: [
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.notifications,
//                                 iconColor: AppColors.secondaryTeal,
//                                 bgColor: AppColors.green100,
//                                 title: 'Notifications',
//                                 onTap: () {},
//                               ),
//                               const Divider(height: 1),
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.email,
//                                 iconColor: AppColors.primaryBlue,
//                                 bgColor: AppColors.blue100,
//                                 title: 'Messages',
//                                 badge: Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: BoxDecoration(
//                                     color: AppColors.red500,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       '3',
//                                       style: TextStyle(
//                                         color: AppColors.white,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 onTap: () {},
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'PREFERENCES',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.grey500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         CustomCard(
//                           child: Column(
//                             children: [
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.settings,
//                                 iconColor: AppColors.grey600,
//                                 bgColor: AppColors.grey100,
//                                 title: 'Settings',
//                                 onTap: () {},
//                               ),
//                               const Divider(height: 1),
//                               Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           width: 32,
//                                           height: 32,
//                                           decoration: BoxDecoration(
//                                             color: AppColors.grey100,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Icon(
//                                             Icons.dark_mode,
//                                             color: AppColors.grey600,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         const Text(
//                                           'Dark Mode',
//                                           style: TextStyle(fontSize: 14),
//                                         ),
//                                       ],
//                                     ),
//                                     Switch(
//                                       value: false,
//                                       onChanged: (value) {},
//                                       activeColor: AppColors.primaryBlue,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Divider(height: 1),
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.help_outline,
//                                 iconColor: AppColors.primaryBlue,
//                                 bgColor: AppColors.blue100,
//                                 title: 'Help & Support',
//                                 onTap: () {},
//                               ),
//                               const Divider(height: 1),
//                               _buildMenuItem(
//                                 context,
//                                 icon: Icons.logout,
//                                 iconColor: AppColors.red600,
//                                 bgColor: AppColors.red100,
//                                 title: 'Logout',
//                                 textColor: AppColors.red600,
//                                 onTap: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: const Text('Confirm Logout'),
//                                       content: const Text('Are you sure you want to log out?'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () => Navigator.pop(context),
//                                           child: Text(
//                                             'Cancel',
//                                             style: TextStyle(color: AppColors.grey600),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () async {
//                                             Navigator.pop(context); // Close dialog
//                                             final authProvider = Provider.of<AuthProvider>(context, listen: false);
//                                             final success = await authProvider.logout();
//                                             if (success) {
//                                               Fluttertoast.showToast(
//                                                 msg: 'Logout successful',
//                                                 toastLength: Toast.LENGTH_SHORT,
//                                                 gravity: ToastGravity.TOP_RIGHT,
//                                                 backgroundColor: AppColors.secondaryTeal,
//                                                 textColor: AppColors.white,
//                                                 fontSize: 14.0,
//                                               );
//                                               Navigator.of(context).pushAndRemoveUntil(
//                                                 MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
//                                                 (route) => false,
//                                               );
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                 msg: authProvider.errorMessage ?? 'Logout failed',
//                                                 toastLength: Toast.LENGTH_SHORT,
//                                                 gravity: ToastGravity.TOP_RIGHT,
//                                                 backgroundColor: AppColors.red500,
//                                                 textColor: AppColors.white,
//                                                 fontSize: 14.0,
//                                               );
//                                             }
//                                           },
//                                           child: Text(
//                                             'Logout',
//                                             style: TextStyle(color: AppColors.red600),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Center(
//                           child: Column(
//                             children: [
//                               Text(
//                                 Strings.appVersion,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.grey500,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '© 2025 Peeman Property. All rights reserved.',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.grey400,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
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

//   Widget _buildMenuItem(
//     BuildContext context, {
//     required IconData icon,
//     required Color iconColor,
//     required Color bgColor,
//     required String title,
//     Color textColor = Colors.black,
//     Widget? badge,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: bgColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     color: iconColor,
//                     size: 16,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: textColor,
//                   ),
//                 ),
//               ],
//             ),
//             if (badge != null) badge,
//           ],
//         ),
//       ),
//     );
//   }
// }