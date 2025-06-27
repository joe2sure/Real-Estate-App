import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 48),
          Image.network(
            Assets.logo,
            width: 96,
            height: 96,
          ),
          const SizedBox(height: 24),
          DefaultTabController(
            length: 2,
            initialIndex: appState.authTab == 'login' ? 0 : 1,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Register'),
                  ],
                  labelColor: primaryBlue,
                  unselectedLabelColor: grey600,
                  indicatorColor: primaryBlue,
                  onTap: (index) {
                    appState.setAuthTab(index == 0 ? 'login' : 'register');
                  },
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      LoginForm(),
                      RegisterForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}