import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/properties/properties_screen.dart';
import 'screens/tenants/tenants_screen.dart';
import 'screens/payments/payment_screen.dart';
import 'screens/more/more_screen.dart';
import 'widgets/bottom_navigation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeemanProperty',
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          secondary: const Color(0xFF059669),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
      home: const MainScreen(),
      // Routes are no longer needed since navigation is handled by Navigator
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // Map tab names to their respective screens
  Widget _getScreenForTab(String tab) {
    switch (tab) {
      case 'dashboard':
        return const DashboardScreen();
      case 'properties':
        return const PropertiesScreen();
      case 'tenants':
        return const TenantsScreen();
      case 'payments':
        return const PaymentsScreen();
      case 'more':
        return const MoreScreen();
      default:
        return const DashboardScreen(); // Fallback to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        Widget content;
        bool showBottomNav = false;

        if (appState.onboardingStep >= 0 && appState.onboardingStep < 3) {
          content = const OnboardingScreen();
        } else if (appState.onboardingStep == -1 && !appState.autoLogin) {
          content = const AuthScreen();
          showBottomNav = true; // Show bottom nav on auth screen
        } else if (appState.onboardingStep == -1 && appState.autoLogin) {
          // Auto-login: Redirect to dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.activeTab.isEmpty) {
              appState.setActiveTab('dashboard');
            }
          });
          content = _getScreenForTab(appState.activeTab);
          showBottomNav = true;
        } else {
          content = const SplashScreen();
          showBottomNav = false; // Explicitly hide bottom nav on splash
        }

        return Scaffold(
          body: Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => content,
              );
            },
          ),
          bottomNavigationBar: showBottomNav ? const BottomNavigation() : null,
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers/app_state.dart';
// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/auth/auth_screen.dart';
// import 'screens/dashboard/dashboard_screen.dart';
// import 'screens/properties/properties_screen.dart';
// import 'screens/tenants/tenants_screen.dart';
// import 'screens/payments/payment_screen.dart';
// import 'screens/more/more_screen.dart';
// import 'widgets/bottom_navigation.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => AppState(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PropertyPro',
//       theme: ThemeData(
//         primaryColor: const Color(0xFF2563EB),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF2563EB),
//           secondary: const Color(0xFF059669),
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF7F7F7),
//         cardTheme: CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         buttonTheme: const ButtonThemeData(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
//         ),
//       ),
//       home: const MainScreen(),
//       routes: {
//         '/dashboard': (context) => const DashboardScreen(),
//         '/properties': (context) => const PropertiesScreen(),
//         '/tenants': (context) => const TenantsScreen(),
//         '/payments': (context) => const PaymentsScreen(),
//         '/more': (context) => const MoreScreen(),
//         '/auth': (context) => const AuthScreen(),
//       },
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppState>(
//       builder: (context, appState, child) {
//         Widget content;
//         if (appState.onboardingStep >= 0 && appState.onboardingStep < 3) {
//           content = const OnboardingScreen();
//         } else if (appState.onboardingStep == -1 && !appState.autoLogin) {
//           content = const AuthScreen();
//         } else if (appState.onboardingStep == -1 && appState.autoLogin) {
//           // Auto-login: Redirect to dashboard after a brief delay
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (appState.activeTab.isEmpty) {
//               appState.setActiveTab('dashboard', context: context);
//             }
//           });
//           content = const DashboardScreen();
//         } else {
//           content = const SplashScreen();
//         }

//         return Scaffold(
//           body: content,
//           bottomNavigationBar: appState.onboardingStep == -1 || appState.autoLogin
//               ? const BottomNavigation()
//               : null,
//         );
//       },
//     );
//   }
// }