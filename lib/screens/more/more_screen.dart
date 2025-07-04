import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../auth/auth_screen.dart';
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
                color: AppColors.white,
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
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context,
                                icon: Icons.person,
                                iconColor: AppColors.primaryBlue,
                                bgColor: AppColors.blue100,
                                title: 'Staff Management',
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                icon: Icons.bar_chart,
                                iconColor: AppColors.purple600,
                                bgColor: AppColors.purple100,
                                title: 'Reports',
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                icon: Icons.description,
                                iconColor: AppColors.amber500,
                                bgColor: AppColors.amber100,
                                title: 'Documents',
                                onTap: () {},
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
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context,
                                icon: Icons.notifications,
                                iconColor: AppColors.secondaryTeal,
                                bgColor: AppColors.green100,
                                title: 'Notifications',
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                icon: Icons.email,
                                iconColor: AppColors.primaryBlue,
                                bgColor: AppColors.blue100,
                                title: 'Messages',
                                badge: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.red500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {},
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
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context,
                                icon: Icons.settings,
                                iconColor: AppColors.grey600,
                                bgColor: AppColors.grey100,
                                title: 'Settings',
                                onTap: () {},
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
                                            color: AppColors.grey100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.dark_mode,
                                            color: AppColors.grey600,
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
                                      activeColor: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                icon: Icons.help_outline,
                                iconColor: AppColors.primaryBlue,
                                bgColor: AppColors.blue100,
                                title: 'Help & Support',
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                icon: Icons.logout,
                                iconColor: AppColors.red600,
                                bgColor: AppColors.red100,
                                title: 'Logout',
                                textColor: AppColors.red600,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Logout'),
                                      content: const Text('Are you sure you want to log out?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: AppColors.grey600),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context); // Close dialog
                                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                            final success = await authProvider.logout();
                                            if (success) {
                                              Fluttertoast.showToast(
                                                msg: 'Logout successful',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.TOP_RIGHT,
                                                backgroundColor: AppColors.secondaryTeal,
                                                textColor: AppColors.white,
                                                fontSize: 14.0,
                                              );
                                              Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
                                                (route) => false,
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: authProvider.errorMessage ?? 'Logout failed',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.TOP_RIGHT,
                                                backgroundColor: AppColors.red500,
                                                textColor: AppColors.white,
                                                fontSize: 14.0,
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Logout',
                                            style: TextStyle(color: AppColors.red600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                                  color: AppColors.grey500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2025 Peeman Property. All rights reserved.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey400,
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
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    Color textColor = Colors.black,
    Widget? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import '../../constants/strings.dart';
// import '../../providers/app_state.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_card.dart';
// // import '../../widgets/custom_toast.dart';
// import '../../widgets/custom_toaster.dart';
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
//                                 onTap: () async {
//                                   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//                                   final success = await authProvider.logout();
//                                   if (success) {
//                                     CustomToast.show(context, 'Logout successful', isSuccess: true);
//                                     Navigator.of(context).pushAndRemoveUntil(
//                                       MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
//                                       (route) => false,
//                                     );
//                                   } else {
//                                     CustomToast.show(context, authProvider.errorMessage ?? 'Logout failed', isSuccess: false);
//                                   }
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