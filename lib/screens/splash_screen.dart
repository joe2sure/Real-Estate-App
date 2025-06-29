import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../providers/app_state.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Provider.of<AppState>(context, listen: false).setOnboardingStep(0);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    Assets.logo,
                    width: 160,
                    height: 160,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      size: 160,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.appName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.tagline,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.white),
                    strokeWidth: 4,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                Strings.appVersion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../constants/assets.dart';
// import '../constants/colors.dart';
// import '../constants/strings.dart';
// import '../providers/app_state.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 2), () {
//       Provider.of<AppState>(context, listen: false).setOnboardingStep(0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     Assets.logo,
//                     width: 160,
//                     height: 160,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     Strings.appName,
//                     style: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     Strings.tagline,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: AppColors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(AppColors.white),
//                     strokeWidth: 4,
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 24,
//               left: 0,
//               right: 0,
//               child: Text(
//                 Strings.appVersion,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: AppColors.white,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }