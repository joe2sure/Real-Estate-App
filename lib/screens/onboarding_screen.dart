import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';
import '../models/onboarding_data_model.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';
import 'auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: 'Track Your Properties',
      description:
          'Easily manage all your properties in one place. Monitor performance, occupancy, and maintenance needs at a glance.',
      image: Assets.onboarding1,
    ),
    OnboardingData(
      title: 'Monitor Tenants & Payments',
      description:
          'Keep track of tenant information, lease agreements, and payment history. Get notified of upcoming and overdue payments.',
      image: Assets.onboarding2,
    ),
    OnboardingData(
      title: 'Collaborate With Your Team',
      description:
          'Invite team members, assign roles, and streamline communication. Work together efficiently to manage your properties.',
      image: Assets.onboarding3,
    ),
  ];

  final CarouselSliderController _controller = CarouselSliderController();
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start initial animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _animateTransition() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStep = appState.onboardingStep;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Stack(
        children: [
          // Background decoration
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),
          
          // Animated background shapes
          ...List.generate(8, (index) => _buildBackgroundShape(index)),

          Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomButton(
                      text: 'Skip',
                      onPressed: () {
                        appState.setOnboardingStep(-1);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                        );
                      },
                      isOutline: true,
                      maxWidth: 80,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                    height: double.infinity,
                    initialPage: currentStep,
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    onPageChanged: (index, _) {
                      appState.setOnboardingStep(index);
                      _animateTransition();
                    },
                  ),
                  items: onboardingData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated image container
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(140),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryBlue.withOpacity(0.1),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.white,
                                            AppColors.grey50,
                                          ],
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(140),
                                        child: Image.asset(
                                          data.image,
                                          width: 240,
                                          height: 240,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey100,
                                                  borderRadius: BorderRadius.circular(140),
                                                ),
                                                child: Icon(
                                                  Icons.business,
                                                  size: 120,
                                                  color: AppColors.grey400,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 48),

                              // Animated title
                              TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 600 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Text(
                                        data.title,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey800,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Animated description
                              TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 800 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 15 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Text(
                                        data.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.grey600,
                                          height: 1.5,
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Page indicators
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: currentStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: currentStep == index
                              ? AppColors.primaryBlue
                              : AppColors.grey300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  bottom: 40,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (currentStep > 0)
                        CustomButton(
                          text: 'Back',
                          onPressed: () {
                            _controller.previousPage();
                          },
                          isOutline: true,
                          minWidth: 100,
                        )
                      else
                        const SizedBox(width: 100),

                      // Next/Get Started button
                      CustomButton(
                        text: currentStep < onboardingData.length - 1
                            ? 'Next'
                            : 'Get Started',
                        onPressed: () {
                          if (currentStep < onboardingData.length - 1) {
                            _controller.nextPage();
                          } else {
                            appState.setOnboardingStep(-1);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen()),
                            );
                          }
                        },
                        isGradient: true,
                        minWidth: 140,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShape(int index) {
    final double top = (index * 120.0) % MediaQuery.of(context).size.height;
    final double left = (index * 80.0) % MediaQuery.of(context).size.width;
    
    return Positioned(
      top: top,
      left: left,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 2000 + (index * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 6.28, // Full rotation
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 60 + (index % 3) * 20.0,
                height: 60 + (index % 3) * 20.0,
                decoration: BoxDecoration(
                  shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  color: index % 3 == 0 
                      ? AppColors.primaryBlue 
                      : AppColors.secondaryTeal,
                  borderRadius: index % 2 != 0 
                      ? BorderRadius.circular(15) 
                      : null,
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
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:provider/provider.dart';
// import '../constants/assets.dart';
// import '../constants/colors.dart';
// import '../models/onboarding_data_model.dart';
// import '../providers/app_state.dart';
// import '../widgets/custom_button.dart';
// import 'auth/auth_screen.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final List<OnboardingData> onboardingData = [
//     OnboardingData(
//       title: 'Track Your Properties',
//       description:
//           'Easily manage all your properties in one place. Monitor performance, occupancy, and maintenance needs at a glance.',
//       image: Assets.onboarding1,
//     ),
//     OnboardingData(
//       title: 'Monitor Tenants & Payments',
//       description:
//           'Keep track of tenant information, lease agreements, and payment history. Get notified of upcoming and overdue payments.',
//       image: Assets.onboarding2,
//     ),
//     OnboardingData(
//       title: 'Collaborate With Your Team',
//       description:
//           'Invite team members, assign roles, and streamline communication. Work together efficiently to manage your properties.',
//       image: Assets.onboarding3,
//     ),
//   ];

//   final CarouselSliderController _controller = CarouselSliderController();

//   @override
//   Widget build(BuildContext context) {
//     final appState = Provider.of<AppState>(context);
//     final currentStep = appState.onboardingStep;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: CarouselSlider(
//                   carouselController: _controller,
//                   options: CarouselOptions(
//                     height: double.infinity,
//                     initialPage: currentStep,
//                     enableInfiniteScroll: false,
//                     viewportFraction: 1.0,
//                     onPageChanged: (index, _) {
//                       appState.setOnboardingStep(index);
//                     },
//                   ),
//                   items: onboardingData.map((data) {
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           data.image,
//                           width: 256,
//                           height: 256,
//                           errorBuilder: (context, error, stackTrace) => const Icon(
//                             Icons.error,
//                             size: 256,
//                             color: AppColors.grey600,
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         Text(
//                           data.title,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.grey800,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 12),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           child: Text(
//                             data.description,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: AppColors.grey600,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 80),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     onboardingData.length,
//                     (index) => Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       width: 10,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: currentStep == index
//                             ? AppColors.primaryBlue
//                             : AppColors.grey300,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 16,
//             right: 16,
//             child: CustomButton(
//               text: 'Skip',
//               onPressed: () {
//                 appState.setOnboardingStep(-1);
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(builder: (context) => const AuthScreen()),
//                 );
//               },
//               isOutline: true,
//             ),
//           ),
//           Positioned(
//             bottom: 32,
//             left: 24,
//             right: 24,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (currentStep > 0)
//                   CustomButton(
//                     text: 'Back',
//                     onPressed: () {
//                       _controller.previousPage();
//                     },
//                     isOutline: true,
//                   )
//                 else
//                   const SizedBox(),
//                 CustomButton(
//                   text: currentStep < onboardingData.length - 1
//                       ? 'Next'
//                       : 'Get Started',
//                   onPressed: () {
//                     if (currentStep < onboardingData.length - 1) {
//                       _controller.nextPage();
//                     } else {
//                       appState.setOnboardingStep(-1);
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => const AuthScreen()),
//                       );
//                     }
//                   },
//                   isGradient: true,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }