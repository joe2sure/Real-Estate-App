import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/property_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/payment_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/properties/properties_screen.dart';
import 'screens/tenants/tenants_screen.dart';
import 'screens/payments/payment_screen.dart';
import 'screens/more/more_screen.dart';
import 'widgets/bottom_navigation.dart';
import 'hive/hive_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Single line registration with built-in conflict prevention
  HiveRegistry.registerAllAdapters();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (context) => TenantProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peeman Property',
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          secondary: const Color(0xFF059669),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
     /*   cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),*/
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
      home: ScaffoldMessenger(
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, AuthProvider>(
      builder: (context, appState, authProvider, child) {
        Widget content;
        bool showBottomNav = false;
        if (appState.onboardingStep >= 0 && appState.onboardingStep < 3) {
          content = const OnboardingScreen();
        } else if (appState.onboardingStep == -1 && !authProvider.isLoggedIn) {
          content = const AuthScreen();
        } else if (appState.onboardingStep == -1 && authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.activeTab.isEmpty) {
              appState.setActiveTab('dashboard');
            }
          });
          content = _getScreenForTab(appState.activeTab);
          showBottomNav = true;
        } else {
          content = const SplashScreen();
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
// import 'package:hive_flutter/hive_flutter.dart';
// import 'providers/app_state.dart';
// import 'providers/auth_provider.dart';
// import 'providers/tenant_provider.dart';
// import 'providers/property_provider.dart';
// import 'providers/dashboard_provider.dart';
// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/auth/auth_screen.dart';
// import 'screens/dashboard/dashboard_screen.dart';
// import 'screens/properties/properties_screen.dart';
// import 'screens/tenants/tenants_screen.dart';
// import 'screens/payments/payment_screen.dart';
// import 'screens/more/more_screen.dart';
// import 'widgets/bottom_navigation.dart';
// import 'models/tenant.dart';
// import 'models/user_model.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   Hive.registerAdapter(UserAdapter());
//   Hive.registerAdapter(TenantAdapter());
//   Hive.registerAdapter(PropertyAdapter());
//   Hive.registerAdapter(EmergencyContactAdapter());

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AppState()),
//         ChangeNotifierProvider(create: (context) => AuthProvider()..init()),
//         ChangeNotifierProvider(create: (context) => TenantProvider()),
//         ChangeNotifierProvider(create: (context) => DashboardProvider()),
//         ChangeNotifierProvider(create: (_) => PropertyProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Peeman Property',
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
//       home: ScaffoldMessenger(
//         child: const MainScreen(),
//       ),
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});

//   Widget _getScreenForTab(String tab) {
//     switch (tab) {
//       case 'dashboard':
//         return const DashboardScreen();
//       case 'properties':
//         return const PropertiesScreen();
//       case 'tenants':
//         return const TenantsScreen();
//       case 'payments':
//         return const PaymentsScreen();
//       case 'more':
//         return const MoreScreen();
//       default:
//         return const DashboardScreen();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<AppState, AuthProvider>(
//       builder: (context, appState, authProvider, child) {
//         Widget content;
//         bool showBottomNav = false;

//         if (appState.onboardingStep >= 0 && appState.onboardingStep < 3) {
//           content = const OnboardingScreen();
//         } else if (appState.onboardingStep == -1 && !authProvider.isLoggedIn) {
//           content = const AuthScreen();
//         } else if (appState.onboardingStep == -1 && authProvider.isLoggedIn) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (appState.activeTab.isEmpty) {
//               appState.setActiveTab('dashboard');
//             }
//           });
//           content = _getScreenForTab(appState.activeTab);
//           showBottomNav = true;
//         } else {
//           content = const SplashScreen();
//         }

//         return Scaffold(
//           body: Navigator(
//             key: GlobalKey<NavigatorState>(),
//             onGenerateRoute: (settings) {
//               return MaterialPageRoute(
//                 builder: (context) => content,
//               );
//             },
//           ),
//           bottomNavigationBar: showBottomNav ? const BottomNavigation() : null,
//         );
//       },
//     );
//   }
// }