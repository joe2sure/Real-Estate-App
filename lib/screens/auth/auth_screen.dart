import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  final String initialTab;

  const AuthScreen({super.key, this.initialTab = 'login'});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/peeman-logo.png', // Update with correct asset path
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTabButton('Login', _currentTab == 'login', () {
                          setState(() {
                            _currentTab = 'login';
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildTabButton('Register', _currentTab == 'register', () {
                          setState(() {
                            _currentTab = 'register';
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              _currentTab == 'login' ? const LoginForm() : const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import '../../providers/app_state.dart';
// import 'login_form.dart';
// import 'register_form.dart';

// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final appState = Provider.of<AppState>(context);
//     return Scaffold(
//       body: Column(
//         children: [
//           const SizedBox(height: 48),
//           Image.network(
//             Assets.logo,
//             width: 96,
//             height: 96,
//           ),
//           const SizedBox(height: 24),
//           DefaultTabController(
//             length: 2,
//             initialIndex: appState.authTab == 'login' ? 0 : 1,
//             child: Column(
//               children: [
//                 TabBar(
//                   tabs: const [
//                     Tab(text: 'Login'),
//                     Tab(text: 'Register'),
//                   ],
//                   labelColor: AppColors.primaryBlue,
//                   unselectedLabelColor: AppColors.grey600,
//                   indicatorColor: AppColors.primaryBlue,
//                   onTap: (index) {
//                     appState.setAuthTab(index == 0 ? 'login' : 'register');
//                   },
//                 ),
//                 SizedBox(
//                   height: 500,
//                   child: TabBarView(
//                     children: [
//                       LoginForm(),
//                       RegisterForm(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }