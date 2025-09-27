import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Progress indicator animation
    _progressFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeIn,
    ));

    // Start animations sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 300));
    await _progressController.forward();
    
    // Navigate after all animations complete
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Provider.of<AppState>(context, listen: false).setOnboardingStep(0);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
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
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              Assets.logo,
                              width: 120,
                              height: 120,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) => const Icon(
                                Icons.business,
                                size: 120,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Animated App Name
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Text(
                        Strings.appName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Animated Tagline
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Text(
                        Strings.tagline,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white.withOpacity(0.9),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated Progress Indicator
                  FadeTransition(
                    opacity: _progressFadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Version Info
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Text(
                  Strings.appVersion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final double left = (index * 37.0) % 100;
    final double animationDelay = (index * 0.2) % 2.0;
    
    return Positioned(
      left: left,
      top: 100 + (index * 23.0) % 400,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 2000 + (index * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -20 * value),
            child: Opacity(
              opacity: (1 - value) * 0.3,
              child: Container(
                width: 4 + (index % 3) * 2.0,
                height: 4 + (index % 3) * 2.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../constants/assets.dart';
// import '../constants/colors.dart';
// import '../constants/strings.dart';
// import '../providers/app_state.dart';
// import 'onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Use addPostFrameCallback to ensure navigation happens after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           Provider.of<AppState>(context, listen: false).setOnboardingStep(0);
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//           );
//         }
//       });
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
//                   Image.network(
//                     Assets.logo,
//                     width: 160,
//                     height: 160,
//                     errorBuilder: (context, error, stackTrace) => const Icon(
//                       Icons.error,
//                       size: 160,
//                       color: AppColors.white,
//                     ),
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